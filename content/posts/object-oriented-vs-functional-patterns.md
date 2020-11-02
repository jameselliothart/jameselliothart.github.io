title: Object Oriented vs Functional Patterns
date: 10-31-20
author: James Hart
category: Development
tags: Development, Opinion, Patterns, C#, F#, Python
status: draft

There is a strange antagonism between object-oriented and functional programming paradigms.
The image below from Scott Wlaschin's excellent [talk](https://www.youtube.com/watch?v=E8I19uA-wGY) is often used.
I saw the meme before watching the talk (or even knowing the talk existed), and in the context of the talk it is actually a joke.
It doesn't actually address the question.
You could make the same image and replace "Functions" for "Objects" and claim victory - there are no OO patterns, just objects.
I often see it taken out of context in a way that obscures rather than reveals an insight.

The more subtle point is that these patterns or principles are much easier to implement - or even trivial - in a functional paradigm.


<img src="{static}/images/oo-vs-fp-patterns/patterns.gif" width="500">

- dotnet
  - C# (https://www.c-sharpcorner.com/article/strategy-design-pattern-using-c-sharp/)
  - F#
- python
  - oo (https://www.tutorialspoint.com/python_design_patterns/python_design_patterns_strategy.htm)
  - [stop writing classes](https://www.youtube.com/watch?v=o9pEzgHorH0) - especially if only two methods, one of which is `__init__`
  - functions are first-class objects, so could use function strategies, but we can do better
- for simple cases like these, could just use lambdas, but imagine some more complex computation
- these could be derided as overly simplistic examples
- could say this looks more like "class-oriented" rather than object-oriented programming, and I would agree - this often seems to be what critics of OO programming are really getting at. The fact that OO-first languages make this an easy trap to fall into is an "iron-man" (as opposed to a straw-man) of the point.
