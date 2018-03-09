One of the questions I've been thinking a lot about for my dissertation is:
How is our ability to solve problems affected by the tools we used to solve them?
I come at this question from the perspective of cumulative cultural evolution, which is the study of how and why our species is particularly skilled at passing on tools and other solutions to problems to be used and improved by future generations.

Unfortunately it's pretty hard to run experiments on processes that unfold over human generations, but what I've been focusing on recently is how we might be able to answer some of these questions by studying computer programmers. What's interesting about computer programmers is that you can study how people solve the same problems using different tools --- in this case different programming languages.

So in this data blitz what I'm going to tell you about is some survey data that we got from professional and academic programmers, asking them what languages they knew and their beliefs about programming.

But first I want to explain why you should care about programming languages.
There are hundreds of different programming languages, all designed for different purposes, but all are formally equivalent, meaning they can all implement the same algorithms.

Computer scientists think a lot about the differences between languages,
but as a psychologist what I'm interested in is the impact of different programming languages on individual computer scientists.

One thing I've learned in this department is that when you ask a question like "can we measure" the answer almost certainly is "yes" but the more interesting questions are "what should we predict and why does it matter."

I'm going to try to touch on these two hypotheses. The first is that functional languages are more transformative than other families or paradigms of programming language. The second is that languages with more paradigms are easier to master, the idea being that languages with many paradigms offer more in-roads to people learning them.

First I want to show you what languages were represented in the survey.
On the left I'm showing the top 20 languages in our sample,
and on the right I'm showing how representative this sample is of
programmers as a whole. I'm showing rank correlations between
language frequency in our survey with language frequency in a much
larger sample of around 35,000 developers conducted by Stack Overflow.
Languages above this line are overrepresented in our sample, and languages
under the line are underrepresented.

It's great that there are so many different languages out there, but
it makes it hard to do statistics, so rather than talking about individual
programming languages, I'm instead going to talk about language paradigms.

To introduce the idea of language paradigms, I'm going to talk about
an old programming language called Lisp, so here's a quote about Lisp
from a famous computer scientist:
Lisp has assisted a number of our most gifted fellow humans in thinking previously impossible thoughts.

Lisp was a programming language that was first used in doing AI research,
and it was known to be a different kind of animal compared to other types
of languages.

Lisp is an example of a functional programming language, but it's not the
only one, so here is a list of all functional programming languages at
least as defined by Wikipedia.

This looks nice and I naively thought I was just going to be able to compare these languages to other languages, but it turns out that no programming
language uses just one paradigm.

Here for instance are all the programming paradigms associated with python,
and it's messy because these are overlapping in some ways.

As I was exploring this data my first approach was to just compare major
paradigms, so here I'm comparing functional languages to imperative languages,
and you can see this interesting middle area for languages that have
both functional and imperative features.

The best way to understand the difference between imperative and functional
paradigms is to look at code, but for the sake of time, I'll describe the difference like this:

With an imperative language, it's like the imperative in English, where you are issuing commands that may or may not be followed or followed correctly.
With a functional language, what you are doing is declaring what you want
to happen, and you don't care as much about how it ends up happening, just
that the end result is what you expect it to be.

The other paradigm I'll talk about is object-oriented, so here I'm showing you languages that are functional, object-oriented, or both.

Object-oriented languages involve objects, of course, but specifically they
restrict the ways you can interact with those objects.

The first hypothesis I wanted to test was whether people who know functional languages think differently about how programming has affected them.

Here I'm showing agreement with the following statement broken down by the language paradigm of the person's top programming language:
"Learning to program has changed how I reason about things outside of coding"

Somewhat surprisingly, people who know a functional language as their first language do not report a difference in how they believe programming has influenced them relative to people who know an imperative language.

The same is true if you expand that to include all the languages that a person knows.

Comparing object-oriented to functional shows the same pattern.

This was surprising to me, but it is worth noting how high overall agreement is with this statement, although there are some people who clearly think programming does not influence cognition, the mean agreement is pretty high.

The second result I want to talk about is looking at the relationship between experience and proficiency. So we asked people how proficient they were in each language, and here I'm showing you the results for people who know python.

This learning curve is probably what you would expect, given that our measure here is bounded at 5, but it kind of makes sense, people who have used languages for longer report being more proficient in that language.

So how do these learning curves vary across different programming languages?

That's what I'm showing here: each of these lines is the learning curve for a programming language, taken from a hierarchical linear model.

The question I wanted to ask was: Can we predict anything about the shape of this learning curve from the paradigm of the language? What I really was curious about was whether languages with more paradigms were easier to master,
the idea being that multi-paradigm languages have more in-roads for learners.

It turns out the answer is "no", which I don't really feel like making too
much of, mostly because these measures are really coarse.

To wrap up:
Studying programmers is an interested test bed for questions about human problem solving.
Pithy intuitions from computer scientists need to be tested with experimental work.
Maybe the differences between programming languages are overblown.

