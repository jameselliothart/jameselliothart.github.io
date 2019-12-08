title: Maps of DevOps: The Second Way
date: 12-08-19
author: James Hart
category: DevOps
tags: DevOps, MapsOfMeaning, TheThreeWays, TheSecondWayOfDevOps, Feedback, APM

## Anomaly

We now turn our discussion to Anomaly: new information that deviates from the expected.
It is most useful to think of it as arising from a sea of irrelevant background information which always surrounds us.

This new information can be either positive or negative - that is, it can be either a **Tool** or an **Obstacle**.
A Tool aids us in reaching the stated objective while an Obstacle hinders our ability to move forward.

![Anomaly](./Anomaly.png)

At the risk of having stated the obvious, note that many new technologies are labeled "tools" but may not fit this definition.
One cannot "do DevOps" simply by implementing DevOps "tools" - they must address the needs at hand.
This is a common management mistake and has lead to the idea that "DevOps is dead" having become simply a marketing gimmick.

With the definition aside, we now note that a sufficiently large anomaly can transform Known into Unknown.
You experience this when something so unexpected happens that your current pursuits or methods or even your current state come into question.

To illustrate, suppose you are folding papers in our letter mailing scenario and the table catches on fire.
You are now in a very different place with very different motivations than you were before!
Your previous map has disintegrated, and this new information must be taken into account and reintegrated into a new one (presumably around putting out the fire and only sometime afterwards resuming paper folding).

![Regeneration](./Regeneration.jpg)

## Anomalies in Mailing Letters

We will now consider some less extreme anomalies that could occur.

1. Letters have gotten too big for the envelopes
2. Envelope seals do not hold and open in transit

In the first case, the sealer can communicate this back to the folder.
Notice that the issue is somewhat relieved by the Single Piece Flow delivery model - we get feedback after only one letter is too large thus minimizing rework.
In the Batch strategy, every letter would need to be refolded.
Alternatively, we need bigger envelopes, and it is better to know on the first one rather than having already ordered enough envelopes for the entire batch of paper.

In the second case, this may mean the letter is never delivered, and we only find out a week later through receiving an angry call from the intended recipient.
The questions arise:

* How often is the envelope seal not holding?
* Where in the process is the issue occurring?
* When did the issue start?

The answers to these question may determine whether it was a freak accident or a fundamental and fatal flaw in our process.
Worse still, if we cannot even determine the answers to these questions, we have been plunged into the Unknown.

The key to mitigating the first case was the quick feedback we received, and that is exactly what we need now.
Perhaps we could monitor the initial seal quality on new envelopes and track letters as they travel to report back on seal status.

## The Second Way: Amplify Feedback Loops

![The Second Way](./TheSecondWay.png)

What we have discovered is the need for The Second Way.
Fundamentally, we are trying to answer two questions:

1. Do we know where we are (What Is)?
2. Are we achieving What Should Be?

In other words:

1. Are our past hypotheses still valid?
2. Was our latest business hypothesis correct?

Is the system still functioning the way it should, and if it is not, can we easily look into its current state?
Did the change we deployed create the value we expected?
When we create a new screen in our application, can we tell if anyone is actually using it or not?

Tools of the trade here include Application Performance Monitoring (APM) solutions such as [New Relic][NR] and [Dynatrace] or the Azure service [Application Insights][AppInsights] as well as Network Monitoring tools such as [SolarWinds] and [Splunk].

[NR]: https://newrelic.com/
[Dynatrace]: https://www.dynatrace.com/
[SolarWinds]: https://www.solarwinds.com/
[Splunk]: https://www.splunk.com/
[AppInsights]: https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview

Service monitoring and observability is a huge topic, so we can only scratch the surface here.
However, the key point to keep in mind is that what makes these "tools" into Tools is their ability to help us keep the Unknown at bay by giving us feedback in the form of checking our assumptions about the current state of the system and validating that the changes we make create value.

## How To Use This Info

### Tools of the Trade

### Spotlight: APM

>APM strives to detect and diagnose complex application performance problems to maintain an expected level of service  
-[Wikipedia](https://en.wikipedia.org/wiki/Application_performance_management)

![APM](./APM.png)

An APM "\[translates\] IT metrics into business meaning (value)" writes [Larry Dragich](https://www.apmdigest.com/the-anatomy-of-apm-4-foundational-elements-to-a-successful-strategy).
