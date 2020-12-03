title: Refactoring for Purity
date: 11-18-20
author: James Hart
category: Development
tags: Development, Refactoring, FunctionalProgramming, Python
status: draft

Worse, what if the class is reading from and writing to databases which are difficult to replicate locally?



[source](https://github.com/jameselliothart/blog-code/tree/master/RefactoringForPurity)

Say you have a class like this:

```py
from pathlib import Path

class Greeter():
    def __init__(self, path):
        self._path = Path(path)

    def get_greetings(self):
        path = self._path.joinpath('greetings.txt')
        return path.read_text().split('\n')

    def run(self):
        planet_greetings = [f'{greeting} earth!' for greeting in self.get_greetings()]  # imagine this is complex logic
        path = self._path.joinpath('planet_greetings.txt')
        path.write_text('\n'.join(planet_greetings))
```

There is a change in the requirement for the greeting - the `planet_greetings = ` line in `run` - and no unit tests exist.
Imagining this line as a stand-in for some complex business logic, we need to test this change thoroughly and preferably with an automated unit test.
Imagine also that the class is reading from and writing to databases which we cannot replicate locally instead of interacting with local files.

The code as currently structured will be difficult to test to say the least.
We could [monkey patch](https://www.geeksforgeeks.org/monkey-patching-in-python-dynamic-behavior/) `get_greetings` to return some hard-coded values, but we would still need to inspect the result of `run` - the updated file or database - to see the result of our greeting logic.
Suppose we instead make this small refactoring:

```py
    def run(self):
        greetings = self.get_greetings()
        planet_greetings = [f'{greeting} earth!' for greeting in greetings]  # imagine this is complex logic
        path = self._path.joinpath('planet_greetings.txt')
        path.write_text('\n'.join(planet_greetings))
```

Now it is clear that the (complex) logic for `planet_greetings` is a [pure function](https://en.wikipedia.org/wiki/Pure_function).
This makes it easy to move into its own method:

```py
    @staticmethod
    def greet_planet(greetings):
        return [f'{greeting} earth!' for greeting in greetings]

    def run(self):
        greetings = self.get_greetings()
        planet_greetings = self.greet_planet(greetings)
        path = self._path.joinpath('planet_greetings.txt')
        path.write_text('\n'.join(planet_greetings))
```

For our purposes, this would be enough.
The business logic encapsulated in a pure function is now easy to unit test, so we can be more confident in our changes.
For the sake of illustration, let's go one step further:

```py
    def run(self):
        greetings = self.get_greetings()  # impure
        planet_greetings = self.greet_planet(greetings)  # pure
        self.save_greetings(planet_greetings)  # impure

    def save_greetings(self, greetings):
        path = self._path.joinpath('planet_greetings.txt')
        path.write_text('\n'.join(greetings))
```

Now we can see that the `run` method is an example of an [impureim sandwich](https://blog.ploeh.dk/2020/03/02/impureim-sandwich/).
In production code, it may not be as easy to see and the refactoring may not be as clean, but it is surprisingly often possible to apply this.


FLIP MATTRESS