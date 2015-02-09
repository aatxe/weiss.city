---
title: Going Static
description: After a year of running Ghost, I made a new static site with Hakyll.
---

It's been just shy of a year since I switched to Ghost. Today, I made a big jump away from it. I
made the decision to make my site static and to serve it via a 
[CDN](https://en.wikipedia.org/wiki/Content_delivery_network) (GitHub's, in particular). There were
two primary motivations behind this change. The first is that I was concerned about how I was 
managing the current site. The second is that I was concerned about the old design.

My concerns about management did not leave me alone. The point was iterated, admittedly with bias,
by [Zack Bloom at Eager.io](https://eager.io/blog/build-static-websites/). I was running my blog on
a small server, and it's likely that it wouldn't be able to take any serious traffic hits before it
crumbled. Further, I had to go through the effort of actually managing a Ghost installation. This 
meant keeping things up to date, and given my post frequency, I wasn't very good at that either. 
Unable to have a separate server for my website, I was actually sharing it with the server I was 
using for my IRC network. So, anything that impacted one was liable to impact the other. I wasn't 
satisfied with this at all. The site is now completely static and generated with Hakyll, and the 
only concern I have is writing, and then rebuilding the site when I make changes. That's just a 
short `./site build` away.

I also had some long-standing design concerns. I liked my old design, but as it aged, a lot of the
warts became more and more apparent. Despite my strive for minimalism, the focus was definitely 
more on flashiness than it was on content. There was a rough looking CSS transition to view the 
list of blog posts, and it caused hiccups in a few browsers. Some viewers of the site believed it
to be a bug! The blog posts themselves were much too wide, making them difficult to read, and the
glaringly bright background colors made the page hard to look at. I've taken a very different 
approach with this new site. I've retried minimalism, and this time it's not flat. My new design
aims to focus strictly on content. There's as few distractions as I could possibly muster. All the
content is still here, and now it's easier than ever to consume.
