title: Todo Kata - Python Part 1
date: 10-11-20
author: James Hart
category: Tutorial
tags: Tutorial, Python, Todo, Development, mypy, click

In this part of the **Todo** kata, we will cover the Python implementation.
If you are new to the series, I would recommend reading the [intro](todo-kata-introduction) first.
It should give sufficient background to be able to follow along even without being familiar with previous posts.

Series Outline

1. [Intro](todo-kata-introduction)
2. F# Series
    1. [Part 1 - Done](todo-kata-fsharp-part-1)
    2. [Part 2 - Todo](todo-kata-fsharp-part-2)
    3. [Part 3 - SQLite](todo-kata-fsharp-part-3)
3. Python Series
    1. Part 1 - Done (you are here)
    2. [Part 2 - Todo](todo-kata-python-part-2)
    3. [Part 3 - SQLite](todo-kata-python-part-3)

Full source code is available [here](https://github.com/jameselliothart/PyTodo).

## Setup

Note: The version of Python on my machine - Python 3.6 - is relatively old, and there are several nice features that have been added to the language since which I will point out along the way.

We will start by creating a folder for the project and setting up a virtual environment:

```shell
$ mkdir PyTodo
$ cd PyTodo
$ python3 -m venv venv
$ code .
```

VS Code will automatically detect and activate the virtual environment which is a great convenience.
To use [mypy](https://mypy.readthedocs.io/en/latest/) as the linter, we install it and configure the .vscode/settings.json.

```shell
(venv) $ python -m pip install mypy
```

.vscode/settings.json
```json
{
    "python.linting.mypyEnabled": true,
    "python.linting.enabled": true,
}
```

Of course, you can use another linter and skip the type hints.
However, even for a simple program like this, type hints caught a number of bugs at design time.

With our setup complete, we can start writing some code.

## done_domain.py

The domain logic of `done` consists just of the `CompletedItem` class and some functions for returning dates we will use to query for completed items.

```py
from datetime import datetime, timedelta
from typing import NamedTuple

class CompletedItem(NamedTuple):
    item: str
    completed_on: datetime

    def __str__(self) -> str:
        return f'[{self.completed_on.isoformat()}] {self.item}'

def create_default(item: str) -> CompletedItem:
    return CompletedItem(item, datetime.now())
```

The `CompletedItem` class is just a `NamedTuple` with a nice string representation.
We will use that when writing a `CompletedItem` to a file and when printing it to the console.
(*Note: a [`dataclass`](https://docs.python.org/3/library/dataclasses.html) would also be a nice way of implementing `CompletedItem` in Python 3.7+.*)

The date functions are nothing special:

```py
def _start_of_day(date: datetime) -> datetime:
    return date.replace(hour=0, minute=0, second=0, microsecond=0)

def _start_of_week(date: datetime) -> datetime:
    return _start_of_day(date - timedelta(days=date.isoweekday()))

def days_ago(date: datetime, num_days: int) -> datetime:
    return _start_of_day(date - timedelta(days=num_days))

def weeks_ago(date: datetime, num_weeks: int) -> datetime:
    return _start_of_week(date - timedelta(days=7*num_weeks))
```

Note the leading `_` to mark "private" functions - we will not use `_start_of_day` or `_start_of_week` outside of this module.

## file.py

Next we will create some helper functions for reading from and writing to files.
We will only use `append_line` for `done` (the others will be used in `todo`), but we may as well define them all now.

```py
import os
from typing import List


def write_all_lines(path: str, lines: List[str]):
    with open(path, 'w') as f:
        for line in lines:
            print(line, file=f)

def append_line(path: str, line: str):
    with open(path, 'a') as f:
        print(line, file=f)

def read_all_lines(path: str) -> List[str]:
    if not os.path.exists(path):
        return []
    with open(path) as f:
        return [line.strip() for line in f.readlines()]
```

The `print(line, file=f)` idiom is a nice way of writing a line to a file without having to remember to specify the new line at the end.
It is easy to forget the `\n` in `f.writelines([f'{line}\n' for line in lines])` and get everything on one line!
It is also easy to forget to `strip()` the new lines when reading a file, but such is life.

## done_file.py

You may have noticed in [Part 1 of the F# series](todo-kata-fsharp-part-1) that we had domain functions (in domain.fs) related to parsing completed items from strings.
Since that logic is specific to file persistence, it really does not belong in the domain - we will correct that this time around.

```py
import re
import os
import file
import done_domain as done
from datetime import datetime
from typing import List, Optional

# define a file path where completed items will be stored
PATH = 'todo.done.txt'

def _parse_datetime(iso_date: str) -> datetime:
    return datetime.strptime(iso_date, "%Y-%m-%dT%H:%M:%S.%f")

# could add a print statement when parse fails
def try_parse(done_item: str) -> Optional[done.CompletedItem]:
    pattern = r'^\[(?P<completedOn>.*)\] (?P<item>.*)'
    matches = re.match(pattern, done_item)
    if matches:
        completed_on = _parse_datetime(matches.group('completedOn'))
        item = matches.group('item')
        return done.CompletedItem(item, completed_on)
    return None

def parse(done_item: str) -> done.CompletedItem:
    '''Raises `ValueError` if parse fails.'''
    completed_item = try_parse(done_item)
    if completed_item:
        return completed_item
    else:
        raise ValueError("`done_item` must be of format '[isodate] completed item'")
```

Recall that we are calling `completed_on.isoformat()` to get a string representation of the completed time.
In Python 3.7+, there is an inverse function [`fromisoformat`](https://docs.python.org/3.8/library/datetime.html#datetime.date.fromisoformat) to get back the datetime object, but since we are using 3.6 we have to parse manually.
It is useful to be familiar with how to do this anyway when the need arises to parse dates encountered in the wild.

The `parse` function is basically the equivalent of our explicitly extracting the `Option.Value` in the F# version - we do it to get rid of the `Optional` while understanding we should be sure the parse does not fail.
You could see this as a drawback of using type hints in that we almost doubled the amount of parsing code just to have the types work out.
With `try_parse` alone, we would still get a runtime exception if we tried to access the returned `CompletedItem`, so you could argue we are no better off having `parse` raise a runtime exception slightly earlier.

However, having `try_parse` return an `Optional[done.CompletedItem]` gives it an *honest type signature*.
Callers know that the parse may fail and return `None`, enabling them to respond accordingly at design time without having to peek at the definition, look at any documentation, or run any code.
Without type hints, we may still assume that the parse could fail (hence the `try`), but what is the failure behavior?
Does it raise an exception (and if so, what?), return a `Tuple` of `(success_status, value)`, return `None`, something else?
Unit tests are a great way of exposing and documenting the API in cases like this without type hints (and may still be a good idea since type hints are ignored at runtime), but having a linter like mypy do some of that work for you definitely takes off cognitive load.

Finally, notice that in both `try_parse` and `parse` we assign a variable and then immediately use it in an `if` statement.
Python 3.8 introduced assignment expressions (aka the walrus operator) to allow assigning a variable and using it in one line:

```py
if (matches := re.match(pattern, done_item) is not None:
    item = matches.group('item')
    # ...
```

Wouldn't that be convenient?
This use case of working with the match on a regular expression was actually part of the original justification for introducing assignment expressions into the language in [PEP 572](https://www.python.org/dev/peps/pep-0572/).

Now we can finish off with the functions for reading and writing completed items to a file.

```py
def _check_completed_since(completed_item: Optional[done.CompletedItem], completed_since: datetime) -> bool:
    return completed_since < completed_item.completed_on if completed_item else False

def get(path: str, completed_since: datetime) -> List[done.CompletedItem]:
    if not os.path.exists(path):
        return []
    with open(path) as f:
        return [
            parse(line.strip())
            for line in f.readlines()
            if _check_completed_since(try_parse(line), completed_since)
            ]

def save(path: str, completed_items: List[done.CompletedItem]) -> None:
    for completed_item in completed_items:
        file.append_line(path, str(completed_item))
```

We use Python's ability to easily operate on lines in a file as they are read (`for line in f.readlines()`) to filter out items completed before the specified date.
Our returning an `Optional` from `try_parse` alerts us that `_check_completed_since` will have to account for the possibility of a null reference.
Also note we explicitly write `str(completed_item)` to the file to get the `__str__` representation we defined for the `CompletedItem` class.

## shared.py

The last piece we need before we get to the executable program is a function for displaying to the console.
We will put this in a "shared" module since both `done` and `todo` will use it.

```py
from typing import Any, Iterable

def display(data: Iterable[Any]):
    for datum in data: print(str(datum))
```

We make a call to `str` just to be explicit (`print` will already use the `__str__` representation implicitly).

## done.py

Now we can actually configure and define the CLI (command-line interface).
We will use partial application (via `partial` from `functools`) to create `get` and `save` functions which will access the path defined in done_file.py to read and write completed items.

We will also define a helper function `save_from_string` to save a collection of strings as completed items.
This will be more helpful later when we technically pass a list of todo items to be completed, but it also gives us the ability to save multiple completed items at once with one command with a little modification to the command-line parsing.
We will leave that as an exercise.

```py
import done_file
import done_domain
from functools import partial
from typing import Iterable

save = partial(done_file.save, done_file.PATH)
get = partial(done_file.get, done_file.PATH)

def save_from_string(items: Iterable[str]):
    save([done_domain.create_default(item) for item in items])
```

With the configuration complete, we can work on handling the incoming command-line arguments.
We will use the [click](https://click.palletsprojects.com/en/7.x/) package to help with this.

```shell
(venv) $ python -m pip install click
```

I was hesitant at first to install a new package as opposed to just parsing from [`sys.argv`](https://docs.python.org/3/library/sys.html#sys.argv) or using [`argparse`](https://docs.python.org/3/library/argparse.html), but I have to admit after trying it out of curiosity that `click` is wonderful to use.

```py
import click
import shared
from datetime import datetime

# ...

@click.group()
def cli(): pass

@cli.command(name='a')
@click.argument('completed_item', type=str)
def save_cli(completed_item: str):
    save_from_string([completed_item])

@cli.command(name='d')
@click.argument('number_of_days_ago', type=int)
def get_by_days(number_of_days_ago):
    completed_since = done_domain.days_ago(datetime.now(), number_of_days_ago)
    shared.display(get(completed_since))

@cli.command(name='w')
@click.argument('number_of_weeks_ago', type=int)
def get_by_weeks(number_of_weeks_ago):
    completed_since = done_domain.weeks_ago(datetime.now(), number_of_weeks_ago)
    shared.display(get(completed_since))

if __name__ == "__main__":
    cli()
```

The `@click.group()` decorator lets us define a mutually exclusive set of commands which are configured with the `@cli.command()` decorator.
In this case, we define 'a', 'd', and 'w' commands to '*a*dd' a completed item and retrieving items completed a number of '*d*ays' or '*w*eeks' ago.
The call to `cli()` under the `if __name__ == "__main__"` idiom handles parsing the incoming command-line arguments and dispatching to the appropriate function.

That's it!
We can run the program with commands like this:

```shell
(venv) $ python done.py a "complete python todo kata part 1"
(venv) $ python done.py d 0
[2020-10-11T10:33:03.696278] complete python todo kata part 1
```

## Wrapping Up

That wraps up the Python implementation of `done`.
Next we will cover `todo` and get a small look at reactive programming with `RxPy`.
