title: Todo Kata - Python Part 2
date: 10-28-20
author: James Hart
category: Tutorial
tags: Tutorial, Python, Todo, Development, mypy, click, RxPY, ReactiveProgramming

In Part 2 of the Python kata, we will implement the `todo` application.
This will allow us to keep track of a todo list, and it will utilize the `done` functionality we created in the previous post to record the items we complete.

Series Outline

1. [Intro](todo-kata-introduction)
2. F# Series
    1. [Part 1 - Done](todo-kata-fsharp-part-1)
    2. [Part 2 - Todo](todo-kata-fsharp-part-2)
    3. [Part 3 - SQLite](todo-kata-fsharp-part-3)
3. Python Series
    1. [Part 1 - Done](todo-kata-python-part-1)
    2. Part 2 - Todo (you are here)
    3. [Part 3 - SQLite](todo-kata-python-part-3)

Full source code is available [here](https://github.com/jameselliothart/PyTodo).

## todo_domain.py

We will start by defining the domain logic of `todo` in `todo_domain.py`.
Creation of todo items should be controlled such that we always have a well ordered list of items.
Python is not known for its strict encapsulation, but we can make use of nested classes and the leading `_` convention to signal our intent to mark something as "private".

```py
from typing import List, Tuple, NamedTuple, Any

class Todos():
    class _Todo(NamedTuple):
        idx : int
        item : str

        def __str__(self) -> str:
            return f'{self.idx}. {self.item}'

    @staticmethod
    def create(todos: List[str]) -> List[_Todo]:
        return [Todos._Todo(index, item) for index, item in enumerate(todos)]
```

The static `create` method will be the entry point for creating a todo list from a list of strings.
The `_Todo` class itself represents a single todo item - its index in the list and the item itself - so we also give it a `__str__` representation which will show when we print to the screen.

Next we will import `Subject`s from RxPY and define the events to which the `todo` application will respond.

```py
from rx.subject import Subject
# ...

class TodosEvent(NamedTuple):
    args: Any

class TodosAddedEvent(TodosEvent):
    args: str

class TodosAddedEventHandler(Subject): pass

class TodosRemainingEvent(TodosEvent):
    args: List[Todos._Todo]

class TodosRemainingEventHandler(Subject): pass

class TodosCompletedEvent(TodosEvent):
    args: List[Todos._Todo]

class TodosCompletedEventHandler(Subject): pass

class TodosPurgedEvent(TodosEvent):
    args: List[Todos._Todo]

class TodosPurgedEventHandler(Subject): pass
```

We have to type the base `TodosEvent` with `args: Any` since the type of `args` varies between the inherited events (`str` for `TodosAddedEvent` and `List[Todos._Todo]` for the others).
These events hold the data to which our application will respond (via the `Handler`s), and the `EventHandler`s themselves just wrap the underlying `Subject` class.
This is for added readability when we wire up the `Handler`s with response logic later.

To finish off this file, we will define functions corresponding the actions of our domain: adding, completing, and purging todo items.

```py
def add_todo(existing: List[str], todo: str) -> List[str]:
    new_todos = [todo]
    new_todos.extend(existing)
    return new_todos

def _partition_todos(todos: List[Todos._Todo], index: int) -> Tuple[List[Todos._Todo], List[Todos._Todo]]:
    partitioned: List[Todos._Todo] = []
    remaining: List[Todos._Todo] = []
    for todo in todos: (partitioned if todo.idx == index else remaining).append(todo)
    return partitioned, remaining

def complete_todos(todos: List[Todos._Todo], index: int) -> List[TodosEvent]:
    completed, remaining = _partition_todos(todos, index)
    return [TodosCompletedEvent(completed), TodosRemainingEvent(remaining)]

def purge_todos(todos: List[Todos._Todo], index: int) -> List[TodosEvent]:
    purged, remaining = _partition_todos(todos, index)
    return [TodosPurgedEvent(purged), TodosRemainingEvent(remaining)]
```

The `add_todo` function is pretty straightforward: just add the new todo item to the top of the list.

The common logic of partitioning the todo list is in the (implicitly private) function `_partition_todos`.
The partition occurs by dynamically appending each todo item to one list or the other depending on if the item's index matches the one by which we are partitioning.
It might take a second to see how that works, but there is no magic.
(Note we have to define `partitioned` and `remaining` on separate lines (rather than simply `partitioned, remaining = [], []`) to make mypy happy.)

Using `_partition_todos`, we can differentiate between `purge_todos` and `complete_todos` by returning different event types for the partitioned items (`TodosPurgedEvent` vs `TodosCompletedEvent`).

With the domain defined, we can move on to the file persistence implementation.

## todo_file.py

In `todo_file.py`, we define the path to the todo.txt file and functions to `add`, `save`, and `get` todo items from it.

```py
import file
import todo_domain as td
from typing import List

PATH = 'todo.txt'

def add(path: str, todo: str):
    existing = file.read_all_lines(path)
    updated = td.add_todo(existing, todo)
    file.write_all_lines(path, updated)

def save(path: str, todos: List[td.Todos._Todo]):
    file.write_all_lines(path, [todo.item for todo in todos])

def get(path: str) -> List[td.Todos._Todo]:
    return td.Todos.create(file.read_all_lines(path))
```

The actual work of interacting with the file is delegated to functions defined in [Part 1](todo-kata-python-part-1).
The creation of the todo list from the individual lines in the file is executed by the static `Todos.create` method we defined in the domain as promised.

Finally, we will create `todo.py` to hold the configuration and command-line interface of the application.

## todo.py

We start with the imports we will need and the configuration of the `get`, `add`, and `save` functions the `todo` application will use.

```py
import done
import shared
import todo_file
import click
import todo_domain as td
from functools import partial, singledispatch

def get(): return todo_file.get(todo_file.PATH)

add = partial(todo_file.add, todo_file.PATH)
save = partial(todo_file.save, todo_file.PATH)
```

The configured functions simply have the path to todo.txt "baked in" via partial application.

With those functions defined, we can set the behavior of the application via the `EventHandler`s.

```py
added = td.TodosAddedEventHandler()
added.subscribe(add)

remaining = td.TodosRemainingEventHandler()
remaining.subscribe(save)

completed = td.TodosCompletedEventHandler()
completed.subscribe(lambda todos: done.save_from_string([todo.item for todo in todos]))
completed.subscribe(lambda todos: shared.display(todos))

purged = td.TodosPurgedEventHandler()
purged.subscribe(lambda todos: shared.display(todos))
```

Each `EventHandler` will respond to the `args` of its corresponding `TodoEvent` by passing `args` to the `subscribe`d function.
For completed items, we delegate to the previously defined `done.save_from_string` function.
Notice the implementation details of `save_from_string` are hidden from us.
This means we can change the `done` implementation in the next section to interact with a SQLite database rather than a text file without needing to make any modifications here.

With the `EventHandler`s wired up, we can define a handler to dispatch to them based on the particular `TodoEvent` using the `singledispatch` decorator from `functools`.

```py
@singledispatch
def handle(event):
    print(f'Unregistered event type: [{type(event)}]')

# Python 3.7+ can use the type annotation of the first argument
@handle.register(td.TodosAddedEvent)
def _handle_added(event: td.TodosAddedEvent):
    added.on_next(event.args)

@handle.register(td.TodosRemainingEvent)
def _handle_remaining(event: td.TodosRemainingEvent):
    remaining.on_next(event.args)

@handle.register(td.TodosCompletedEvent)
def _handle_completed(event: td.TodosCompletedEvent):
    completed.on_next(event.args)

@handle.register(td.TodosPurgedEvent)
def _handle_purged(event: td.TodosPurgedEvent):
    purged.on_next(event.args)
```

The names of the `register`ed functions do not matter (calling `handle` will dispatch to them based on argument type), so it is normally customary to name them all `_`.
However, mypy complains about this, so we give them different "private" names with leading `_` instead.

The `handle` function itself defines the default behavior when there is no corresponding registered function - in this case we just print that the type is unregistered for debugging purposes.
Otherwise, each registered function simply dispatches each `TodoEvent` to the corresponding `EventHandler` we defined above (the `on_next` function passes its argument on to the `subscribe`d functions).

Also note that starting in [Python 3.7](https://docs.python.org/3.7/library/functools.html#functools.singledispatch), we can leave the type out of the `register` decorator (i.e. `@handle.register`) to infer the type from the annotation of the first argument to the decorated function. (I am running Python 3.6.9 locally as noted at the series start and spent some time frustrated before I realized this.)

Last but not least, we can define the cli behavior of the application with `click`.

```py
@click.group()
def cli(): pass

@cli.command(name='s')
def show():
    shared.display(get())

@cli.command(name='a')
@click.argument('todo_item', type=str)
def add_cli(todo_item: str):
    handle(td.TodosAddedEvent(todo_item))

@cli.command(name='r')
@click.argument('index_to_remove', type=int)
def get_by_days(index_to_remove):
    events = td.complete_todos(get(), index_to_remove)
    for event in events: handle(event)

@cli.command(name='p')
@click.argument('index_to_purge', type=int)
def get_by_weeks(index_to_purge):
    events = td.purge_todos(get(), index_to_purge)
    for event in events: handle(event)

if __name__ == "__main__":
    cli()
```

This should look familiar from the previous part covering `done`.
The difference here is that we are producing events which we pass to the `handle` dispatcher function we just defined.
This gives us a great amount of flexibility in defining the behavior of the application without having to change its interface.

## Wrapping Up

As before, we can test out the application at the command line and see the integration with `done`:

```shell
(venv) $ python todo.py a "first todo item"
(venv) $ python todo.py a "second todo item"
(venv) $ python todo.py s
0. second todo item
1. first todo item
(venv) $ python todo.py r 1
1. first todo item
(venv) $ python done.py d 0
[2020-10-28T07:39:27.567047] first todo item
```

In the [next and final part](todo-kata-python-part-3) of the Python series, we will change the `done` implementation to work with SQLite rather than a text file.
See you then!
