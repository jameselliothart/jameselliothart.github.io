title: Maps of DevOps: The Third Way
date: 05-29-20
author: James Hart
category: DevOps
tags: DevOps, MapsOfMeaning, TheThreeWays, TheThirdWayOfDevOps, ContinuousLearning
modified: 10-12-20
status: draft

## Welcome

Welcome to the third and final post in the Maps of DevOps series!
In [The First Way: Systems Thinking](maps-of-devops-the-first-way) we used a mock scenario of mailing letters to demonstrate the importance of completing a finished product (sealed and mailed letters) over accumulating inventory (folded paper).
We used this as an analogy for a Development organization delivering working software to production rather than letting it sit undeployed, and this necessarily meant that the strict boundary between programming applications (development) and deploying applications (operations) needed to be broken down.

This focus on creating value worked well when we knew what we were doing (in Known Territory), but in [The Second Way: Amplify Feedback Loops](maps-of-devops-the-second-way) we found it was insufficient once Anomaly appeared and we were consumed by Chaos in the Unknown.
To mitigate this, we needed to be able to proactively gather and respond to information about the validity of our assumptions and the effects of our efforts.

## A Return to the Beginning

We noted in the post on The First Way that the Development and Operations organizations are composed of smaller units just as the business is composed of Dev and Ops.
We used that observation to analyze the business as if it were composed of just those atomic units of Paper Folder and Letter Mailer.
To complete our analysis, we must return to that view of a full-scale enterprise with teams of Folders reporting up through various layers of management.

As we look up through these layers, those responsible for managing and directing work get further away from the work itself.
This shift is necessary so that higher levels of management can operate at higher levels of abstraction.
Their focus is on the broader company or even (maybe especially) industry trends and direction.
However, the business can become unhealthy if information - the lifeblood of any system - stops flowing between levels of the organization.

>A system is no better than its sensory organs
>
>-John Gall, *Systemantics*

In the same way that industry trends will leave a business behind if it fails to update its strategy, the internal processes the business follows will become outdated and inefficient if it does not maintain them.
Our world falls apart without constant diligence.

Managers have access to insight across a greater cross-section of the company or even of the industry.
And have influence over a greater amount of budget to allocate when necessary.
On the subject of budget, what would be even better is to give everyone some budget of time to improve.
This allows everyone to experiment and make micro-improvements while taking some pressure off management.
The alternative only creates the friction of micro-management and is inefficient for both parties.

Even better is to allocate time for everyone to be able to improve whatever piece of the process over which they have influence.

It is clear from this that any improvement in efficiency within or between the organizations must come from improvements in the workflows of the individuals involved.
As obvious as this may be, the higher levels of management with the most influence on whether and what investments are made to that end often have the least natural visibility into *where* those investments should be made.
It becomes difficult if not impossible to improve a process as we lose sight of what the process actually is.
This is the reason for the authors' insistence in *Leading the Transformation* that executives "walk the floor" to see day-to-day operations first-hand.

Often those operating in a particular workflow will already have ideas for improvement but even if not, they will at least have the most intimate knowledge of where the bottlenecks are.
With this information in hand, manager are better able to perform their role of removing barriers to allow people to work on improving what they can or to use their greater experience to offer solutions to the newly articulated problems.
Some changes will be out of scope for any one individual or team to implement, and this again is where managers can take the initiative to drive those changes armed with the knowledge that it will be a worthy investment.

Time is money.
Where to invest time to improve - maybe even money for commercial tooling or consulting.
There are various points of friction along the path from idea to product.
People doing the work will already have an idea of many of them and likely have ideas to lessen.
Or they may not, but if no one else knows the process, there is no chance of improvement.
Each person has a discretionary budget - even if it is only discretionary time - which can be used for improvements to existing processes.

From this thought experiment, it is obvious that any improvement in the efficiency of a department must have a corresponding improvement in the efficiency in its teams and ultimately the individuals within it.
This allows them to know what direction the company or industry are going, what budgetary constraints are in place, etc.
However, this disconnect also means that any action they take on their own is necessarily painted with a broad brush and lacks the necessary details to be effective.
It is through communication between the different levels of the organization that the details from lower levels are able to keep higher levels up to date with the day-to-day functioning of the organization's processes and the higher levels are able to keep lower levels informed about the company direction so that their efforts can be focused in the right place.


What is not obvious is how to bring about such an organizational change.
Many organizations find themselves plagued by inefficiencies and recognize they need to improve but do not have the insight to know where to begin, these inefficiencies having been the result of slow decay over time.
Suddenly, the idea to "do Agile" and "implement DevOps"
In ouroboric fashion, the end has become the beginning.

The question we ask now is: Who has the most information about what works well and what doesn't on the current folding techniques?
The answer, of course, is the people doing the folding - the folders themselves.
That is not really the question.
The question is who knows *what the process actually is in practice* as opposed to simply what someone *imagines* it to be.
People doing the work may have a blind spot in thinking something works well that doesn't at all (they don't know of another way).
If you want to find out what the process is, you have to ask the people doing the processing.
Gather their ideas for improvement, but this is also a chance for more senior leaders to give perspective and counsel.


## The Third Way: Continuous Learning

![The Third Way]({static}/images/maps-of-devops-third/TheThirdWay.png)

What we derive from this is that the fractal nature of the original map means that the first two ways (Systems Thinking and Amplify Feedback Loops) must be applied down the whole chain.
What is true at one level of analysis (enterprise) is true at all others (department and individual).
That is to say, each individual should try to improve their own workflow and gather feedback on what is working and what is not.
If everyone does just a little and shares it, it doesn't take long for those gains to compound.
What does it look like for an individual to embody Systems Thinking?
Fine-tuning their workflow.
Avoiding rework.
Automating repetitive or cumbersome tasks.
What does it look like for an individual to Amplify Feedback Loops?
Share that knowledge with others.
See if it works for them, what suggestions they have, what they've done.
The Third Way is the recognition that if this happens at every level, a culture of continuous learning and improvement has developed.
This can't be mandated from the top down, it must be encouraged from the ground up.


Ultimately, the sensory organs of an organization are the people living and working in it.
Thus each individual should be encouraged to make their own hypotheses, run experiments, and share the outcomes with others.

Internal wiki pages such as can be created with [Confluence] and [SharePoint], collaboration apps like [Slack] and [Microsoft Teams][Teams], and source code open to the company all help to facilitate this.

[Confluence]: https://www.atlassian.com/software/confluence
[SharePoint]: https://products.office.com/en-us/sharepoint/collaboration
[Slack]: https://slack.com/
[Teams]: https://products.office.com/en-us/microsoft-teams/group-chat-software

That said, not every change can be driven at the individual level - this is the important role that leadership serves in having a broader perspective.
However, that perspective must be kept healthy and up-to-date.

Without constant effort, systems fall apart of their own accord.
This is the unavoidable and continual march of entropic decay.

>Improving daily work is even more important than doing daily work
-Gene Kim, *The Phoenix Project*

## How To Use This Info

### Tools of the Trade

### Spotlight

## References

1. Leading the Transformation: Applying Agile and DevOps Principles at Scale, Gary Gruver, Tommy Mouser, Gene Kim (2015), IT Revolution Press (BOOK) - <https://www.amazon.com/Leading-Transformation-Applying-DevOps-Principles/dp/1942788010>
2. Systemantics: How Systems Work and Especially How They Fail, John Gall (1977), Quadrangle (BOOK) - <https://www.amazon.com/Systemantics-Systems-Work-Especially-They/dp/0812906748>
3. The Phoenix Project: A Novel about IT, DevOps, and Helping Your Business Win; Gene Kim, Kevin Behr, George Spafford (2013), IT Revolution Press (BOOK) - <https://www.amazon.com/Phoenix-Project-DevOps-Helping-Business/dp/0988262592>
4. Maps of Meaning: The Architecture of Belief, Jordan B. Peterson (1999), Routledge (BOOK) - <https://www.amazon.com/Maps-Meaning-Architecture-Jordan-Peterson/dp/0415922224>
