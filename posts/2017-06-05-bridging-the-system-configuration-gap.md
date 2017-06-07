---
title: Bridging the System Configuration Gap
description: I recently gave a talk at <a href="http://www.nepls.org">NEPLS</a> on research that enables sysadmins to update high-level system configurations from the shell.
---

Last Friday, I gave a talk at [NEPLS](http://www.nepls.org) on work I did while I was at UMass with [Arjun Guha](https://people.cs.umass.edu/~arjun/home/). You can find the slide deck for the talk [here](/pubs/nepls17.pdf), but the rest of this post will be a presentation of the same general material.

# The State of System Configuration

In the past, system administrators relied largely on the shell to configure systems within an organization. Systems would either be configured manually on an individual basis, or automatically by scripts written by more enterprising administrators. However, the increased need for computer systems has made this approach generally intractable.

With the scale of modern computer systems, system configuration has become a pressing technical challenge. Large companies like [Red Hat](http://redhat.com), [Oracle](https://www.oracle.com/), and [Google](https://www.google.com/intl/en/about/) are pouring money into configuration management tools to deal with these complexities. These tools provide powerful, high-level abstractions to make system administration easier, and they're widely used for this purpose. For example, [Puppet](https://puppet.com) boasts that it's used by over 33,000 organizations, including 75 of the Fortune 100. 

Still, scripts written in these configuration languages frequently contain bugs, and the shell remains the simplest way to diagnose them. However, after diagnosis, system administrators cannot **fix** the bugs from the shell as doing so would cause the state of the system to drift from the state specified by the configuration. Thus, in spite of their advantages, configuration management tools force system administrators to give up the simplicity and familiarity of the shell. But is there some way that we can fix this?

# Bridging the Gap

We've developed an approach called *imperative configuration repair* that uses techniques derived from general program synthesis to allow administrators to use configuration languages and the shell in harmony. With imperative configuration repair, a user can diagnose and repair a configuration bug via the shell and have the changes **automatically** propagate back to the original configuration. This propagation keeps the configuration in sync with the system, preventing *configuration drift*.

Imperative configuration repair has a number of important properties that make it particularly useful to system administrators. Firstly, it's sound, meaning that all the changes made via the shell are preserved. Secondly, it supports configuration maintainability by preserving the structure and abstraction of the configuration. Thirdly, it deals nicely with the possibility of multiple repairs by presenting the user with a list of repairs ranked in a logical fashion. Finally, it works with all existing shells because it relies on known tools for programming monitoring (like [ptrace](https://linux.die.net/man/2/ptrace)).

# A Repair Scenario

To get a better idea of what imperative configuration repair actually looks like, let's step through an example from the perspective of [Pied Piper](http://www.piedpiper.com) using [Puppet](https://puppet.com).

```puppet
package {"apache2": ensure => present }
service {"apache2": ensure => running }

define website($title, $root) {
  file {"/etc/apache2/sites-enabled/$title.conf":
    content => "<VirtualHost $title:80>
    DocumentRoot /var/sites/$root
    </VirtualHost>"
  }

  file {"/var/sites/$root":
    ensure => directory,
    source => "puppet://sites/$root",
    mode => 0700,
    recurse => "remote"
  }
}

website {"piedpiper.com": root => "piedpiper" }
website {"piperchat.com": root => "piperchat" }
```

In this example, we install and start the Apache service. We also create two simple Apache configurations that set up two websites, PiedPiper.com and PiperChat.com. This uses a type of Puppet abstraction known as a *define type*, but you can think of this as a simple function. 

On its face, this Puppet configuration (or *manifest*) looks to be correct. However, when we deploy the configuration to a machine and try to visit either website, we get an Error 403: Forbidden. In order to debug this issue, we can then head to the shell. Looking at the log files (`tail /var/log/apache2/error.log`), we can see a line stating `permission denied`. We haven't set up anything about user access, and so the problem should be one of filesystem permissions. When we run `stat /var/sites/piedpiper`, we get back that the owner is `root` and the permissions are `-rwx------` (or `0700` for short). From this, we can recognize the issue: our `www` user cannot access the files Apache is trying to serve! 

Now that we've identified the issue, we can try to fix it. One possible fix is to run `chmod 755 /var/sites/piedpiper`. We can run this in the shell, and then run the special command `synth` to start the process of imperative configuration repair. This will automatically propagate the changes back to the manifest, resulting in the mode line changing to `mode => 0755`.

# Multiple Repairs

To get a sense of how multiple repairs are handled with imperative configuration repair, we can look at a simple, but slightly contrived example with a single instantiation of a single abstraction.

```puppet
define dir($path) {
  file {$path:
    ensure => directory
  }
}

dir { path => "/foo" }
```

In this example, we have a `dir` abstraction that creates a directory at the specified path, and a single instantiation for the path `"/foo"`. If we then use the command `mv /foo /bar`, there are actually two possible repairs that make this change. The obvious one changes the constant `"/foo"` to `"/bar"`, but the other one changes the use of `$path` on the second line to `"/bar"` meaning the abstraction ignores its parameter.

Both repairs are correct in that they preserve the changes made via the shell, but a user is likely to prefer the one that changes the parameters to the abstraction. We capture this intuition in a ranking algorithm. We calculate a cost for each repair that corresponds to the sum of the number of updates and the number of updates within an abstraction. This means that smaller updates and updates that make changes outside abstractions are preferred.

# Bringing the Shell to Puppet 

We implemented a prototype of imperative configuration repair for Puppet which we called [Tortoise](https://github.com/plasma-umass/Tortoise). Our prototype is written in [Scala](http://scala-lang.org), and consists of around 3,300 lines of code. It's built using [strace](https://linux.die.net/man/1/strace) and [z3](http://rise4fun.com/z3). It has its limitations, but works on a set of thirteen real Puppet benchmarks from [GitHub](https://github.com) used in prior work. To get a better sense of how it works, let's step through the whole toolchain at a high level.

The user starts a Tortoise monitor on a shell using its pid: `tortoise watch -i manifest.pp -p pid`. The user must specify which manifest is deployed on the system and should be updated according to the edits made. They then enter a number of commands on the shell which produce file system effects via system calls. Tortoise records these effectful system calls and the paths that they've affected. When the user has fixed the bug, they run the command `synth` to signal to Tortoise to generate the repair.[^1] After receiving the `synth` command, the process of imperative configuration repair begins.

[^1]: Currently, `synth` is just an alias of the Unix `true`. A future version of Tortoise will instead have a dedicated `synth` program that communicates with the Tortoise monitor and presents the choice of repairs in this shell, rather than the monitoring one.

Once initiated, Tortoise starts by parsing the manifest identified by the `-i` flag into a Puppet abstract syntax tree (AST). Then, it performs a labeling operation on the AST that assigns a unique label to each variable binding (including in abstractions). These labels are used to associate repairs with their corresponding bindings. We then compile the Puppet manifest into an imperative specification language called &Delta;P. This &Delta;P specification captures a series of file system operations and is used to generate a corresponding abstract file system on which the changes recorded by strace can be replayed. After replaying these changes, we can then use the abstract file system to produce &Delta;P constraints that will be used next in the synthesis procedure.

The synthesis procedure starts by compiling the &Delta;P specification into logical formulas describing the step-by-step operation of the manifest over a symbolic file system. It then converts the &Delta;P constraints into logical assertions about the final state of the program over the symbolic file system. Because these changes were made via the shell after running the program, they may currently be false. Next, [z3](http://rise4fun.com/z3) is asked to repeatedly find new models for the repair by replacing values present in the original program. Each of these models are recorded, and parsed into repair substitutions. These repairs are then ranked by the previously described ranking algorithm, and presented to the user. The user then selects their preferred repair, and the system automatically applies it to the manifest on disk.

# Evaluating Tortoise

We evaluated our prototype on a suite of thirteen real world Puppet benchmarks that were gathered from GitHub. These benchmarks consist of instantiations of open source Puppet modules. For each benchmark, we identified a number of possible repairs to make via the shell. We ran Tortoise with each benchmark and each shell repair, and produced a list of repairs. To understand the effectiveness of the ranking procedure, we presented this list in a randomized fashion and asked the user to select their preferred repair. We recorded the Tortoise-assigned rank of this repair for each instance. We then averaged them and found that the average repair rank was 1.31 indicating that Tortoise typically ranks the preferred repair as the first option (this exact case occurred 75% of the time).

![Varying manifest size with a constant-sized update.](/images/size-scaling.png)

We also looked at evaluating the scalability of Tortoise on artificial benchmarks. In each case, we ran 100 trials at each size, recorded the runtime, and computed the average and confidence interval across all trials. In one case, we looked at varying the size of the manifest while leaving the update size constant. This result is presented above. In practice, most manifests do not seem to grow beyond this size and the performance is well under a second. So, this performance seems reasonable.

In the other case, we looked at varying the size of the update. This result is presented below, and appears roughly exponential. This is expected because Tortoise relies on SMT solving to generate repairs. Fortunately, we can break up large repairs into a series of smaller intermediate pieces (that cover some part of the overall repair) and avoid the degenerate performance at large sizes. In general, we expect that users will likely perform distinct updates separately anyway.

![Varying update size for a manifest.](/images/update-scaling.png)

# Summary

In conclusion, we presented imperative configuration repair and a prototype [Tortoise](https://github.com/plasma-umass/Tortoise) that together bridge the gap between configuration management tools and the shell. Imperative configuration repair preserves all changes made from the shell, preserves the structure and abstractions of the original manifest, and uses instrumentation techniques to support all existing shells. Our prototype implementation is fast, and shows that our ranking algorithm appears reasonable. Overall, we have demonstrated that imperative configuration repair is a realistic technique for improving the process of configuration management.
