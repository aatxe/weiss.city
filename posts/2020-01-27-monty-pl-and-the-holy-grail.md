---
title: Monty PL and the Holy Grail
description: In this post, I describe the quest for the holy grail of programming --- a language that strikes the perfect balance between systems and application programming. This article is a lightly updated version of my submission to the ACM Student Research Competition Grand Finals which can be found <a href="https://src.acm.org/binaries/content/assets/src/2019/aaronweiss.pdf">here</a>.
---

Conventional wisdom among programmers holds that one should choose "the best
language for the job." Though exactly which language is "best" is often
ambiguous, in practice, there has arisen a division between so-called
_"systems programming"_ languages that enable fine-grained control over
the usage and layout of memory, and _"applications programming"_
languages that provide the programmer with high-level abstractions to make
correct software more quickly and with less effort. But in the lands of myths
and legends, brave knights of programming languages research seek out the Holy
Grail --- a general-purpose programming language that enables programmers to get
both the high-level abstractions of the latter and the fine-grained control of
the former.

# The Quest for the Holy Grail

For decades, these Knights of PL have explored idea after idea in search of the
grail. One of the most promising discoveries on this quest came as Ser Girard's
Linear Logic whose powers of reasoning about _resources_ spawned a wealth of new
work on high-level support for resource management in programming. Among these,
the efforts of Ser Baker on Linear Lisp are most relevant to our tale. On
their quest, Ser Baker used a notion of _linearity_ to enable efficient
reuse of objects in memory in a functional programming language _without_
garbage collection. Here, linearity prevented aliasing in programs, enabling the
treatment of names as resources. Further, Ser Baker uncovered a relationship
between linearity and
stack machines that allow arbitrary manipulation on the top of the stack,
capturing a _low-level_ interpretation of linearity in
programming.

Then, later quests by Sers Clarke, Potter, and
Noble and Sers Noble, Vitek, and Potter brought us the discovery of _ownership
  types_, a programming discipline that empowers the programmer with the
flexibility to control what kinds of aliasing patterns are allowed in their
programs. While Ser Baker addressed the question of
how to design a high-level language without garbage collection, these next
efforts address the question of how to control aliasing in programs to avoid
classic systems problems like _encapsulation violations_,
_use-after-free bugs_, and _data races_. Here, we see an essential
insight --- rather than choose one for the whole language, one can give the
programmer a choice locally between uniqueness and mutability _or_
sharedness and immutability (sometimes called _writing xor sharing_).

Around the same time, Sers Tofte and Talpin
set out on their own quests to enable more fine-grained
control of memory management in functional programming languages through the use
of _regions_. These regions statically group objects into distinct sections
of memory which are allocated and deallocated together. In the ensuing years,
many worked on developing full-scale production languages that leveraged these
ideas to create a _safe systems programming language_. Yet, for
a variety of reasons (not least of which a lack of large-scale engineering
investment), none of these really caught on. Still, the ideas and techniques
discovered on these quests moved the Knights of PL forward, helping to bring us
to today.

# A New Lead?

In recent years, the Rust programming language has taken
off as the latest language at the intersection of low-level systems programming
and high-level applications programming --- bringing us the closest we have ever
gotten to the Holy Grail. Its rapid growth and promising design have caught the
attention of researchers and practitioners alike. To accomplish this, Rust integrates
many of these ideas discovered on prior quests --- including automatic memory
management without garbage collection, flexible
control over aliasing, and region-based memory
management --- into a novel framework called _borrow checking_. But hailing from
industry knights, Rust and its _borrow checker_ lack the kinds of formal
specifications that enable many of the
reasoning techniques favored by the Knights of PL, and thus preventing their
benefits.

For those uninitiated by the Knights of PL, I will try to make these benefits
concrete. Historically, formal reasoning has played an essential role in
developing new features for programming languages, ensuring the correctness of
languages and their compilers, and enabling programmers to reason more precisely
about their programs. For instance, Featherweight
Java and other similar efforts to formalize
Java were used to experiment with designs for generics and led to Java's
generics system being introduced in Java 1.5. As a squire myself, I have set out
to try to bring this kind of power and interest to Rust by producing a formal
account of the language, dubbed _Oxide_, on my journey to knighthood.

While there are some existing formalizations of Rust, none capture a
high-level understanding of Rust's essence (namely _ownership_ and
_borrowing_). In particular, the first major effort,
Patina, formalized an early version of Rust which predates
much of the work to simplify and streamline the language, and was ultimately
left unfinished. The next effort, known as Rusty
Types, set out to characterize Rust-like type
systems, developing a formal calculus, _Metal_, which relies on an
algorithmic formulation of borrow checking that is less expressive than both
Rust and Oxide. RustBelt, the most complete effort to
date, formalized a _low-level_, intermediate language in
continuation-passing style, making it difficult to reason about ownership as a
_source-level_ concept. Finally, an early version of
Oxide oversimplified some parts of the language and
overcomplicated others. We have since revised and simplified Oxide greatly to
get at its _essence_.

In this post, I'll present the key intuitions behind Oxide,
wade a bit into some of the essential formal elements, and
finally explore some of the ramifications of this newfound understanding.
Our draft paper features a larger, and more complete account of Oxide.

# Understanding the Borrow Checker

As alluded to already, the essence of Rust lies in its _borrow checker_, a
novel approach to _ownership_, which accounts for the most interesting
aspects of the language's type system (or _static semantics_) and provides
justification for its claims to _memory safety_ and _data race freedom_.
In this section, we work through a number of examples on our quest
to understand ownership and borrowing, and how they are ultimately captured in
Oxide.

# Ownership for Great Good

The first element of Rust's _borrow checker_ is a notion of
_ownership_ that builds on the quests of Ser
Baker, which developed support for efficient reuse of
objects in memory using _linearity_. In fact, there is a strong resemblance
between this half of Rust's borrow checker and Ser Baker's 'use-once'
variables. We can view these ideas at work in
Rust in the following example:

```rust
  struct Point(u32, u32);

  let mut pt = Point(6, 9);
  let x = pt;
  let y = pt; // ERROR: pt was already moved
```

In this example, we declare a type `Point` consisting of a pair of
unsigned 32-bit integers (denoted `u32`). Then, on line 3, we create a new
`Point` named `pt`. We use `mut` to mark that the binding for
`pt` can be reassigned, and we say that this value is _owned_ by its
identifier `pt`. Then, on line 4, we transfer ownership to `x` by
_moving_ the value from `pt`. After moving the value out of
`pt`, we invalidate the old name, and thus, in the subsequent attempt to
use it on line 5, we encounter an error as `pt` was already moved in the
previous line. With the exception of required type annotations, this program is
identical in Oxide, and produces the same error.

# Borrowing for Flexibility

The second element of Rust's _borrow checker_ is known as _borrowing_
and represents the language's main departure from ideas like 'use-once'
variables. Rather than say that
_everything_ must be unique, Rust allows the programmer to locally make a
decision between using unique references with
unguarded mutation _or_ using shared references without such
mutation.[^1] This flexibility takes inspiration from the
quests of Sers Noble, Clarke, Vitek, and Potter toward flexible alias protection
and ownership types. We can once again see this at work in Rust with an example:

[^1]: The use of "such" here is intentional as dynamically guarded mutation, e.g. using a `Mutex`, is still allowed through a shared reference. Indeed, this is precisely what makes such guards _useful_ when programming.

```rust
  struct Point(u32, u32);

  let mut pt = Point(6, 9);
  let x = &pt;
  let y = &pt; // no error, sharing is okay!
```

In the above example, we replaced the _move_ expressions on lines 4 and 5
with _borrow_ expressions that create shared references to `pt`. As
noted in the comment, this program does not produce an error because the
references specifically _allow_ this kind of sharing. However, unlike with
plain variable bindings (as in the last example), we cannot mutate through these
references, and attempts to do so would result in an error at compile-time.
However, the behavior changes when we try to mix shared and unique references to
the same place:

```rust
  struct Point(u32, u32);

  let mut pt: Point = Point(6, 9);
  let x: &'a mut Point = &mut pt;
  let y: &'b Point = &pt;
  //                 ^~~
  // ERROR: cannot borrow pt while
  //        a mutable loan to pt is live
  ... // additional code that uses x and y
```

In this case, we've changed the borrow expression on line 4 to create a unique
reference, and added explicit type annotations to our bindings on lines 3--5.
This produces an error because Rust forbids the creation of a shared reference
while a mutable _loan_ exists. Here, we use the word loan to refer to the
state introduced in the borrow checker (including the uniqueness of the loan and
its origin) by the creation of a reference. Regions[^2] in
Rust (denoted `'a`, `b`, etc.) can be understood as collections of
these loans which together statically approximate which pointers could be used
dynamically at a particular reference type. This is the sense in which Rust's
regions are distinct from the existing literature on region-based memory
management.
  
[^2]: Previously, Rust used the term _lifetime_, but recent efforts on a borrow checker rewrite called Polonius have been using the term region. 

While we were unable to create a second reference to the same place as an
existing unique reference in our past examples, Rust allows the programmer to
create two unique references to disjoint paths through the same object, as in
the following example:

```rust
  struct Point(u32, u32);

  let mut pt: Point = Point(6, 9);
  let x: &'a mut u32 = &mut pt.0;
  let y: &'b mut u32 = &mut pt.1;
  // no error, our loans don't overlap!
```

In this example, we're borrowing from specific paths within `pt` (namely,
the first and second projections respectively). Since these paths give a name to
the places being referenced, we refer to them as _places_. Rust employs a
fine-grained notion of ownership allowing unique loans against non-overlapping
places within aggregate structures (like structs and tuples). Intuitively, this
is safe because the parts of memory referred to by each place (in this case,
`pt.0` and `pt.1`) do not overlap, and thus they represent portions
that can each be uniquely owned.

# Formalizing Rust

These programs remain largely the same in Oxide, though I don't have the space
to reproduce them all here. There are three main differences from Rust. First,
we explicitly annotate the types of every binding. Second, acknowedgling the two
distinct roles `mut` plays in Rust, I draw attention to its use as a
qualifier for the uniqueness of references (renaming it to `uniq`). Third, I
shift the language we use to discuss regions or lifetimes. In particular, since
regions capture approximations of a reference's origin, I use the more precise
term _approximate provenances_, and refer to their variable form
(`'a`, `'b`, etc.) as _provenance variables_. With these
differences in mind, let's revisit our last example after translating it into
Oxide:

```rust
  struct Point(u32, u32);

  let pt: Point = Point(6, 9);
  let x: &'x uniq u32 = &'x uniq pt.0;
  let y: &'y uniq u32 = &'y uniq pt.1;
  // no error, our loans are disjoint
```

As already noted, the type annotations on lines 3--5 (i.e. for each let binding)
are now required, and we replaced `mut` with the qualifier `uniq`,
denoting that the references on lines 4 and 5 are unique. The program is
otherwise unchanged from the Rust version. Then, as in the original, the Oxide
version of the program type checks successfully because the origins of the loans
created on lines 4 and 5 are disjoint. That is, we know that `x` can
only have originated from `pt.0`, `y` only from `pt.1`, and
that `pt.0` and `pt.1` refer to disjoint portions of memory.

How did the type-checker determine this? First, while type-checking the let
bindings, Oxide computes the concrete values for any provenance variables that
appear in their types (such as `'x` and `'y`). Here, it determines
that `'x` will be mapped to `{ uniq pt.0 }` and `'y` to `{ uniq pt.1 }`. These
mappings tell
us the potential provenance of each reference, where in this simple case, there
is exactly one for each. Then, when type-checking the borrow expressions, Oxide
looks at its place environment &Gamma; to determine that there are no live
loans to any place that is somehow joint with the place we're borrowing from. In this
case, on line 5, the type-checker looks at the current environment and finds
that the only live loan is `uniq pt.0`, and since `pt.0` and `pt.1` are disjoint,
the second borrow also type checks.

_Information Loss_. Though the example we just saw has a precise origin
for each reference, provenances are, in general, approximate because of join
points in the program. For example, in an if expression, we might create a new
set of loans in one branch, and a different set of loans in the other branch. To
keep the type-checker sound, we need to be conservative and act as if
_both_ sets of loans are live, and so, we combine the return types and
environments from each branch.

# Oxide, More Formally

We've now seen roughly enough to describe Oxide in more formal detail. First,
note that loans are created and destroyed over the course of the program. This
means that our type system has to somehow track the flow of this information as
it type-checks each expression. As such, we use an environment-passing typing
judgment where the output of the judgment includes an updated environment that
may have added or removed some bindings (and thus created or destroyed some
loans). We write this judgment as $\Sigma; \; \Delta; \; \Gamma \vdash e : \tau \Rightarrow \Gamma^\prime$,
which can be read as:
under the global environment $\Sigma$ (containing top-level program
definitions including both function and type definitions), the type variable
environment $\Delta$ (tracking in-scope type and provenance variables), and
the place environment $\Gamma$ (mapping places to their respective types),
the expression $e$ has type $\tau$ and produces an updated output
environment $\Gamma^\prime$, which contains all of the remaining places
_after_ type-checking the expression $e$.

\begin{figure_[H]
  \begin{mathpar_
    \TMove \and \TBorrow
  \end{mathpar_
  \caption{The essence of Oxide._
  \label{fig:essence_
\end{figure_

Above, we see two typing rules that capture the essence of how
Oxide models the behavior of Rust's borrow checker. Following the traditions of
the Knights of PL, these rules are written in the style of _natural
  deduction_ where each rule can be read as ``if we have a proof of the
statements above the horizontal line, then we can combine them to construct a
proof of the statement below the line." As such, to understand our two rules,
it is necessary to understand the meaning of the judgement in their premise
($\Sigma; \; \Gamma \; \vdash_\omega \; p : \tau \Rightarrow \{ \; \ell_1 \; \dots \; \ell_n \; \}$).

This judgment, called ownership safety, says "in the place environment
$\Gamma$, it is safe to use the place $\pi$ (of type $\tau$)
$\mu$-ly." That is, if we have a derivation when $\mu$ is unique, we
know that we can use the place $\pi$ uniquely because we have a proof that
there are no live loans against the section of memory that $\pi$
represents. This instance of the judgment appears in the premise of
$\texttt{T-Move}$ because we know that it is only safe to move a value _out_
of the environment when it is the sole name for that value. Further, when we
have a derivation of this ownership safety judgment where $\mu$ is $\texttt{imm}$,
we know that we can use the place $\pi$ sharedly because we have a proof
that there are no live _unique_ loans against the section of memory that
$\pi$ represents. In the case of borrowing (as in $\texttt{T-Borrow}$), these
two meanings of ownership safety correspond exactly to the intuition behind when
a $\mu$-loan is safe to create.

Since this judgment is the one that captures the essence of Rust's ownership
semantics, we understand Rust's borrow checking system as ultimately being a
system for statically building a proof that data in memory is either
_uniquely owned_ (and thus able to allow unguarded mutation) or
_collectively shared_, but not both. To do so, intuitively, the
ownership safety judgment looks through all of the approximate provenances found
within types in $\Gamma$, and ensures that none of the loans they contain
conflict with the place $\pi$ in question. For a $\texttt{uniq}$ loan, a conflict
occurs if any loan maps to an overlapping place, but for a $\texttt{shrd}$ loan, a
conflict occurs only when a $\texttt{uniq}$ loan maps to an overlapping place.

For both more examples and more details about the Oxide formalism, interested
readers should look at the full article by Weiss, Patterson, Matsakis, and
Ahmed.

# Oxide in Context

As with prior quests directed at understanding real world languages, Oxide
provides a formal framework for reasoning about the behavior of programs in one
such language --- i.e. programs in surface-level Rust. One prominent example is
Featherweight Java which supported a wealth
of new research on Java. And as with prior quests such as this, a number of
promising avenues for future work on Rust open up that leverage our newfound
reasoning ability with Oxide.

# Formal Verification

One of the unfortunate gaps in Rust programming today is the lack of effective
tools for proving properties (such as functional correctness) of Rust programs.
There are some early efforts already to try to improve this
situation~\cite{ullrich16:electrolysis, toman15:crust, baranowski18:smack,
  astrauskas18:rust-viper_, but without a semantics the possibilities are
limited. For example, the work by Astrauskas et
al. builds verification support for Rust into
Viper, but uses an ad-hoc subset of the language without
support for shared references. We believe that our work on Oxide can help extend
such work to support more Rust code, and will enable further verification
techniques like those seen in $F^\star$ and Liquid
Haskell.

# Verified Compilation

Given the prevalence of memory safety issues in security vulnerabilities, Rust's
guarantees of memory safety lend themselves well to building security-critical
applications. However, many security-critical applications (like cryptography
code) require that these guarantees still hold after compilation, and further
require a guarantee that timing of the program is preserved under compilation
(to avoid the introduction of side-channel attacks). Rust's existing compiler
toolchain --- which is built using LLVM --- is unable to
formally prove preservation of these kinds of guarantees, and indeed, for
timing, optimizations are designed to do almost entirely the opposite. As such,
another avenue for future work would be to develop a verified compiler for Rust
that preserves program semantics and timing behavior, perhaps by compilation to
Vellvm.

# Language-based Security

We also view Oxide as an enabler for future work on extending techniques from
the literature on language-based security to Rust. In particular, one could
imagine building support for dynamic or static information-flow control atop
Oxide as a formalization (for which we can actually prove theorems about these
extensions) alongside a practical implementation for the official Rust compiler.
Similarly, Oxide can support building extensions for data-oblivious computing
(as in work by Zahur and Evans) and relaxed
noninterference (as in recent work by Cruz et al.).

# The Quest Marches On&#8230;

As argued early on, Rust is the closest the Knights of PL have
gotten to the Holy Grail of Programming --- the language that provides
programmers all the benefits of high-level abstractions and all the fine-grained
control of systems programming. With Oxide, we now have the tools to interact
with and build on Rust more formally. This work too will help bring us closer to
the Grail. Yet, we also remain so far! Still, I --- forever the fool ---
continue on my own search.
