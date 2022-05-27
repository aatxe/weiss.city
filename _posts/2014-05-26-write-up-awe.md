---
title: 'Write-Up: awe'
description: In this writeup from the first HSCTF, I walk through the solution to my unsolved reconnaissance problem entitled 'awe'.
published: true
---

As part of HSCTF, there was a reconnaissance problem entitled awe. The given text for the problem was simple, and generally unhelpful as it was part of a series on some of our organizers. The text read "My name is Aaron Weiss." The problem was, as you could probably tell, about me.

The task of finding the flag was broken up into two pairs of `#, word` in two different places on the web. The hope was that when all four parts (two pairs from two sources) were found, they could be assembled into the flag using the order from the numbers accompanying the words. The format was designed purposefully to look suspicious and to draw attention across the web. The problem never intended for people to just guess random pieces of information.

The first pair was found in two GitHub repositories, [dc-anchor](https://github.com/aatxe/dc-anchor/commit/fdf059c097e1f2fbe5d988dd2fca74e1e984857b#L13) and [juicebot](https://github.com/aatxe/juicebot/commit/31c8e338d1b939f79c413ded9bae31b0a8013e10#L2). As something of a gotcha, the first repository had another [commit](https://github.com/aatxe/dc-anchor/commit/6591b8d28ce6f6c3c626babdcf1c9b357182a317#L13) wherein I had removed a flag from an old CTF we ran. Many teams got caught up thinking this was important, even despite the note I added saying it wasn't. This probably helped to add to the confusion, as this old flag was found by a great many participants.

The other two pieces were found on the [FyreChat IRC Network](http://www.fyrechat.net). The first one was found in the channel description of the channel `#awe`. This could be found by using the command `/msg ChanServ LIST *` and reading through the results. It was actually the first result. Then, upon joining the channel, the topic was set with the remaining piece. Many teams found this last part by doing `/whois awe` and joining all of the channels I was in. This approach cheated them out of the channel description, and ultimately complicated the problem. 

Once all the parts were found, the key could then be formed. Any combination that featured the words in the proper order, regardless of separators, would be considered correct. Valid keys could've been `aweiskindanew` or `awe is kinda new` or anything else to that effect. That would all suffice.

Many teams got caught up in searching for particular information about me and making guesses based on that information. This resulted in a variety of funny submissions that were all generally unrelated to me. Many of these submissions were related to an Iraq war veteran and a video wherein he challenged New York's SAFE Act. Others were related to a seemingly insignificant secondary character in a book entitled the Trikon Deception. Here's a sampling of some of the submissions: `2nd Amendment`, `awe is really cool`, `SAFE Act`, `My right is greater than your dead`, and `Gun Control`. 

Based on the history of the problem, it should be rather apparent that it was a lot harder than it originally seemed to me as the author. The problem was originally set to be a 300 point problem, but was raised to a 400 point problem prior to the competition. Half way through the competition, the problem remained unsolved and so it was raised to 500 points. Ultimately, the problem was not solved during the competition.




