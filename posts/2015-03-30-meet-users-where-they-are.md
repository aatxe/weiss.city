---
title: Meet Them Where They Are 
description: I respond to a friend's post about tool choice with my own input on the matter.
---

This post was written in response to [hardmath123]()'s
[Use Imperfect Tools](http://hardmath123.github.io/use-imperfect-tools.html). While it's not
necessarily required to read it to get my input on the matter, I would recommend reading it first
in order to understand the context surrounding this post.

---------

The notion of getting caught up in selecting the right language, the right libraries, and the right
design is certainly not a foreign one to me. Indeed, I've had vast periods of virtually no
productivity as a result of my ongoing strive to design my API right the first time. From that
experience, I find it easy to agree with the call to use imperfect tools. However, I take issue
with the basis from which this conclusion is drawn, and the way in which it is drawn.

Use Imperfect Tools opens by saying, "As I look back on programs I've written, I almost always
notice that the most successful are the hacks." Afterward, hardmath123 rattles off a list of some
of what he describes as his best projects. While I think it's a fair observation that these
projects have probably been more appreciated than his other works, I think it's important to
consider why exactly that is. The implication here is that these projects are great because they
were made quickly. However, looking at the metric used to determine success, there's probably a
more likely explaination hiding. Referring to `alchemy`, hardmath123 calls it his "most successful
software projects if measured by total amount of happiness brought to users," and talking about
`jokebot`, a similar metric is brought up, "the most-forked of [his] projects". The thing that both
these metrics have in common is that they're metrics of attention garnered.

While I believe that having software be used while it's made plays an important role in its
development, I'd argue that even more central to the turnout of these projects is the ways in which
they appeal to their audience. In this case, the audience is one that favors simplicity and 
novelty. There's little introduction necessary for a game based around combining things, or for a 
bot that tells jokes, or for a Scratch MIDI player. By contrast, his most engineered project is 
`nearley`, a parsing library in JavaScript. It's certainly a novel project, but why has it amounted
to very little? I think it's all about the audience.

Hackathon culture (and its professional equivalent, start-up culture) is oriented around simple,
quick, and novel (especially the latter two!). Python and JavaScript are at the center of these
cultures, and the majority of those who would use hardmath123's software are thoroughly immersed. 
So, my answer to the question of why these projects were so popular isn't because they were good or
because there's something fundamentally effective about the strategy of hacking something up
quickly. Instead, it's because those projects had a place in the culture they're participating in. 
By contrast, `nearley` is interesting, but can't find such a place. After all, parsing is a
predominantly academic problem, and indeed, a project named for the parsing algorithm it uses 
([Earley parsing](https://en.wikipedia.org/wiki/Earley_parser)) is going to draw that sort of
attention. It got attention in that respect, shown by its 108 stars and 4 contributors. However,
nobody actually used it.

To answer the question of why, I'd suggest that it's because a parsing library in JavaScript isn't
something that anyone is really asking for, especially one selling itself by its algorithm. There
isn't a wealth of people implementing programming languages in JavaScript, nor is there a great
deal of academic work being done in JavaScript (at least as far as I know). So, of course, while it
interests people, it's not something they'd actually go out and *use*. It's a great project, but it
doesn't meet its potential users where they are, and that's an absolutely fatal design decision.

This actually has a lot of implications with respects to hardmath123's conclusion, too. I agree
that we can't ever choose the "right" tool because there likely isn't one. However, I think if you
want your project to actually be adopted, there's more to it than just picking the tooling "that
feels right." After all, this expression implies that the most important factor is that *you* feel
right in your choice of tools, but ultimately, if your metrics of success are oriented around
others, it's more important how others feel. In such a case, I'd put the number one priority as the
exact point of problem I identified with nearley. You should pick the tools to meet your users
where they're at. In some ways, this also means you have to pick your users. If you don't make
those choices, regardless of the attention you get, your library won't get used, and that's
incredibly frustrating.

In a lot of ways, I'm going through a similar experience with my Rust irc library right now. It's
my most starred project, and I've been working on it a lot. I've gotten a lot of good comments on
design, and I've seen it evolve over the past several months into something great. Yet, I can only
find but a small few projects using it that are not my own. It's been a great benefit for me to
make working versions early, and to let the library evolve with its usage, but I haven't been able
to attain the sort of usage that I'd like. It makes me wonder if perhaps I made a bad decision in
choosing to work on this in Rust, or if there's something that I could do better to spur adoption.
I certainly don't have the answers to that though.
