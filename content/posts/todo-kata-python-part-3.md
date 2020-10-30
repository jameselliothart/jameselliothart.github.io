title: Todo Kata - Python Part 3
date: 10-30-20
author: James Hart
category: Tutorial
tags: Tutorial, Python, Todo, Development, SQLite

Welcome to Part 3 of the Python Todo kata.
In this final part, we will revisit the `done` application and modify it to work with a SQLite database instead of a text file.

We will see that Python makes this very easy with its built-in integration with SQLite in the standard library.
In creating this post, I found the following resources very useful:

- This [Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-use-the-sqlite3-module-in-python-3) tutorial (as an aside, I have been pleasantly surprised by the high quality of several Digital Ocean community tutorials given it is actually a cloud platform)
- The [Python docs](https://docs.python.org/3.6/library/sqlite3.html#sqlite3-controlling-transactions) covering SQLite transactions
- This [StackOverflow](https://stackoverflow.com/a/1830499) answer showing how to retrieve a Python `datetime` object from SQLite rather than a string (SQLite [has no datetime datatype](https://www.sqlite.org/datatype3.html) as other databases do)

Series Outline

1. [Intro](todo-kata-introduction)
2. F# Series
    1. [Part 1 - Done](todo-kata-fsharp-part-1)
    2. [Part 2 - Todo](todo-kata-fsharp-part-2)
    3. [Part 3 - SQLite](todo-kata-fsharp-part-3)
3. Python Series
    1. [Part 1 - Done](todo-kata-python-part-1)
    2. [Part 2 - Todo](todo-kata-python-part-2)
    3. Part 3 - SQLite (you are here)

Full source code is available [here](https://github.com/jameselliothart/PyTodo).

## done_db.py

The SQLite implementation will live in the `done_db.py` file.
We will start with the imports we'll need and by defining the path to the database file.

```py
import os
import done_domain as done
import sqlite3
from datetime import datetime
from typing import List
from contextlib import contextmanager, closing

PATH = 'done.db'
```

The first function we will define, `_cursor`, will be a context manager for our connection to the database:

```py
@contextmanager
def _cursor(db_path: str):
    with closing(sqlite3.connect(db_path, isolation_level=None, detect_types=sqlite3.PARSE_DECLTYPES)) as connection:
        with closing(connection.cursor()) as cursor:
            yield cursor
```

This looks pretty ugly, but the good news is that we will never have to worry about these details again as we use `_cursor` to interact with the database in our other functions.
Technically we could avoid creating the `cursor` object because SQLite will implicitly create it for us via [shortcut methods](https://docs.python.org/3/library/sqlite3.html#using-shortcut-methods).
However, we may as well be explicit since we are encapsulating all the implementation details here anyway.

To explain some of those details:

- [`closing`](https://docs.python.org/3.6/library/contextlib.html#contextlib.closing) creates a context manager which calls `close()` for the underlying object as cleanup
- `isolation_level=None` configures the connection to autocommit mode (a discussion of database transactions is out of scope, but you can read more [here](https://docs.python.org/3/library/sqlite3.html#controlling-transactions))
- The `detect_types` argument is half of the answer to being able to automatically retrieve `datetime` objects (the other half is using a `TIMESTAMP` datatype which we will see below)

We will define one more helper function to initialize the database before we get to the persistence logic:

```py
def _initialize_db(db_path: str):
    with _cursor(db_path) as cursor:
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS CompletedItems (
                Id INTEGER PRIMARY KEY,
                CompletedOn TIMESTAMP,
                Item VARCHAR(255)
                )"""
            )
```

Here we use the `_cursor` context manager we just defined to create the `CompletedItems` table to hold our completed items (notice SQLite has a nice syntax for creating a table if it does not exist).
The `TIMESTAMP` datatype declaration for the `CompletedOn` column is not part of the SQLite API but allows Python to translate it into `datetime` objects when the connection uses the `detect_types` specification we saw earlier.

Next we will define the `save` and `get` functions which we will swap in for the `done_file` functions.
Here is `save`:

```py
def save(db_path: str, completed_items: List[done.CompletedItem]):
    if not os.path.exists(PATH): _initialize_db(PATH)
    with _cursor(db_path) as cursor:
        for completed_item in completed_items:
            cursor.execute(
                "INSERT INTO CompletedItems (CompletedOn, Item) VALUES (?, ?)",
                (completed_item.completed_on, completed_item.item)
                )
```

First we check if the database file exists and initialize if not.
Then we insert our completed item using parameter substitution (the `?`) - this is a best practice for parametrized SQL to avoid [SQL injection](https://owasp.org/www-community/attacks/SQL_Injection).

We finish off the file with the definition for `get`:

```py
def get(db_path: str, completed_since: datetime) -> List[done.CompletedItem]:
    if not os.path.exists(PATH): _initialize_db(PATH)
    with _cursor(db_path) as cursor:
        rows = cursor.execute(
            "SELECT Item, CompletedOn from CompletedItems WHERE CompletedOn > ?",
            (completed_since,)
            )
        return [done.CompletedItem(*row) for row in rows.fetchall()]
```

We again ensure the database exists and use parameter substitution in our query.
The `*row` expansion allows us to construct `CompletedItem`s from the `Item` and `CompletedOn` values returned in the `row`.
(As an aside, the `sqlite3.Row` class [enables](https://docs.python.org/3/library/sqlite3.html#accessing-columns-by-name-instead-of-by-index) accessing columns by name instead of by index though we do not need that here.)

Now all that is left to do is to update `done` to use our newly defined `save` and `get` rather than the ones from `done_file`.

## done.py

In `done.py`, we add an import for `done_db` and switch out the `save` and `get` functions:

```py
import done_db

# save = partial(done_file.save, done_file.PATH)
# get = partial(done_file.get, done_file.PATH)

save = partial(done_db.save, done_db.PATH)
get = partial(done_db.get, done_db.PATH)
```

That's it!
No other updates are required for `done` and `todo` to use our SQLite persistence logic for completed items.
The ease with which we made this change provides some validation of our loosely coupled application design.

## Demonstration

We can now run either the `python done.py` or `python todo.py` commands to log a completed item, and they will be saved to the done.db database.
To see this better in VS Code, the `alexcvzz.vscode-sqlite` extension allows us to query the database directly.
Here are the results for me:

| Id | CompletedOn | Item |
| --- | --- | --- |
| 1 | 2020-10-10 10:33:03.696278 | done db |
| 2 | 2020-10-10 10:52:26.556313 | add a todo |
| 3 | 2020-10-29 18:48:52.621930 | complete sqlite |

And of course, we can query for these items via `python done.py` as well:

```shell
$ python done.py d 0
[2020-10-29T18:48:52.621930] complete sqlite
$ python done.py w 3
[2020-10-10T10:33:03.696278] done db
[2020-10-10T10:52:26.556313] add a todo
[2020-10-29T18:48:52.621930] complete sqlite
```

## Wrapping Up

That concludes the Python series of the Todo kata!
In this series, we saw the ease with which we can work with both text files and SQLite databases in Python using just the standard library.
Additionally, we were able to get some experience with static typing via `mypy`, creating command-line interfaces with `click`, and even some reactive programming with `RxPY`.
Of course, there is much more we could have covered about any of these topics, but I think this gives a good starting point for diving deeper and creating more complex applications.
