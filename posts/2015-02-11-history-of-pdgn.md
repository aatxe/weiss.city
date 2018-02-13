---
title: A Brief History of Pdgn
description: As its founder, I detail the history of the PdgnCo IRC network, a self-proclaimed bastion of democratic autonomism on the web.
---

This is a cross-post from the [PdgnCo Community Blog](http://blog.pdgn.co). It was published on
February 11th, 2015, and can also be found 
[here](http://blog.pdgn.co/general/2015/02/11/history-of-pdgn.html).

---------

The idea for Pdgn first came in June of 2014. For reasons that I can't recall, I was drawn to
searching for a domain. I didn't really have a purpose for it. I was just poking around to see if
anything cool was available. I stumbled upon the domain `pdgn.co`, and I thought it was concise,
oddly charming, and easily pronouncable (as the English word, pigeon). As I said, I didn't have a
purpose, and so, I didn't purchase the domain. I did, however, keep it in my mind.

Around this time, my productivity levels had plummetted immensely. I had begun to loathe working in
Java, and my constant attempts to take on incredibly large projects were going nowhere. I'd been
trying to learn Haskell on-and-off for roughly a year, and I'd fallen completely in love with
functional programming as a paradigm. In another IRC network that I call home
([FyreChat](http://www.fyrechat.net)), I'd also been exposed to Rust. I didn't really think of
myself as capable of programming in a systems language, but I liked that Rust had many of the nice
idioms that I had come to appreciate from my struggles with Haskell. So, I wanted to jump ship from
Java, and I was looking at both Rust and Haskell. However, I didn't have any ideas of reasonable
things to work on once I did. That changed in July.

In July of that year, as the next step in a big push to distance myself from Google, I had decided
that I wanted to run a small, privacy-first email service and that I wanted to write all the
software myself. I had some experience with IRC as a protocol, and I figured that the email
protocols couldn't be that much worse. So, I bought the domain. I tried to make the decision of
whether I wanted to write it in Rust or Haskell. Rust would be hard because I was scared of the
idea of having to manage memory myself, and Haskell would be hard because I was still struggling to
understand how to work with state and the real world. Ultimately, at the urging of some friends, I 
decided that I would write the service in Rust. I also decided that I may as well combine it with a
privacy-first chat service as well. My goal was to incorporate the best privacy practices available
for existing protocols, and thus I wasn't going to invent a new chat client or a new email protocol
and so on.

Still, even with an idea, my motivation was pretty low. I looked at the task of learning a new
language as an impossibly high barrier, and much like previous projects, I worried that it was too
large of a task for me to finish. Having already assured some of my friends that it would happen, I
continually put off the idea and then put it off again. By the time summer ended, I had made no
progress at all on my goal, and had made no effort to learn Rust. My friend 
[Jacob](http://www.jacobedelman.com) bugged me countless times about writing the service because he
wanted a new email address himself, but even that had done nothing to drive progress. 

I was about to start University, and I stopped to look back at what I had done on the summer. When
I did, I was saddened to see that I had done just about nothing and I wondered why. I wrote a 
[blog post](http://aaronweiss.us/posts/2014-08-26-summers-gone.html) about it, and decided that I
needed to do things differently. So when I started school, I decided that I was going to learn
Rust by working with something familiar before doing anything unfamiliar. Dungeons and Dragons, 5th
Edition was released around this time, and I wanted to play it with people over IRC. So, I thought
that it would be a good opportunity to write an IRC bot to run the game. There was a clear path to
starting off small, and a clear path for it to be more complicated. So, it seemed like a great
first project. I split the project into two parts, [the IRC library](https://github.com/aatxe/irc) 
and [the bot](https://github.com/aatxe/dnd) itself, and I set off to learn Rust.

From September 10th on, I was throwing all the free time that I could muster into this bot. Bored
in my data structures class, I started using that time to work on it, too. Once I got over the hump
of struggling with the language (and especially lifetimes), I started making good progress. I
knocked out a lot of the features I had planned, and by the end of October, I found myself looking
mostly at some of the harder stuff. I wanted to implement a battle map, and that required an
associated web server component. I was worried about how hard it was going to be, and so I went
looking elsewhere for places to continue my learning of Rust. Eventually, it occurred to me that a
part of my goal had been to run an IRC server in Rust. I obviously couldn't write it immediately,
but I could definitely launch a server with an existing IRCd and make it a long-term project. 

With that, on October 27th, 2014, Pdgn as an IRC network was born. I reached out to my high school
friends Jacob and Alok, and asked them to join. We had run an online computer science competition
earlier in the year ([HSCTF](http://hsctf.com)), and I had missed being able to interact with them
over IRC. In what can only be described as perfect timing, [PicoCTF](https://picoctf.com) had also
started that day. This meant that Jacob and Alok, both participating in it, were immediately in
contact with many of the participants of HSCTF who spent their time in our IRC channel on Mibbit
during and after the competition. The channel had all but completely disappated by this time, and
so I hadn't really heard from any of them. They both took this as an opportunity to recruit, and
they convinced a number of old friends (and former HSCTF participants) to join the network. Slowly,
but surely, we garnered a small userbase.

Seeing all the progress that was made in a day, I immediately started work on our own set of IRC
services written in Rust. I didn't have a lot of knowledge about how they were implemented, and so,
I assumed that they were just normal bots. For anyone looking to not replicate my mistake, services
are almost always implemented as a separate server linked to the main hub. Regardless, I carried on
blindly. Within two days, nickname and channel registration was implemented. The services were
starting to shape up, and I was excited to be putting them to immediate use. One issue I
encountered along the way was that the user mode marking that you're identified (`+R`) is actually
only able to be set by a server. I didn't have a server component to my IRC library, and I knew
that that would be a huge investment. So, I modified the `m_samode` module for InspIRCd to allow
operators to set the mode `+R` with the `SAMODE` command. I was the only server operator, and so I
figured that it wouldn't be much of an issue. With that, the bot was able to mark people as being
identified.

A few days later, I found myself joining a discussion on the Mozilla IRC about IRC libraries in 
Rust. As far as I knew, my library was the only one that built on the latest Rust, as many of the
previous developers had abandoned their work. While my library worked fine for my purposes, others
were critical of my use of callbacks to define IRC functionality. Another developer who had 
previously worked on an IRC library pointed me in the direction of a better design. They
recommended that I take advantage of iterators because of all of the sugar associated with them in
Rust. So, 
[on November 2nd](https://github.com/aatxe/irc/tree/91aa5bcc6f5a2380bb2348274432b34d86b03ace), I 
did a large refactor of my IRC library. I dropped a lot of the excess, and implemented an
iterator-based design. From there, I started down a long path of improving the library. I wrote a
collection of utility functions that evolved into a utility wrapper to the server objects. I
rewrote tons of unit tests. I added SSL support, and working user tracking with access level
support. I dealt with crate name squatting on the Rust [crate repository](https://crates.io), and
eventually claimed the crate name `irc`. I made the library thread-safe, and fully specification
compliant. The library grew into something substantial, and I was happy for it.

Both bots weathered the storm of the redesign, and while the Dungeons and Dragons bot had 
stagnated, the services bot continued to grow and expand. At Jacob's urging, I implemented the game
[Resistance](https://en.wikipedia.org/wiki/The_Resistance_(game)) as an optional feature for it. I
also added a counter to track stupid mistakes, and a full-featured voting-based administration
tool. The idea was to use the bot (named Pidgey, and declared our mascot) to allow fully democratic
channel administration. We found out quickly that this was less than desirable. People started lots
of non-sense votes, and rarely did votes ever pass. Eventually, I retired the democracy feature,
and Pidgey went back to just managing channel and nickname registration (with Resistance and derps
on the side). The server kept on running.

After a few months, it became more apparent that running an IRC network on a single server was less
than desirable. I wasn't able to do updates of any kind, and maintenance meant that everything was
completely inaccessible. So, I set out to make Pdgn into an actual network instead. The first step
was to [move my site off of Ghost](http://aaronweiss.us/posts/2015-02-03-going-static.html), which 
was being hosted on the same server as the IRC network. Once that was done, I got two new, smaller
servers for the network. One in San Fransisco, and one in New York. I had to decide on names, and
I wanted an overarching theme for them. So, I settled on 
[genera](http://dictionary.reference.com/browse/genus) of pigeons as an appropriate name. The
hub server in New York was named [Columba](https://en.wikipedia.org/wiki/Columba_(genus)), after
the genus of typical Old World pigeons. The server in San Fransisco was named 
[Raphus](https://en.wikipedia.org/wiki/Dodo), after the genus of the dodo (which is, to some
people's suprise including my own, a type of pigeon!). 


On February 3rd, 2015, both of the new servers went live, and the original server that housed Pdgn 
was taken down. With this, the original services bot was also retired. 
[On February 9th](https://github.com/Pdgn/site/tree/fa533c0f976470211ca41f689c45001dd270ee67), I 
released an official [pdgn.co site](http://pdgn.co), and then 
[on February 10th](https://github.com/Pdgn/blog/tree/919e50226dd6e68e69ef85dda4c6ce73e72a6075), I
released the official [pdgn.co community blog](http://blog.pdgn.co). This brings us to today,
February 11th, where I have now, for the first time, documented the history of the network. It's
hard to say where the future will take us, but I hope to expand the network with more servers and
more people. This is really only the beginning.
