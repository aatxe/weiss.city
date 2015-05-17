---
title: Recreating Creatures
description: In this series, I'll detail my process in recreating Creatures, a classic alife game.
---

For years now, I've wanted to make my own artifical life game in the spirit of 
[Creatures](https://en.wikipedia.org/wiki/Creatures_(artificial_life_series)). I spent a lot of time
imagining exactly what it'd be like, but when I was younger, I always imagined the creatures
essentially behaving based on pseudorandom models. I hadn't any exposure to more advanced artifical
intelligence techniques, and so I didn't even imagine that they'd be something more complex than
that. 

I even made an attempt of sorts in 2013, entitled [critters](https://github.com/aatxe/critters). It
didn't go anywhere though. My goal from the get-go was to focus on extensibility. I wanted all of
the aspects of the world around the creatures to be easily programmable in JavaScript. I had very
little real experience with C++, but I was working with my friend
[Peter Atashian](https://github.com/retep998). I got stuck trying to understand how to embed
[V8](https://code.google.com/p/v8/) and how to best apply it for the sort of extensibility I was
imagining. Unfamiliar with the language and the tools, I gave up quickly.

Fast forward to today, I've been programming in Rust for going on a year. I'm an active participant
in academia now, and I'm getting some experience reading research papers. While my focus has been
in programming languages, my friend [Jacob Edelman](http://www.jacobedelman.com) has been working
with neural networks for a while now. So, I'm trying again, but with a different approach this time.
Rather than focus on getting all of the logistical engine-type stuff out of the way first, I'm
focusing on the artificial life aspect. My plan is to build a backend first, and then create a small
command-line interface using [ncurses](https://www.gnu.org/software/ncurses/ncurses.html). Once I've
reached that point, I'll work on developing it into a full 2D game. I'll also be writing a series of
blog posts about the process of working on this game. My hope in doing so is to document in detail
the decisions made and difficulties encountered along the way. I'll collect a full list of all the
posts at the end of this post. You can find the project
[on GitHub](https://github.com/aatxe/life-sim/).

Posts in series:
None
