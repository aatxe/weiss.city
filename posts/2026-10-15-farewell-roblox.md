---
title: Farewell, Roblox 
description: In this post, I reflect on my experiences at Roblox working on Luau, and contextualize my decision to move on to something new.
---

I joined Roblox coming out of grad school in 2022 to work on [Luau](https://luau.org). Today is my last day. When I joined Roblox, the company was in an explosive period of growth and change.
Luau had been open sourced about half a year prior, and a new director with significant programming languages expertise had been brought on to lead the project. The
Luau team had acquired a tremendous talent in the late [Alan Jeffrey](https://www.asaj.org/), whose presence was actually what brought me to Roblox as a fellow ex-academic
and programming languages creative. I was hired to bring more type system design (and critically) implementation expertise to the team. Four and
a half years later, the New Type Solver[^1] has been out a year, and, while the launch was rocky, it is by most accounts a pretty good product now.[^2] 

In that time, I have grown a lot as a person, an engineer, and a leader, and I'm very appreciative of the opportunities working on Luau has afforded me. I've learned a great deal
about working on and managing larger open source projects, and even more about building a good programming language in a corporate environment. And the team has grown
and changed a lot too: [the project's founder moved on](https://zeux.io/2023/11/28/it-is-time/), Alan passed away, the other engineers on the type system (besides me and
[Andy](https://andyfriesen.com)) left, and we hired a bunch of new, wonderful people to work on the type system and the language at large. We've had to collectively sort through a great
deal of change in management and instability in direction, and have largely stabilized on a very reasonable heading: building Luau into a pluralistic gradually-typed language focused
on giving programmers lots of choices about how they want to approach their game or other software.

I'm very happy for this direction, and I believe wholeheartedly in the language and the project as a whole, but I also have hit some of my own limits here. Around RDC last year, our manager left
and from then until May, we went through three management transitions and three complete changes-of-direction for the team. We've only fairly recently reached a reasonable degree of stability
with the incredibly fortunate hiring of [Fil Pizlo](https://www.filpizlo.com/) to manage the team. Throughout that instability and owing to the fact that we had invested heavily in a small number
of big, long-term projects, I pushed very hard for us to work on smaller, better scoped projects that had immediate impact on our customers. This is where the team's investment in
[Lute](https://github.com/luau-lang/lute), [Mandolin](https://github.com/luau-lang/mandolin), [the website overhaul](https://github.com/luau-lang/site), and other developer tooling arose from.
There have been both great successes in that process, as well as plenty of failures. With that in mind, and combined with the overarching narrative of our field today, I am frankly burnt out and in need of change.

Anyone who knows me probably can tell that I'm a very emotional person, and that I've invested a lot into my work and the community (sometimes to a detriment even). While I think that investment
is broadly a strength, it's also made it very hard for me to experience the leadership instabilities, the shifting priorities of a fairly indecisive company, and the sustained awareness of all the
things still wrong in Luau. Some of this would get better in time, but leaving feels like the only option really in my control today. It's hard to let go since I've truly loved working on Luau and truly loved
working with the open source community around Roblox, even through many of the difficulties of doing so, but I'm very much in need of a reset for my overall well-being.

To everyone who has worked with me on this journey to make Luau the best language it can be, whether that be folks here at Roblox or the many, many passionate folks in open source: thank you for your contributions
and for your passions! It has meant so, so much to me to do this work over the past five years. I'm sorry that I am unable to stay on for the rest of it, but I believe I'm leaving the project better than I found it,
and the future for Luau seems very bright! I will be rooting for all of you!

[^1]: I consider this to be something of a brand name for our type inference engine, and that's why it is written as a proper noun. I've never heard anyone else refer to a 
type inference algorithm as a type solver, so I generally characterize the term as an [Andy](https://andyfriesen.com/)-ism-turned-brand-name.
[^2]: I think personally I'm still unsure of how to be proud of my own work, and so it's hard for me to look at all the problems I know are still outstanding and say that, but I have 
to believe the many people who are kind enough to share with me the positive experiences they've had using it.
