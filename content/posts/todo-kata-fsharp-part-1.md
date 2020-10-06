title: Todo Kata - FSharp Part 1
date: 10-05-20
author: James Hart
category: Tutorial
tags: Tutorial, FSharp, Todo, Development

Welcome to Part 1 of the FSharp kata to implement to todo list manager discussed in the [introduction]({static}/todo-kata-introduction).
In this post, we will implement the `done` command.
We start with `done` rather than `todo` because `todo` will actually depend on functionality in `done` to save completed items whereas `done` has no dependencies.

Series Outline

1. [Intro]({static}/todo-kata-introduction)
2. [Part 1 - Done]({static}/todo-kata-fsharp-part-1) (you are here)
3. [Part 2 - Todo]({static}/todo-kata-fsharp-part-2)
4. [Part 3 - SQLite]({static}/todo-kata-fsharp-part-3)

Full source code is available [here](https://github.com/jameselliothart/FsTodo).

## Setup

We start by setting up our [.NET Core](https://dotnet.microsoft.com/download) console app, adding it to a solution, and opening VS Code:

```shell
$ mkdir FsTodo
$ cd FsTodo
$ dotnet new console -n Done -lang F#
$ dotnet new sln
$ dotnet sln add Done/Done.fsproj
$ code .
```

Next we will create the Domain of our application which will hold all of the logic for creating and working with completed items - the main subjects of the `done` command.
Add the Domain.fs file above Program.fs.

## Domain.fs

The `done` command should allow us to record completed items and query for them later by how long ago they were completed.
First, we create a module defining the type and some functions for creating and printing.
Putting the `CompletedItem` type and the functions for working with it in a module with `module Done =` allows us to more easily group and discover related operations.
Basically, it allows for "dot-driven development" as we get intellisense with `Done.` for `Done.create`, `Done.CompletedItem`, etc.

```fsharp
module Done.Domain
open System

module Done =

    type CompletedItem = {CompletedOn: DateTime; Item: string}

    let create (completedOn: DateTime) (item: string) =
        {CompletedOn = completedOn; Item = item}

    let createDefault item = item |> create DateTime.Now

    let toString item =
        sprintf "[%s] %s" (item.CompletedOn.ToString("s")) item.Item
```

The `toString` function is how we will serialize a completed item to a text file, so it will have a representation like "[2020-10-02T17:53:47] hello world".

We will also need a way to turn that text representation back into a `CompletedItem` (deserialize it) to work with it again within our domain logic.
Add a reference to `open System.Text.RegularExpressions` to access `Regex` so that we can parse the date from the completed item.

The `tryParse` function will return a `CompletedItem option` because the file could potentially be "corrupted" - someone could tamper with the file and put in something like "[this is not a date] ugh" or even just leave out the "[]" like "there is no date here".
`Some item` gives us a type-safe way of saying we got something rather than `None`.

```fsharp
open System.Text.RegularExpressions

// ...

    let tryParse (s: string) =
        let result =
            try
                s
                |> fun s -> Regex.Match(s, "^\[(?<completedOn>.*)\] (?<item>.*)")
                |> fun m -> if m.Success then Some m.Groups else None
                |> Option.map (
                    fun g -> (
                                (g |> Seq.filter (fun x -> x.Name = "completedOn") |> Seq.exactlyOne).Value,
                                (g |> Seq.filter (fun x -> x.Name = "item") |> Seq.exactlyOne).Value
                            )
                    )
                |> Option.map (fun (date, item) -> (DateTime.TryParse(date), item))
                |> Option.map (fun ((success, date), item) -> if success then Some (create date item) else None)
            with
            | :? ArgumentException -> None
        match result with
        | Some(Some(completedItem)) -> Some completedItem
        | _ -> None
```

There is a lot going on there just to deal with potentially bad entries in the file.
If we were confident the file will always be clean, we could use something like the below.
However, we would still want to return a `CompletedItem option` as the cleanest way to handle `DateTime.TryParse`.

```fsharp
    let tryParse (s: string) =
        let result =
            s
            |> fun s -> Regex.Match(s, "^\[(?<completedOn>.*)\] (?<item>.*)")
            |> fun m -> (
                            (m.Groups |> Seq.filter (fun x -> x.Name = "completedOn") |> Seq.exactlyOne).Value,
                            (m.Groups |> Seq.filter (fun x -> x.Name = "item") |> Seq.exactlyOne).Value
                        )
            |> fun (date, item) -> (DateTime.TryParse(date), item)
            |> fun ((success, date), item) -> if success then Some (create date item) else None
```

The whole point of storing our completed items is to be able to query for ones completed some time ago, so we can tackle that next.
First we will define some helper functions at the top of the file to make working with dates easier:

```fsharp
let private startOfDay (date: DateTime) = date.Date
let private daysAgo (date: DateTime) days = date.AddDays(-days) |> startOfDay
let private startOfWeek (date: DateTime) = date.AddDays(-(float)date.DayOfWeek) |> startOfDay
let private weeksAgo (date: DateTime) weeks = date.AddDays(-7.0 * weeks) |> startOfWeek |> startOfDay
```

Notice they are marked as `private` because we will only use them within this module and do not want to clutter the public API.

We can represent the period back we would like to query (days or weeks) nicely as a discriminated union:

```fsharp
type Period =
| Days of float
| Weeks of float
```

This combined with our helper functions earlier makes the `completedSince` function pretty straightforward:

```fsharp
    let completedSince period (item: CompletedItem) =
        let since =
            match period with
            | Days x -> daysAgo DateTime.Now x
            | Weeks x -> weeksAgo DateTime.Now x
        since < item.CompletedOn
```

Finally, at the bottom of the file we will define some types that we expect our persistence logic to implement.
This tells us we expect to be able to:

1. Save a completed item and get a `Result` back either of success or an error message
2. Retrieve all completed items (which we can then filter by date with `completedSince`)

```fsharp
type SaveCompletedItem = Done.CompletedItem -> Result<unit,string>
type GetCompletedItems = unit -> Done.CompletedItem seq
```

As already mentioned, we will first provide implementations of these types to read/write from a file.
Later, we will see how we can switch to using a SQLite database with minimal changes outside of implementing the SQLite logic.

## Persistence.File.fs

Beneath Domain.fs, we create Persistence.File.fs.
There is not much to implementing file persistence - the entire implementation is below.

```fsharp
module Done.Persistence.File
open Done.Domain
open System.IO

[<LiteralAttribute>]
let FilePath = "todo.done.txt"

let saveCompletedItem path : SaveCompletedItem =
    fun item ->
        use writer = File.AppendText path
        item |> Done.toString |> writer.WriteLine
        Ok ()

let getCompletedItems path : GetCompletedItems =
    fun _ ->
        if (File.Exists path) then File.ReadAllLines path else [||]
        |> Array.map Done.tryParse
        |> Array.filter Option.isSome
        |> Array.map (fun i -> i.Value)
        |> Array.toSeq
```

There are a couple things to call out.
First, notice these functions take a `path` and return `SaveCompletedItem` or `GetCompletedItems` - that is, they return functions.
We will see after this how we can partially apply the path to configure these functions for use.
Second, it is generally bad practice to extract the value from an option like in `Array.map (fun i -> i.Value)` since an exception will be thrown in the case of `None`.
However, we filter immediately before on `Option.isSome`, so this is ok to make the return value work out.
Also, note we are careful to handle the case of the file not existing yet by checking `if (File.Exists path)` - it is easy to forget edge cases like this!
`File.AppendText` will create the file if it does not exist, so no need for defensive coding there.

## Config.fs

The Config file is where we will configure the persistence logic for use by our application and others.
This way, consumers do not need to worry about the implementation details of how data is stored.
We will see how useful this is when we switch to using a SQLite database and only need to update this file instead of scouring the code for references to the `Persistence.File` functions.

```fsharp
module Done.Config
open Persistence.File

let save = saveCompletedItem FilePath
let get = getCompletedItems FilePath
```

## Program.fs

We are finally ready to code the actual application.
The final usages will look like the below:

```shell
$ done a "this is a completed item"
$ done d 1
$ done w 1
```

These commands show how to add a completed item, get items completed since yesterday, and get items completed since last week.
It will be useful to keep this API in mind as we develop the logic.

We start by defining the types of commands our application can respond to: it can either `Add` a new completed item or it can `Query` for them by how long ago they were completed (some number of `Period`s ago - either "d" or "w").
(Hopefully CQRS practitioners can forgive making a `Query` a type of `Command`!)

```fsharp
type Command =
| Add of string
| Query of Period
```

Next, because the arguments we receive from the command line will be strings, we will define a helper method to parse the period for a `Query` (we will need to be sure not to use this when we receive an `Add` command):

```fsharp
let tryParsePeriod (period: string) amount =
    match period.ToLowerInvariant() with
    | "d" -> Some (Query (Days amount))
    | "w" -> Some (Query (Weeks amount))
    | _ -> None
```

The heavily nested `Some (Query (Days amount))` may look intimidating at first glance.
Breaking it down, we can see it reflects:

1. We may have received invalid input - use an Option (`Some`/`None`) to indicate whether a valid `Period` is requested
2. We mentioned earlier this will only be used for a `Query` which expects a `Period` (either `Days` or `Weeks`)
3. The "d" or "w" specifies whether the `amount` is in `Days` or `Weeks` (`amount` is inferred to be a `float`)

With that helper function defined, we can try to parse the entire command line argument array:

```fsharp
let tryParseArgs (argv: string []) =
    match argv with
    | [|command;param|] ->
        if command = "a" then Some (Add param) else
            match Double.TryParse(param) with
            | (true, x) -> tryParsePeriod command x
            | (false, _) -> None
    | [|period|] -> tryParsePeriod period 0.0
    | _ -> None
```

We pattern match on the `string array` of incoming arguments:

1. If we received two arguments (`[|command;param|]`)
   1. If the first argument is "a" then we are adding a new completed item (the `param`): `if command = "a" then Some (Add param)`
   2. Otherwise, assume it is a query
      1. Then the `param` needs to be parsed to a `Double`
      2. If the `param` is valid, then try to determine the `Period` (using the helper we defined above)
2. If we received one argument, assume it is a query for the current `Day` or `Week` (this is a nice convenience)
3. Otherwise, we have received bad arguments, so return `None`

The use of pattern matching and helper methods makes this kind of deeply nested logic more readable.

Now we'll define a smaller helper function to display any errors if we receive them or nothing if not (we have actually not even defined any errors at this point).
The implicit argument is a `Result<'a,string>`.

```fsharp
let printIfError = function
    | Error e -> printfn "%s" e
    | Ok _ -> ()
```

And the final bit of code before the `main` function is a help message if we received bad arguments and the dispatching logic to run the actual code requested:

```fsharp
open Done.Domain
open Done.Config

// ...

[<Literal>]
let HelpMessage =
    "Usage: `done d <number>` or `done w <number>` to get items done <number> of days/weeks ago or add with `done a`"

let dispatch argv =
    let cmd = tryParseArgs argv
    match cmd with
    | Some c ->
        match c with
        | Query p ->
            get()
            |> Seq.filter (Done.completedSince p)
            |> Seq.iter (Done.toString >> printfn "%s")
        | Add s -> s |> Done.createDefault |> save |> printIfError
    | None -> printfn "%s" HelpMessage
```

We can see in the use of `get()` and `save` (with a reference to `open Done.Config`) that we can change the definitions of those functions (e.g. to use SQLite instead of a text file) without the program knowing any difference.

## Wrapping Up

That completes the `done` implementation.
We can test it out with the commands below:

```shell
$ dotnet run a "complete our first todo"
$ dotnet run d
[2020-10-05T21:38:56] complete our first todo
```

Nice.
The next part of the series will cover creating the `todo` application.
