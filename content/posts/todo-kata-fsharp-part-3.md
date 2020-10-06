title: Todo Kata - FSharp Part 3
date: 10-07-20
author: James Hart
category: Tutorial
tags: Tutorial, FSharp, Todo, Development, SQLite, Dapper, ORM, SQL

Welcome to Part 3 of the FSharp Todo kata.
In this final part, we will revisit the `done` application and modify it to work with a SQLite database instead of a text file.

(Note: F# has a great feature called a [type provider](https://docs.microsoft.com/en-us/dotnet/fsharp/tutorials/type-providers/) which can give strongly typed compile-time access to a data source - including SQL databases.
However, the [SQLProvider](https://fsprojects.github.io/SQLProvider/) was surprisingly difficult to set up for SQLite, so we will opt for the lightweight `Dapper` ORM instead.)

Series Outline

1. [Intro]({static}/todo-kata-introduction)
2. [Part 1 - Done]({static}/todo-kata-fsharp-part-1)
3. [Part 2 - Todo]({static}/todo-kata-fsharp-part-2)
4. [Part 3 - SQLite]({static}/todo-kata-fsharp-part-3) (you are here)

Full source code is available [here](https://github.com/jameselliothart/FsTodo).

## Nuget Packages

To connect to a SQLite database, we will need to add the "Microsoft.Data.SQLite" nuget package to the `Done` project.
To simplify data access, we will use the micro-ORM (object-relational mapper) `Dapper`.
There is an FSharp friendly wrapper for `Dapper` called "FSharp.Data.Dapper".

```shell
dotnet add package FSharp.Data.Dapper
dotnet add package Microsoft.Data.SQLite
```

## Domain.fs

We will need to make a small modification to the `Domain` module for `Dapper` to be able to deserialize the SQLite rows into `CompletedItem`s.
Adding the `[<CLIMutable>]` attribute to the `CompletedItem` type accomplishes this.

```fsharp
    [<CLIMutable>] type CompletedItem = {CompletedOn: DateTime; Item: string}
```

Next we will add the Persistence.SQLite.fs file below the existing Persistence.File.fs to handle the SQLite persistence logic.

## Persistence.SQLite.fs

The [README](https://github.com/AlexTroshkin/fsharp-dapper) for `FSharp.Data.Dapper` has pretty good documentation for using it, though some of the connection setup was lacking.
A nice working example of using the package is [here](https://github.com/lmortimer/fsharp-dapper-sqlite-example).

A good portion of the code is boilerplate which can be found in either of those two examples.
At a high level, we have a `Connection` module for defining and creating connections to the SQLite database - either in memory or on disk - and we use that connection in the `Db` module.

```fsharp
// This is the path to the SQLite db file
[<Literal>]
let DataSource = "../done.db"

module Connection =
    let private connectionStringInMemory (dataSource : string) =
        sprintf "Data Source = %s; Mode = Memory; Cache = Shared;" dataSource

    let private connectionStringOnDisk (dataSource: string) =
        sprintf "Data Source = %s;" dataSource

    let Memory () = new SqliteConnection (connectionStringInMemory "MEMORY")
    let Disk () = new SqliteConnection (connectionStringOnDisk DataSource)

module Db =
    let private connection () = Connection.SqliteConnection (Connection.Disk())

    let private querySeqAsync<'R>    = querySeqAsync<'R> (connection)
    let private querySingleAsync<'R> = querySingleOptionAsync<'R> (connection)

    module Schema =
        let createTables = querySingleAsync<int> {
            script """
                CREATE TABLE IF NOT EXISTS CompletedItems (
                    Id INTEGER PRIMARY KEY,
                    CompletedOn DATETIME,
                    Item VARCHAR(255)
                )
                """
        }

        let initializeDiskDb () =
            if (IO.File.Exists DataSource) then ()
            else createTables |> Async.RunSynchronously |> ignore

    let saveCompletedItem : SaveCompletedItem =
        fun item ->
            querySingleAsync<int> {
            script "INSERT INTO CompletedItems (CompletedOn, Item) VALUES (@CompletedOn, @Item)"
            parameters (dict ["CompletedOn", box item.CompletedOn; "Item", box item.Item])
            } |> Async.RunSynchronously |> ignore
            Ok ()

    let getCompletedItems : GetCompletedItems =
        fun _ ->
            querySeqAsync<Done.CompletedItem> { script "SELECT CompletedOn, Item FROM CompletedItems" }
            |> Async.RunSynchronously
```

The non-boilerplate pieces to note are:

1. Creating the `CompletedItems` table in the `Schema` sub-module
   1. SQLite has a nice syntax for creating a table if it does not exist: `CREATE TABLE IF NOT EXISTS`
   2. SQLite does not actually have `DATETIME` or `VARCHAR` column types, but it will translate these to representations it does use ([docs](https://www.sqlite.org/datatype3.html))
2. The helper function `initializeDiskDb` for initializing the SQLite db on disk and creating the schema (just our single table)
3. The `saveCompletedItem` and `getCompletedItems` functions for inserting and retrieving completed items (similar to examples linked above)

## Config.fs

Now in `Config` we can switch out the definition of `save` and `get` without consumers knowing the difference!
If we wanted to make this configurable after compile time, we could try to read configuration from a file at runtime.
We will leave that as an exercise for the dedicated reader.

```fsharp
// let save = saveCompletedItem Path
// let get = getCompletedItems Path

let save =
    Db.Schema.initializeDiskDb ()
    Db.saveCompletedItem

let get =
    Db.Schema.initializeDiskDb ()
    Db.getCompletedItems
```

And that's it!
The `Program` for `Done` does not need to change nor does any configuration in `Todo` for completed items now to be written to our SQLite database.

## Wrapping Up

You may notice that we are retrieving all rows from the `CompletedItems` table to filter afterward.
This is a direct port of the file based approach we implemented originally.
We could instead use a `where` clause to filter the rows returned for us - that would be one of the nice advantages of a SQL-based approach!
However, we would need to make some more (albeit minor) changes for this, so we will leave it as an exercise as well.

## Series Wrap Up

This completes the Todo kata for FSharp.
We have seen a nice demonstration of the features for FSharp including some simple domain modeling, reading/writing text files, and even interacting with a SQL database.
The next installment will cover a [Python](https://www.python.org/) implementation which will go a little faster, partly because of the nature of the language and partly because we will already be familiar with the application from this series.

P.S. If you were wondering how to run the compiled application directly (instead of with `dotnet run`), you can find the executables in the `bin` directory:

```shell
./Done/bin/Debug/netcoreapp3.1/Done d 0
./Todo/bin/Debug/netcoreapp3.1/Todo a "run the compiled app directly"
```

Nice.
