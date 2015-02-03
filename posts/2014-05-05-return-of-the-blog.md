---
title: Return of the Blog
description: After a series of technical difficulties with Heroku, I was able to upgrade Ghost.
---

I recently went through the process of moving my site from the master branch of Ghost to the stable branch. I would've done this earlier, but I was afraid that something would break in the process. Of course, it did. My site was offline for some time while I struggled to set up Ghost on Heroku once more, but I did it. The blog portion was missing all of the content for a longer period of time, but I've just now finished migrating that over. Since I had so much trouble, I'd like to document what I had to do here to get Ghost to work on Heroku. 

Firstly, I had to set up the database to connect using `pg	`. This admittedly wasn't hard as it essentially just requires adding `pg` as a dependency in `package.json`. From there, I set up my configuration file to read all of the information from environment variables to make it easier to change without redeploying. The full configuration file can be seen [here](https://github.com/aatxe/Ghost/blob/stable/config.js).

Next, I had to add a Procfile for Heroku. After all, it needs to know what exactly it has to run. This wasn't a difficult process though. I simply put `web: node index.js --production` as this is a production site. 

Finally, I wanted to have the production assets generated with grunt during the deployment process. This meant a few things. I had to find a buildpack that would run a grunt task (which wasn't hard) and then I had to add the grunt task to run. The buildpack is available on [GitHub](https://github.com/mbuchetics/heroku-buildpack-nodejs-grunt). The task I created was just to perform `prod`. In order to get this to run properly however, I had to move several of the dependencies from `devDependencies` to `dependencies`. This included all of the grunt dependencies and `matchdep`. However, once this was done, everything worked smoothly.

That being said, there's one caveat with this whole process that tripped me up for a while. I was unable to get Heroku to properly use bower, and as such, I had to add all of the installed bower dependencies to the repository. I would like to remove this some day, and add `shell:bower` to the grunt task, but it'll have to wait until I can get that to work. For now, including them in the repository will have to suffice.
