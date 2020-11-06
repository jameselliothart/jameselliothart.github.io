title: Write Documentation in Markdown
date: 11-01-20
author: James Hart
category: Productivity
tags: Markdown, Pandoc, Tips, Productivity, Documentation
modified: 11-06-20

I think the dictum ["working software over comprehensive documentation"](https://agilemanifesto.org/) is very much undervalued in the enterprise.
However, there are times when documentation is quite necessary, and the methods we have for creating and maintaining it seem underdeveloped compared to our patterns for software.
The two challenges I have encountered most often are related to document versioning and the requirement for different formats of the same document.
In this post, I will expand on these problems and explore the title's recommendation.

## Versioning

Often the documentation we write is "living" - meaning it has to be maintained and updated over time to remain accurate.
However, this creates a slew of problems: How do we tell there is a new version? How do we know what changed? How do we know which version we have (or if it's the latest)?
The "solutions" I have most often seen are one or some combination of the following:

- Update the document name (e.g. doc_v1.docx, doc_v2.docx, etc.)
- Keep a version table in the document listing changes by author (and hope everyone updates this meaningfully)
- Use the document you were most recently emailed

These are as suboptimal as they are common.
What is surprising to me is that this is no less common among "technical" folks (e.g. software engineers) even though this exact problem has been solved for decades by [version control systems](https://en.wikipedia.org/wiki/Version_control) - which they probably use every day!

One company I worked for did make it to this realization, but we checked documents in as Word .docx files.
This was a good start, but formats of [WYSIWYG](https://en.wikipedia.org/wiki/WYSIWYG) editors (e.g. MS Word) make it very difficult to compare differences between file versions.
It is much easier to do a diff on text.

So why not do just that?
Write documentation in plaintext so that it can easily be stored in version control and thus gain all the benefits of doing so.
Of course, this might be more of another problem than a solution because it is almost never acceptable to present documentation in plaintext.
Imagine emailing official installation documentation as a .txt file!
However, this is really just a restatement of a problem we already identified: the need to have different formats of the same document, i.e. plaintext for version control, Word for end-user consumption, etc.

That is where [Markdown](https://www.markdownguide.org/getting-started/) (or [reStructuredText](https://www.writethedocs.org/guide/writing/reStructuredText/)) comes in.
Markdown allows us to add formatting elements to plaintext documents that can then be "compiled" to different formats.
In the next section, we will see how to do that with [pandoc](https://pandoc.org/).

## Variable Formats

Above we noted the desirability of writing documents in plaintext for version control while being able to present them in another format when required.
That consideration aside, the consumers of our documentation will already sometimes want or require it to be in different formats.

For example, copying text from Word or PDF documents will often carry formatting that is undesirable when pasting into other programs.
This is especially true when copying code in which case we would often actually prefer a plaintext document.
Alternatively, we may need to post part of our document to an internal wiki page (e.g. on SharePoint or Confluence) which has clashing formatting.
In this case, the wiki may already accept Markdown or give the option to edit the html source directly.

The combination of Markdown and pandoc can handle all of these cases (and more).
Once a document is written in Markdown, pandoc can convert it to (probably) any other format you might require.
"Pan-doc" comes from "pan-" meaning [all](https://www.merriam-webster.com/dictionary/pan) and "-document" after all.

If the final product needs to be a Word doc (most often the case for me), `pandoc -s -o MyDocument.docx MyDocument.md`.
If you need an html fragment to put into a wiki, `pandoc -o MyDocument.html MyDocument.md`.
The [documentation](https://pandoc.org/demos.html) has an extensive list of demos.

## Summary

1. Write documents in [Markdown](https://www.markdownguide.org/getting-started/)
   1. Pro-tip: write each sentence on its own line to make diffs more effective
2. [Version control](https://git-scm.com/) them
3. Convert as needed with [pandoc](https://pandoc.org/)
4. Profit

That's it.
You will thank me later.
