title: Todo Kata - FSharp Part 2
date: 10-06-20
author: James Hart
category: Tutorial
tags: Tutorial, FSharp, Todo, Development, Events

In Part 2 of the FSharp kata, we will implement the `todo` application.
This will allow us to keep track of a todo list, and it will utilize the `done` functionality we created in the previous post to record the items we complete.

Series Outline

1. [Intro]({static}/todo-kata-introduction)
2. [Part 1 - Done]({static}/todo-kata-fsharp-part-1)
3. [Part 2 - Todo]({static}/todo-kata-fsharp-part-2) (you are here)
4. [Part 3 - SQLite]({static}/todo-kata-fsharp-part-3)

Full source code is available [here](https://github.com/jameselliothart/FsTodo).

## Setup

As before, we create a console application and add it to the solution:

```shell
$ dotnet new console -n Todo -lang F#
$ dotnet sln add Todo/Todo.fsproj
```

## Domain.fs

As before, we start by defining the types of our domain.
We use a single case discriminated union for the `Todo` type and mark it `private` for use only within the `Todo` module.

```fsharp
module Domain

module Todo =
    type Todo = private Todo of index: int * item: string
```

Todos will be numbered with their index (this will allow us to reference the index when completing them), but we want the module only to expose the `TodoList` to prevent a caller from creating a nonsensical list.

```fsharp
    type TodoList =
    | Todos of Todo array
    | Nothing
```

Example display of todos:

> 0. Get something done
> 1. Do another thing

By making `Todo` `private` we avoid the possibility of callers creating a todo list like this:

```fsharp
let badTodoList = [|Todo.Todo (42, "these indices"); Todo.Todo (-7, "make"); Todo.Todo (0, "no sense")|]
```

We will also define events which the program should handle.
We want to be able to add a todo item, complete an item (mark it done), purge an item (remove without marking done), and keep track of any remaining items.
Though it may not be clear right now, doing this will give us a great amount of control over the behavior of the application.

```fsharp
    type TodoEvent =
    | TodoAddedEvent of string
    | TodosRemainingEvent of TodoList
    | TodosCompletedEvent of TodoList
    | TodosPurgedEvent of TodoList
```

With the domain types defined, we next give callers a way to actually create a Todo list and convenience functions to access the index and value of a `Todo` item.

```fsharp
    let create (todos: string[]) =
        match todos with
        | [||] -> Nothing
        | todos ->
            todos
            |> Array.indexed
            |> Array.map Todo
            |> Todos

    let value (Todo(_,item)) = item
    let index (Todo(i,_)) = i
```

The point of a todo list is to complete items off of it, so we define those functions next.
We will use these functions when handling the `TodoEvent`s defined above.

```fsharp
    let private partitionTodos idx todos =
        match todos with
        | Nothing -> (Nothing, Nothing)
        | Todos todos ->
            todos
            |> Array.partition (fun t -> index t = idx)
            |> fun (completed, remaining) -> (Todos completed, Todos remaining)

    let complete index todos =
        partitionTodos index todos
        |> fun (completed, remaining) -> [TodosCompletedEvent completed; TodosRemainingEvent remaining]

    let purge index todos =
        partitionTodos index todos
        |> fun (purged, remaining) -> [TodosPurgedEvent purged; TodosRemainingEvent remaining]
```

We encapsulate the partitioning logic for a completed or purged item in `partitionTodos`.
The only difference between the two functions `complete` and `purge` is whether a `TodosCompletedEvent` or a `TodosPurgedEvent` is returned.

Adding a reference to the `Done` project allows us to transform a `Todo` into a `CompletedItem`.
We will use this to save a todo we have completed as a `CompletedItem`.

```fsharp
open Done.Domain

// ...

    let toCompletedItems todos =
        match todos with
        | Todos todos ->
            todos
            |> Array.map (value >> Done.createDefault)
            |> Some
        | Nothing -> None
```

The composition operator `>>` allows us to get the value of the todo item with the `value` function and pass the result to `Done.createDefault` in one statement.

Finally, we define function types that we expect the consumers of `Todo` to implement.

```fsharp
type PrintTodo = Todo.TodoList -> unit
type GetTodos = unit -> Todo.TodoList
type AddTodo = string -> Result<unit,string>
type SaveTodos = Todo.TodoList -> Result<unit,string>
```

## Persistence.File.fs

The persistence logic is similar to what we already saw with `Done`.

```fsharp
module Persistence.File
open Domain
open System.IO

let writeAllLines path (s: string []) =
    File.WriteAllLines(path, s)

let addTodo path : AddTodo =
    fun todo ->
        if not (File.Exists path) then
            File.Create(path).Dispose()
            printfn "Created %s" (Path.GetFullPath path)
        File.ReadAllLines path
        |> Array.append [|todo|]
        |> writeAllLines path
        Ok ()

let saveTodos path : SaveTodos =
    fun todos ->
        let write = writeAllLines path
        match todos with
        | Todo.Nothing -> write [||]
        | Todo.Todos todos ->
            todos
            |> Array.map Todo.value
            |> write
        Ok ()

let getTodos path : GetTodos =
    fun () ->
        if (File.Exists path) then File.ReadAllLines path else [||]
        |> Todo.create
```

Notice as before the guards around the file existing (`File.Exists path`) and returning the function types we defined in the domain.
Notice also that we add todos to the top of the file rather than appending to the bottom.
From experience, we tend to work on and complete the most recently added item, so being able to consistently reference it with index 0 is a nice convenience.

## Config.fs

The configuration logic for `Todo` will be much more involved than for `Done`, but each piece will be small.
Let's dive in.

First we set a path to the file in which to track todo items and use that to create the `get`/`save`/`add` functions.

```fsharp
module Config
open System
open Domain
open Persistence.File

[<LiteralAttribute>]
let Path = "todo.txt"

let get = getTodos Path
let add = addTodo Path
let save = saveTodos Path
```

Next we create some helper functions for printing results.
Notice the use of our `Todo` helper functions `index` and `value`.

```fsharp
let printIfError = function
    | Error e -> printfn "%s" e
    | Ok _ -> ()

let printTodo : PrintTodo = function
    | Todo.Nothing -> printfn "No todos in %s" (IO.Path.GetFullPath Path)
    | Todo.Todos todos ->
        todos
        |> Array.iter (fun t -> printfn "%i. %s" (Todo.index t) (Todo.value t))
```

Now the exciting part.
We can use `Event`s to configure the response behavior to the `TodoEvent` types we created earlier.

```fsharp
let addedTodoEvent = new Event<string>()
addedTodoEvent.Publish |> Event.add (add >> printIfError)

let remainingTodosEvent = new Event<Todo.TodoList>()
remainingTodosEvent.Publish |> Event.add (save >> printIfError)

let completedTodosEvent = new Event<Todo.TodoList>()
completedTodosEvent.Publish |> Event.add (printTodo)
completedTodosEvent.Publish
|> Event.add (
    Todo.toCompletedItems >>
        Option.iter (Array.iter (Done.Config.save >> printIfError))
    )

let purgedTodosEvent = new Event<Todo.TodoList>()
purgedTodosEvent.Publish |> Event.add (printTodo)
```

`Event.add` configures the `Event` to run the given function (e.g. `printTodo` or the composition `save >> printIfError`) each time the given event (e.g. `completedTodosEvent`) is triggered.
Each event is also strongly typed with the kind of data it expects to receive when it is triggered (e.g. `string` or `Todo.TodoList`).

Once the syntax is clear, notice the difference between the `completedTodosEvent` and `purgedTodosEvent`: for a `purgedTodosEvent` we only register the `printTodo` function to display the item but *not* to save it with `Done.Config.save`.
Also notice how we do not need to know how the `Done.Config.save` function is doing its work.
When we switch `Done` to save to a SQLite database instead of a text file, this logic will not have to change at all!
This is much better than if we had to call the `Done.Persistence.File.saveCompletedItem` function directly.

Finally, we wire up a handler for the `TodoEvent`s by triggering the `Event`s we just defined with the `todo` payload (either a `string` or `Todo.TodoList`).

```fsharp
let handle = function
    | Todo.TodoAddedEvent todo -> addedTodoEvent.Trigger todo
    | Todo.TodosRemainingEvent todos -> remainingTodosEvent.Trigger todos
    | Todo.TodosCompletedEvent todos -> completedTodosEvent.Trigger todos
    | Todo.TodosPurgedEvent todos -> purgedTodosEvent.Trigger todos
```

Using a discriminated union for the `TodoEvent`s also means that if we add events in the future, the compiler will warn us that the `handle` function is not handling every case.
Try adding one now to see the effect.

## Program.fs

Now we are ready to put it all these pieces together in the final program.
Similar to `Done`, we will start with a helper function to encapsulate the index parsing logic when completing or purging todo items.

```fsharp
let tryParseIndex (data: string) =
    match Int32.TryParse(data) with
    | (true, i) -> Some i
    | (false, _) -> None
```

To parse the command line arguments, we will use a technique we have not used before called Active Patterns.
The logic is similar to how we parsed arguments for `Done`, but we have a few more possibilities to handle.

```fsharp
let helpMessage = "Valid commands are 'a <item>' and 'r <index>' or 'p <index>' for Add, Remove, or Purge (remove without saving)"

let (|Show|Add|Remove|Purge|Invalid|) (argv: string []) =
    match argv with
    | [||] -> Show
    | [|cmd;data|] ->
        match cmd.ToLowerInvariant() with
        | "a" -> Add data
        | "r" ->
            match tryParseIndex data with
            | Some i -> Remove i
            | None -> Invalid "Specify number index of item to Remove"
        | "p" ->
            match tryParseIndex data with
            | Some i -> Purge i
            | None -> Invalid "Specify number index of item to Purge"
        | _ -> Invalid helpMessage
    | _-> Invalid helpMessage
```

Parsing each possibility into a `Choice` type allows us to easily dispatch to the appropriate functions.

```fsharp
let showTodos () = get() |> printTodo

let dispatch = function
    | Show ->
        showTodos()
    | Add data ->
        Todo.TodoAddedEvent data |> handle
        showTodos()
    | Remove i ->
        get()
        |> Todo.complete i
        |> List.iter handle
    | Purge i ->
        get()
        |> Todo.purge i
        |> List.iter handle
    | Invalid msg -> printfn "%s" msg
```

Notice that we further delegate event handling to the `handle` function.

## Wrapping Up

That completes `Todo`!
You can test it out with commands like the below:

```shell
dotnet run a "my first todo"
0. my first todo
dotnet run a "my second todo"
0. my second todo
1. my first todo
dotnet run r 0
0. my second todo
dotnet run
0. my first todo
```

Be sure to check the todo.done.txt file to see the completed "my second todo" item appear!

In the next and final part of the FSharp series, we will circle back and see what it takes to save completed items to a SQLite database instead of a text file.
