---
title: Reasoning with Types in Rust
description: In this post, I explore how Rust's type system provides programmers with powerful reasoning principles. In doing so, I attempt to present an accessible explanation of an idea known as free theorems and its relationship with noninterference, a common security property.
---

[Rust][rust] is a modern programming language which is marketed primarily on the basis of its very
nice type system, and I'd like to tell you about how you can use this type system to reason about
your programs in interesting ways. Most of the time when its type system is discussed, the focus is
on its guarantee of data race freedom and ability to enable so-called
[_fearless concurrency_][fearless] (and rightfully so---this is a place where Rust truly shines!).
Today, I have a different focus in mind, characterized perhaps most succinctly as follows:

> From the type of a polymorphic function we can derive a theorem that it satisfies. Every function
> of the same type satisfies the same theorem. This provides a free source of useful theorems.
>
> <cite>Philip Wadler, [_Theorems for Free!_][tff]</cite>

If you're not the most mathematically inclined, don't be scared off by the word theorem! The quote
is telling us that---with the right property of our type system---we can learn useful properties
about generic (i.e. polymorphic) functions solely by inspecting their types. In the rest of this
post, we'll cover this type system property, and a number of example properties we can derive from
types as as result.[^1] Much of what's covered can be generalized to languages aside from Rust,
but (most) examples will be in Rust with Rust-specific aspects highlighted.

[^1]: Owing to their presentation in the paper [_Theorems for Free!_][tff], these properties are
known in the  academic world as _free theorems_---though I suspect that some will be unhappy with my
liberal application of this term to intuited properties.

# A Principal Property for Reasoning

The property at the heart of this style of type-based reasoning with generics is known as
_parametricity_. Parametricity can be formulated as a mathematical theorem,[^2] but it's best
thought of intuitively as the notion that all instances of a polymorphic function act the same way.
With this intuition in mind, you can imagine determining whether or not a particular function is
parametric. For example, we can determine that the following [Java][java] function is parametric:

```java
public static <T> T identity(T x) {
  return x;
}
```

And that the following almost-Java function is not:[^3]

```java
public static <T> T notIdentity(T x) {
  if (x instanceof Integer) {
    return (T) 42;
  } else {
    return x;
  }
}
```

The reason for this is that the latter function has chosen to specialize its behavior based on the
type of its parameter, rather than acting the same on all types. This cuts to the essence of
parametricity: to write parametric functions, we must treat parametric types opaquely! While Java
does not enforce parametricity (and in fact often encourages otherwise), other type systems like that
of [Haskell][haskell] and Rust require all functions to be parametric.[^4] When all polymorphic
functions are parametric, the type system is said to be _parametrically polymorphic_---though in
practice, many parametrically polymorphic type systems support some degree of ad hoc (that is,
type-dependent polymorphism). In this case, we know that all polymorphic functions are parametric
and we're able to learn some of their properties solely from their type. So, let's look at some
examples in Rust.

[^2]: And indeed, it was originally presented as the _abstraction theorem_ in John C. Reynolds'
[_Types, abstraction, and parametric polymorphism_][typeabs].
[^3]: Actual Java does not allow the cast from `Integer`{.java} to `T`{.java} as such, but there are
more complicated examples involving subtyping that can produce similar specialized-by-type behavior.
This simpler example nevertheless captures the essence of non-parametric functions.
[^4]: Strictly speaking, [Haskell's `seq` breaks general parametricity][freeseq], as do Rust's
various reflection capabilities (including `Sized`) and the upcoming
[impl specialization][specialization] feature. Fortunately, like in the Haskell paper, we can always
refine our notion of parametricity. Though this does have some consequences for precisely what
properties you can glean from types.

# Who am I? or: Reasoning about Identity

Consider the following function type, and try to imagine as many implementations as possible:

```rust
fn<T>(T) -> T
```

This type describes a function that for any type `T`{.rust}, takes an argument of type `T`{.rust}
and returns a result of type `T`{.rust}. If you're already familiar with Rust, I'm sure it wouldn't
take long to come up with the following implementation, the identity function:

```rust
pub fn id<T>(x: T) -> T {
    x
}
```

In fact, since there are no operations we can actually perform on `x`{.rust}, it's the only possible
return value for this function. Of course, since Rust is effectful, we could print something before
we return like so:

```rust
pub fn effectful_id<T>(x: T) -> T {
    println!("oh no");
    x
}
```

And Rust is also partial, meaning we could error (called _panicking_ in Rust) or otherwise diverge:

```rust
pub fn panicking_id<T>(_: T) -> T {
    panic!("at the disco")
}

pub fn diverging_id<T>(_: T) -> T {
    loop {}
}
```

These various implementations all tell us something about what the type means, which we can phrase
like so:

> A function of type `fn<T>(T) -> T`{.rust} must:
>
>    - return its argument __or__
>    - panic or abort __or__
>    - never return

Additionally, since we still know nothing about the type `T`{.rust}, we can conclude that any
effects that occur during the function are _not_ dependent on the argument. With these two
properties, we can then conclude the more general properties that functions of the type
`fn<T>(T) -> T`{.rust} behave "like an identity function":

> Given a function `id`{.rust} of type `fn<T>(T) -> T`{.rust}, a total function `f`{.rust} of the
> form `fn(A) -> B`{.rust} where `A`{.rust} and `B`{.rust} are both concrete types, and a value 
> `a`{.rust} of type `A`{.rust}, then either:
>
>    - `id`{.rust} can be composed arbitrarily (e.g. `id(f(a)) = f(id(a))`{.rust}) __or__
>    - `id(f(a))`{.rust} and `f(id(a))`{.rust} both panic or diverge.

In order to conclude this, we can consider each of the cases we previously described. If the
function returns its argument, then we know both that `id(a) = a`{.rust} and
`id(f(a)) = f(a)`{.rust} and we can combine these two equalities to conclude the first result. If
the function does not return its arguments, we know it either panics or never returns but we also
know that this cannot be dependent on the argument in any way. Thus if `id(f(a))`{.rust} panics,
then `f(id(a))`{.rust} __must__ panic as well.

With that, we've intuited (but have not formally proven)[^5] our first "useful theorem" about
a family of functions based solely on their type. While it's nice to know that identity-looking
functions behave like an identity function, there's certainly nothing earth-shattering about the
result. But the fact that we can apply this style of reasoning to _every_ type ought to be
compelling.

[^5]: Though our argument is somewhat proofy, we would require a formal semantics for Rust. There
exists one in the form of [RustBelt][rustbelt], and as part of my research, I hope to produce an
alternative formal backing for these free theorems in Rust, particularly the latter ones related to
security.

# Vectors Abound

Let's look at a slightly more complicated type now, involving Rust's `Vec<T>`{.rust} type for
dynamically-sized buffers. We'll again follow the same formula of enumerating some possible
implementations before trying to conclude a general property. Given the type:

```rust
fn<T>(Vec<T>) -> Vec<T>
```

We can come up with implementations such as:

```rust
pub fn tail<T>(vec: Vec<T>) -> Vec<T> {
    vec.into_iter().skip(1).collect()
}

pub fn reverse<T>(vec: Vec<T>) -> Vec<T> {
    let init = Vec::with_capacity(vec.capacity());
    vec.into_iter().fold(init, |mut acc, elem| {
        acc.insert(0, elem);
        acc
    })
}

pub fn swap_first_two<T>(mut vec: Vec<T>) -> Vec<T> {
    if vec.len() < 2 {
        return vec;
    }
    let elem = vec.remove(1);
    vec.insert(0, elem);
    vec
}
```

We can then try to capture a sense of what this type means as we did before:

> A function `m`{.rust} (for mystery) of type `fn<T>(Vec<T>) -> Vec<T>`{.rust} must:
>
>    - return a `Vec<T>`{.rust} that contains a subset of the contents of its argument
>      `Vec<T>`{.rust} in any order. (i.e. `∀v. {e | e ∈ m(v)} ⊆ {e | e ∈ v}`{.agda}) __or__
>    - panic or abort __or__
>    - never return

The process of concluding this is more complicated, but the general gist is that such a function can
only perform the operations defined on `Vec<T>`{.rust} and as usual cannot inspect the types of its
elements. From there, we know that we cannot create new values of type `T`{.rust} or perform any
operations dependent on values within the vector. This also leverages the Rust-specific fact that
values (in this case, of type `T`{.rust}) cannot be copied without knowing that they implement
`Clone`{.rust} and/or `Copy`{.rust} (whereas in other languages with parametricity, this typically
is not the case). We can then conclude that all functions at this type must yield a permutation (or
possibly a subset of a permutation) of the input vector. Of course, the same exceptions about panics
and divergence apply. Interestingly, we can reach a similar general conclusion to the one we reached
for `fn<T>(T) -> T`{.rust}:

> Given a function `m`{.rust} of type `fn<T>(Vec<T>) -> Vec<T>`{.rust}, a total function `f`{.rust}
> of the form `fn(A) -> B`{.rust} where `A`{.rust} and `B`{.rust} are both concrete types, and
> `a`{.rust} is a value of type `Vec<A>`{.rust}, then either:
>
>    - `mystery(map_f(a)) = map_f(mystery(a))`{.rust} where `map_f`{.rust} is defined as 
>       `|x| { x.iter().map(f).collect() }`{.rust} __or__
>    - at least one of `mystery(map_f(a))`{.rust} and `map_f(mystery(a))`{.rust} panic or diverge.

# Noninterference for Free

Thus far, we've looked at rather simple properties of programs because it is easier to imagine the
proof in your head. But now, let's take the opportunity to explore a security property called
_noninterference_ for which a number of tailored type systems have been built. The idea behind these
type systems is typically that you annotate types and values in your program with labels indicating
whether a value should be public or secret (some systems expand this with further labels, but just
the two are enough for the basics). Noninterference then says that functions with public output
cannot depend on private inputs. Fortunately, using parametricity, we can have this property for
free in Rust![^6]

To do so, first, we have to define a notion of secret (we'll treat all unannotated types as
public, though we could choose to introduce a public type as well for symmetry):

```rust
pub struct Secret<T>(T);
```

Strictly speaking, we've now achieved noninterference! That was probably easier than you expected,
but the intuition should be clear: since we can perform no operations whatsoever on values of the
type `Secret<T>`{.rust}, it is impossible for public outputs to depend on secret data! However,
there is a caveat: because of how access modifiers work in Rust, code in the same module can violate
noninterference like so:

```rust
pub struct Secret<T>(T);

pub fn unwrap_secret<T>(secret: Secret<T>) -> T {
    secret.0
}
```

To avoid this, we can place our implementation of secret types inside of its own module with no
additional code:

```rust
pub mod secret {
    pub struct Secret<T>(T);
}
use self::secret::Secret;
```

Now, we have noninterference enforced in any downstream code, but in real security type systems, you
can still use secret values to compute other secret values. To do this, we can use Rust's trait
system to add common functionality. We can use this to define a lot of operations, but some of the
operator-overloading traits (`std::ops`{.rust}) are not currently general enough making some code
less pleasant.[^7] Here is our example with some ability to use secret values to compute other
secret values:

```rust
pub mod secret {
    #[derive(Copy, Clone, Default)]
    pub struct Secret<T>(T);

    use std::ops::{Add, Sub};

    impl<T> Add for Secret<T> where T: Add {
        type Output = Secret<<T as Add>::Output>;

        fn add(self, other: Secret<T>) -> Self::Output {
            Secret(self.0 + other.0)
        }
    }

    impl<T> Sub for Secret<T> where T: Sub {
        type Output = Secret<<T as Sub>::Output>;

        fn sub(self, other: Secret<T>) -> Self::Output {
            Secret(self.0 - other.0)
        }
    }

    // ...
}
use self::secret::Secret;
```

Now, we have some ways of using our secret data to construct other secret data. It's limited, but
many other extensions should follow similar patterns and we could also add other operations
implemented directly on `Secret<T>`{.rust} types that compose secret values without going through a
trait like so:

```rust
impl Secret<bool> {
    pub fn branch<F, T>(&self, cons: F, alt: F) -> Secret<T>
    where F: Fn() -> Secret<T> {
        if self.0 {
            cons()
        } else {
            alt()
        }
    }
}
```

With all these extensions, the argument that parametricity is still enforcing noninterference is now
dependent on the exact set of operations that have been implemented for `Secret<T>`{.rust}, but as
long as they _always_ return an argument of the form `Secret<T>`{.rust}, Rust will enforce
noninterference. We can even include operations that combine `Secret<T>`{.rust} and `T`{.rust} as
long as their results are themselves secret. We could even imagine building a simple static analysis
tool that runs atop Rust to audit a crate providing such a secret type to ensure that every function
it implements returns a secret marked type.

[^6]: A connection between parametricity and noninterference was commonly held wisdom in the
programming languages community, but was not proven until Bowman and Ahmed's
[_Noninterference for Free_][nifree].
[^7]: The consequence of this is that we would need to define methods instead of operators which
would make secret code look weirder and be less ergonomic, but is not a fundamental limitation to
this approach. If the trait definitions were made more general, this would be a nonissue, and we
could use macros instead to offer some improvements.

# Bountiful Properties with Bounded Parametricity

Though we used traits to extend the functionality of our `Secret<T>`{.rust} type, they played a
somewhat limited role in our argument for noninterference via parametricity, but we can do more.
Fundamentally, traits allow us to bound type parameters with a specific interface that can be used
within functions. This allow us to weaken our notion of parametricity from type parameters and
values at those types being completely opaque to values at those types being usable in a controlled
fashion. Correspondingly, we can derive even more interesting properties from the types. For a
simple example, consider this extended version of our original identity example:

```rust
fn<T>(T) -> T where T: Display
```

Previously, we said that any side-effects of this function could not depend on the argument. By
adding the `Display`{.rust} bound on `T`{.rust}, we've allowed the argument to be displayed in
output effects like `println!`{.rust}. In a sense, this new ability to display the argument is
expanding the allowed set of side-effects. This expansion is most evident from the fact that all of
our old implementations are still legal at this bounded type, but new implementations are also
legal. For example:

```rust
pub fn trace<T>(x: T) -> T where T: Display {
    println!("{}", x);
    x
}
```

You may have noticed as we went through our earlier noninterference example that this property seems
almost useless by virtue of being overly strict. In particular, since public outputs cannot depend
on secret values in any way, there's really no reason to use secret values at all. In practice,
security type systems offer escape hatches (much like Rust's `unsafe`{.rust}) to selectively reveal
secret information in a way that is readily auditable. With traits, we can build a principled escape
hatch giving us a weakened property known as _relaxed noninterference_.[^8] Relaxed noninterference
can be understood intuitively as the property that public outputs can only depend on secret values
according to predetermined rules known as _declassification policies_.

In our formulation in Rust, we will record these policies as traits and use trait bounds to decide
what policies are available within a function. Consequently, the type signatures of our functions
will necessarily have to tell us how they plan on using the secret data we give them giving us
strong, local reasoning principles for security. At the heart of this approach is our previous
definition of `Secret<T>`{.rust} with a trait representing the empty declassification policy:

```rust
pub struct Secret<T>(T);

pub trait Sec<T>: private::Sealed {}
impl<T> Sec<T> for Secret<T> {}

mod private {
    use super::Secret;
    pub trait Sealed {}
    impl<T> Sealed for Secret<T> {}
}
```

Our private module here is used to seal the `Sec<T>`{.rust} trait preventing it from being
implemented on any additional types beyond `Secret<T>`{.rust}. With just this, we can now specify
functions like before that have noninterference: 

```rust
pub fn f<S, T>(x: u32, y: S) -> u32 where S: Sec<u32> {
    // the following line is not legal...
    // return y.0;
    x
}
```

We can then specify a number of declassification policies that enable us to make selective use of
our secret values:

```rust
// Debug declassification policy: can format the value for debugging purposes
impl<T> Debug for Secret<T> where T: Debug {
    fn fmt(&self, f: &mut Formatter) -> Result<(), Error> {
        self.0.fmt(f)
    }
}

// Zeroable declassification policy: can determine whether or not this is zero
impl<T> Zeroable for Secret<T> where T: Zeroable {
    fn is_zero(&self) -> bool {
        self.0.is_zero()
    }
}

// Hash declassification policy: can compute a hash of the value
impl<T> Hash for Secret<T> where T: Hash {
    fn hash<H>(&self, state: &mut H) where H: Hasher {
        self.0.hash(state);
    }
}
```
And then we can use these declassification policies to discern legal implementations of specific
types as we've done before. Consider the type:

```rust
fn<'a, S>(S, u64) -> bool where S: Sec<&'a str> + Hash
```

We know that there are some trivial implementations (e.g. comparing the `u64`{.rust} against
`0`{.rust}) that don't make use of the secret value, but what about implementations that do? We can
come up with something like:

```rust
pub fn check<'a, S>(password: S, db_hash: u64) -> bool
where S: Sec<&'a str> + Hash {
    // please don't actually do this, use bcrypt or scrypt instead.
    use std::collections::hash_map::DefaultHasher;
    let mut hasher = DefaultHasher::new();
    password.hash(&mut hasher);
    hasher.finish() == db_hash
}
```

Now, if we connected this to a web framework (like the amazing [Rocket][rocket]), we could imagine
having our forms always providing passwords as secret values. Then, by using traits as
declassification policies, we can use the type system to ensure that we never accidentally misuse
the password. However, we should be wary: we used `Hash`{.rust} in this example because it's
provided by `std`{.rust} and includes already-implemented hash algorithms, but it's actually
overly-permissive for this purpose. We could write a custom hasher that would allow us to leak
information or even completely reveal the value. For a real implementation, we would instead provide
a more constrained trait that allows you to compute a specific cryptographic hash such as bcrypt or
scrypt.

[^8]: In [_Type Abstraction for Relaxed Noninterference_][typeabsrni], we see a related presentation
of relaxed noninterference as a consequence of object-oriented type abstraction capabilities. Since
Rust uses parametric polymorphism with traits for type abstraction, we are developing an analogue
here.

# Some Final Words

If you've made it this far, you've seen a bunch of "crazy academic concepts" like parametricity,
free theorems, and noninterference. You've also seen how traits can be used to relax parametricity
and give us even more useful free theorems. Hopefully, this endeavor has convinced you of the
strength of type-based reasoning in Rust. The [small examples][examples] that you've seen
throughout the post are really just scratching the surface of this kind of reasoning: we can go
further by using the added constraints from the ownership system to produce even more interesting
theorems (such as that a [cryptographic nonce][nonce] is only used once). The extent of these
reasoning capabilities is one of my personal favorite features of strong type systems, and
subsequently one of my favorite things about Rust. Maybe it'll be one of yours now too!

[rust]: https://www.rust-lang.org/
[java]: https://www.java.com/
[haskell]: https://www.haskell.org/
[fearless]: https://blog.rust-lang.org/2015/04/10/Fearless-Concurrency.html
[tff]: http://ecee.colorado.edu/ecen5533/fall11/reading/free.pdf
[typeabs]: https://commie.club/papers/reynolds83:parametricity.pdf
[freeseq]: https://cs.appstate.edu/~johannp/popl04.pdf
[specialization]: https://github.com/rust-lang/rfcs/pull/1210
[rustbelt]: http://plv.mpi-sws.org/rustbelt/
[nifree]: http://www.ccs.neu.edu/home/amal/papers/nifree.pdf
[typeabsrni]: https://hal.archives-ouvertes.fr/hal-01637023/document
[rocket]: https://rocket.rs/
[examples]: https://github.com/aatxe/reasoning-with-types
[nonce]: https://en.wikipedia.org/wiki/Cryptographic_nonce
