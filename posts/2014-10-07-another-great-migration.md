---
title: Another Great Migration
description: I migrated my blog from Heroku to a DigitalOcean box.
---

My blog has just finished going through yet another great migration today. For a while now, I've been stuck on a dated version of Ghost (Ghost 0.3.2) because I needed Postgres support to continue operating on Heroku. Unfortunately, they broke what little support they had for Postgres during the updates. Today, I moved my blog off of Heroku and onto [DigitalOcean](http://digitalocean.com/). 

I took advantage of the [GitHub Student Pack](https://education.github.com/pack/) to get both hosting and an SSL certificate through Namecheap. This, in combination with CloudFlare's new Universal SSL program, has resulted in my site being readily accessible over HTTPS. In fact, I've gone as far as to redirect users accessing the site in an insecure manner toward the secure version. So, all access to this site is now exlcusively over SSL.

I've gone through a lot of big changes with my personal site, especially those related to Heroku. Since I'm now on DigitalOcean and run the VPS myself, I should be encountering a lot fewer issues when I try to do things like update Ghost. I'm looking forward to smoother sailing in the future.
