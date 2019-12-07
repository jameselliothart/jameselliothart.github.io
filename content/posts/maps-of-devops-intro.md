title: Maps of DevOps: Introduction
date: 10-25-19
author: James Hart
category: DevOps
tags: DevOps, MapsOfMeaning, TheThreeWays
modified: 12-05-19

## Welcome

This post marks the beginning of a multi-part series
explaining the ideas of DevOps (that is, Development Operations).
The target audience is primarily those
unfamiliar with DevOps, and it is meant to
be friendly even to those without a technical background who seek to
understand the principles behind what has become something of a tech
buzzword. Perhaps even those already initiated may find a nice
insight or two.

## Definitions

To begin, we should first define some terms.
"Software development" is generally concerned with building applications which provide some business value - that is, which provide solutions to business problems.
On the other hand, "information-technology (IT) operations" is generally concerned with keeping an organization running smoothly by maintaining the existing applications and the infrastructure on which they rely while ensuring that changes to those assets do not cause service disruptions.
As you can see, these goals are not necessarily in alignment and could even be at odds.

Thus, [Wikipedia](https://en.wikipedia.org/wiki/DevOps) defines DevOps as such:

>DevOps is a set of practices that combines software development and information-technology operations which aims to shorten the systems development life cycle and provide continuous delivery with high software quality

In other words, DevOps is the attempt to have the best of both worlds: to delivery software quickly and often while maintaining a high level of system up time.
Throughout this series, we will explore the ideas which underlie this goal, and in describing the underlying pattern, we hope to reveal a broader applicability of these principles such as always comes when one extracts a general principle from a particular case.

## Motivation

>People don't have ideas. Ideas have people.  
-Carl Jung

I first encountered the principles of DevOps in a book called
_Leading the Transformation_<sup>1</sup> some years ago and have since
become rather passionate about the topic.
Sadly over that same period, I have also
seen its impenetrability to those
not expressly interested in seeking it out and have been
disheartened by the ease with which it is misunderstood.

Traditional introductions to DevOps typically begin with an
analogy to the [Lean manufacturing][Lean] movement of the 1980's, and
I have always found that somewhat
unsatisfying. This approach has the benefit of rooting
DevOps in a mature framework, but it runs the risk of
explaining a new concept in terms of another, equally foreign one.

Owing to a background in mathematics, I have long been interested in
the ways in which ideas or methods generalize. Thus
the congruence between these disparate fields suggested to me
an underlying idea common to both.

As I thought about these ideas, I noticed a similarity between
the figures (see below) used to express [The Three Ways of DevOps][ThreeWays]
<sup>2</sup> and those used to
describe the phenomenological landscape of human motivation in
_Maps of Meaning_<sup>3</sup> . Thus the title of this series, _Maps of DevOps_,
is a play on that book's title. This leads directly to my approach which
perhaps predictably is to show how the principles of DevOps can be
derived from the ideas presented there.

## Approach

>There is more wisdom in your body than in your deepest philosophy  
-Friedrich Nietzsche, _Thus Spoke Zarathustra_

One of the main theses of _Maps of Meaning_ is that there is a
universal story-like structure through which we understand the world.
Seen at a sufficiently abstract level, all belief systems fit within
this framework, thus the subtitle _The Architecture of Belief_.
My goal is to show that Gene Kim's Three Ways of DevOps (expressed succinctly
in his post on [The Three Ways][ThreeWays] and elaborated in detail in
_The DevOps Handbook_<sup>4</sup>) can naturally be understood within
the _Maps of Meaning_ framework.

I believe this approach makes these principles more
widely applicable as it emphasizes that DevOps is a culture -
a pattern of behavior - and not a particular set of tools and
buzzwords. Put another way, DevOps is an _idea_ that inhabits an
organization and the individuals within it.

I hope you will join me on this journey.

---

## Figures

The following are figures from _Maps of Meaning_ juxtaposed with Gene
Kim's diagrammatic representations of The Three Ways of DevOps.
The _Maps of Meaning_ figures have bizarre names owing to that book's
very different subject matter, but we will cover
that ground in due time.

### The Domain and Constituent Elements of the Known vs The First Way

<img src="{static}/images/maps-of-devops-intro/TheKnown.jpg" width="500">
![The First Way]({static}/images/maps-of-devops-intro/TheFirstWay.png)

### The Metamythological Cycle of the Way vs The Second Way

<img src="{static}/images/maps-of-devops-intro/TheCycle.jpg" width="500">
![The First Way]({static}/images/maps-of-devops-intro/TheSecondWay.png)

### Bounded Revolution vs The Third Way

<img src="{static}/images/maps-of-devops-intro/BoundedRevolution.jpg" width="500">
![The First Way]({static}/images/maps-of-devops-intro/TheThirdWay.png)

## References

[ThreeWays]: https://itrevolution.com/the-three-ways-principles-underpinning-devops/
[Lean]: https://www.leanproduction.com/

1. Leading the Transformation: Applying Agile and DevOps Principles at Scale, Gary Gruver, Tommy Mouser, Gene Kim (2015), IT Revolution Press (BOOK) - <https://www.amazon.com/Leading-Transformation-Applying-DevOps-Principles/dp/1942788010>
2. The Three Ways: The Principles Underpinning DevOps, Gene Kim (WEBSITE) - <https://itrevolution.com/the-three-ways-principles-underpinning-devops/>
3. Maps of Meaning: The Architecture of Belief, Jordan B. Peterson (1999), Routledge (BOOK) - <https://www.amazon.com/Maps-Meaning-Architecture-Jordan-Peterson/dp/0415922224>
4. The DevOps Handbook: How to Create World-Class Agility, Reliability, and Security in Technology Organizations; Gene Kim, Patrick Debois, John Willis, Jez Humble, John Allspaw (2016), IT Revolution Press (BOOK) - <https://www.amazon.com/DevOps-Handbook-World-Class-Reliability-Organizations/dp/1942788002>
