title: Todo Kata - Introduction
date: 10-04-20
author: James Hart
category: Tutorial
tags: Tutorial, FSharp, Todo, Development

This post marks the introduction for a [code kata](https://en.wikipedia.org/wiki/Kata_(programming)) series in which we will develop a command-line todo list manager in a few different languages.
Each kata will assume a working development environment (I will be working in [VS Code](https://code.visualstudio.com/) on Ubuntu 18.04) and basic familiarity with the syntax of the language involved.
The end result will be two programs, `todo` and `done`, to track a current todo list and to keep track of completed items by date.
The final API will look something like this:

```shell
$ todo a "create a todo manager"
$ todo a "create a completed item manager"
$ todo
1. create a completed item manager
2. create a todo manager
$ todo r 0
$ todo
0. create a todo manager
$ done d 0
[2020-10-05T13:23:56] create a completed item manager
$ done w 1
[2020-10-02T12:40:12] draft tutorial
[2020-10-05T13:23:56] create a completed item manager
```

The commands do the following:

1. `todo a` - Add items to the todo list
2. `todo` - List todo items
3. `todo r` - Remove (complete) an item by index
4. `done d` - Retrieve items completed a number of days ago
5. `done w` - Retrieve items completed a number of weeks ago

(Note: Technically `done` is already a shell keyword.)

We will implement this first by just saving to text files, but we will see that we can design the solution to be flexible enough to switch to saving completed items in a SQLite database with relative ease.
The curious may read a little more about the motivation for this below.
Otherwise, continue to the [first kata](todo-kata-fsharp-part-1) covering the [F#](https://fsharp.org/) implementation.

## Motivation

I have worked in environments that sometimes require a large amount of task switching for some time.
This is generally the result of high priority requests coming in with unpredictable frequency as may be familiar to anyone working on a team that supports other teams or customers.
To keep track of what I needed to do, I would typically record tasks in a [Notepad++](https://notepad-plus-plus.org/) tab (without even saving to a file) and delete a task line when I finished.
This suited my needs well enough until I started working on a team that followed a number of [Agile ceremonies](https://www.atlassian.com/agile/scrum/ceremonies) - daily stand-ups and sprint retrospectives in particular.

It wasn't enough simply to track what I had to do because I also needed to be able to report on what I had done yesterday and contribute meaningfully about the events of the previous two-week sprint.
Now, there are a number of lightweight todo list applications already out there, but the security setup at work meant that I had very limited ability to install software on my machine.
To address these issues, I wrote a PowerShell module [pstodo](https://github.com/jameselliothart/pstodo) consisting of a single file so that I could copy/paste the entire contents from GitHub onto my machine and having a working tool.
The implementation was quick and dirty, but it continues to serve its purpose to today.

More recently, I started to play with rewriting `pstodo` and realized that while the implementation was relatively straightforward, it was non-trivial enough to serve as a good demonstration of the features of the language in which it was implemented.
Since I have always found tutorials a great way to learn some aspect of a language, I thought I would create a series of my own partly to serve as a personal reference but also in case anyone else might find them useful.

## Series Outline

1. Intro (you are here)
2. F# Series
    1. [Part 1 - Done](todo-kata-fsharp-part-1)
    2. [Part 2 - Todo](todo-kata-fsharp-part-2)
    3. [Part 3 - SQLite](todo-kata-fsharp-part-3)
3. Python Series
    1. [Part 1 - Done](todo-kata-python-part-1)
    2. [Part 2 - Todo](todo-kata-python-part-2)
    3. [Part 3 - SQLite](todo-kata-python-part-3)
