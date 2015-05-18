---
title: Recreating Creatures, Pt. 1
description: I design a basic, but flawed creature simulator with a brain and biochemistry.
---

To begin, I've created a tag to mark the current state of the software when this post was written.
You can find it [on GitHub](https://github.com/aatxe/life-sim/tree/blog-post1). With that out of the
way, this first step in the game has been a confusing one. I found 
[a paper by Steve Grand](http://mrl.snu.ac.kr/courses/CourseSyntheticCharacter/grand96creatures.pdf)
detailing the design of Creatures. Unfortunately, the paper is sort of confusing, and doesn't go
into a great deal of detail. So, I struggled through designing a system of genetically-defined
biochemistry with some basic primitives inspired by the paper. The definitions of these primitives
was as follows:

```rust
pub struct Chemical {
    id: Id,
    concentration: Concentration,
}

pub struct Emitter {
    chemical: Id,
    gain: Concentration,
}

pub struct Reaction {
    kind: ReactionType,
    rate: u8,
    tick: Cell<u8>,
}

pub struct Receptor {
    kind: ReceptorType,
    chemical: Id,
    gain: f32,
    threshold: Concentration,
}
```

The chemicals were defined essentially as they were in the paper (that is, they had no inherent
properties). The emitters, reactions, and receptors tried to emulate the contents of the paper as I
understood it, but ignoring the parts about locus sites. This was sufficient for me to build a small
simulator:

```rust
fn simulate_genome(steps: u32, genome: Genome, map: &mut ChemicalMap) {
    for _ in 0..steps {
        let mut deltas: DeltaMap = HashMap::new();
        for gene in genome.iter() {
            match *gene {
                Gene::Emitter(ref e) => e.step(&mut deltas),
                Gene::Reaction(ref r) => r.step(map, &mut deltas),
                Gene::Receptor(ref r) => if let Some(val) = r.step(map, &deltas) {
                    println!("Receptor for {} triggered with output {}.", r.id(), val);
                },
                _ => ()
            }
        }
        map.apply(&deltas);
        map.values().map(|v|
            println!("Chemical {} has concentration {}.", v.id(), v.concnt())
        ).count();
    }
}
```

It really doesn't do much, but it does evaluate all of the reactions as they were defined. I had a
lot of difficulty trying to decipher this system and infer how some of it behaved from its
constituent parts, but there weren't any big gotchas along the way. Of course, this is actually
where the flaws came about (basically, emitters and receptors both function differently than how I
interpreted the descriptions), but I'll go more into depth on that later.

The next thing I worked on was the brain, and to do it, I implemented a feedforward neural network.
I'd never done this before, nor have I studied it in any deal of depth. So, this was a pain point.
I managed to get by using 
[Neural Networks in Plain English](http://www.ai-junkie.com/ann/evolved/nnt1.html). The bulk of the
work came in two parts. The first was the core interface to the neural net, and it came together
nicely in functional style:

```rust
    pub fn update(&self, inputs: Vec<f32>) -> Option<Vec<f32>> {
        if inputs.len() != self.input_count { return None }
        Some(self.layers.iter().fold(inputs, |acc, ref layer| {
            layer.neurons.iter().map(|neuron| {
                sigmoid(neuron.weights.iter()
                              .zip(acc.iter().chain([-1.0].iter()))
                              .map(|(w, v)| w * v)
                              .fold(0.0, |acc, ref n| acc + n), 1.0)
            }).collect()
        }))
    }
```

The next part proved quite the struggle. I set out to make a function to create a neural network
from a vector of all the weights. The challenging part was how exactly to slice up this vector such
that the weights are properly assigned in the same pattern that they are read out by
`get_weights(...)`. The final product was as follows:

```rust
    pub fn with_weights(input_count: usize, output_count: usize, hidden_layer_count: usize,
                        neurons_per_hidden_layer: usize, weights: &[f32]) -> Option<NeuralNet> {
        let init = neurons_per_hidden_layer * (input_count + 1); // neurons * weights
        let stride = neurons_per_hidden_layer * (neurons_per_hidden_layer + 1); // neurons * weights
        let fin = output_count * (neurons_per_hidden_layer + 1); // neurons * weights
        if weights.len() != init + stride * (hidden_layer_count - 1) + fin { return None }
        Some(NeuralNet {
            input_count: input_count,
            layers: {
                let mut vec = Vec::with_capacity(hidden_layer_count + 1);
                if hidden_layer_count > 0 {
                    vec.push(NeuronLayer::with_weights(neurons_per_hidden_layer,
                                                       &weights[0..init]));
                    for c in 0 .. hidden_layer_count - 1 {
                        vec.push(NeuronLayer::with_weights(neurons_per_hidden_layer,
                            &weights[init + stride * c .. init + stride * (c + 1)]
                        ));
                    }
                    vec.push(NeuronLayer::with_weights(output_count,
                        &weights[init + stride * (hidden_layer_count - 1) ..]
                    ));
                } else {
                    vec.push(NeuronLayer::with_weights(output_count, weights))
                }
                vec
            }
        })
    }
```

I made the mistake initially of forgetting about the bias in each neuron, and as such, I spent quite
a bit of time debugging what appeared to be some sort of off-by-one error. This is why the number of
weights per neuron has to have a +1 tacked on. Finally, I built a full simulator combining the two
systems:

```rust
fn simulate_genome(steps: u32, genome: Genome, map: &mut ChemicalMap) {
    let mut net = None;
    for gene in genome.iter() {
        match *gene {
            Gene::Brain(h, npl, ref weights) => {
                net = NeuralNet::with_weights(256, 4, h, npl, &weights);
            },
            _ => ()
        }
    }
    let mut state = "none";
    for s in 0..steps {
        let mut inputs: Vec<_> = repeat(0.0).take(256).collect();
        let mut deltas: DeltaMap = HashMap::new();
        for gene in genome.iter() {
            match *gene {
                Gene::Emitter(ref e) => e.step(&mut deltas),
                Gene::Reaction(ref r) => r.step(map, &mut deltas),
                Gene::Receptor(ref r) => if let Some(val) = r.step(map, &deltas) {
                    inputs[r.id() as usize] += val;
                },
                _ => ()
            }
        }
        map.apply(&deltas);
        if let Some(ref net) = net {
            let tmp = net.update(inputs).unwrap().value();
            if tmp != state {
                state = tmp;
                println!("Creature is currently {} at time {}.", state, s);
            }
        }
    }
}
```

Ultimately, this was a pretty trivial adaptation of the original chemical simulator I wrote. The
biggest difference was going through and implementing `Rand` (or using a macro to do so) for a bunch
of the biochemical types in order to allow me to generate large genomes. In running this simulation
with everything randomized (including the neural nets), I found that it was nearly impossible for
the maximum of the four outputs to change. Initially, I thought this meant that something was broken
in my neural network implementation. So, I looked it over thoroughly. I've since come to the
conclusion that I simply need to be far more intentional than randomly-generating everything. This
is also the part where I found out that I had gotten the biochemistry system very wrong by excluding
the locus sites. With the help of 
[Chris Double's Creatures genetics reference](http://double.co.nz/creatures/genetics.htm), I learned
that the locus sites are the way that the biochemistry is tied to physiology. Without this, the
system is fundamentally useless.

At the same time, my friend [Jacob](http://www.jacobedelman.com) began insisting that physiology can
instead be evolved in the neural network itself without any outside systems. So, I'm now at a point
where I have to make a decision between these two options. I can either define physiology through
biochemistry as in Creatures, or I can try to evolve physiology in the neural networks. I'm still
not entirely sure which direction I'm going to take it (although I'm leaning toward the former).
I'll write more once I've gotten something together.
