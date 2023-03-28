/*
    Prove: I know (x,y) such that:
    - biomeperlin(x, y) = biomeBase
    - MiMCSponge(x,y) = hash
*/
pragma circom 2.0.3;

include "circuits/mimcsponge.circom";
include "../perlin/perlin.circom";
include "circuits/tags_specifications.circom";

template Biomebase() {
    // Public signals
    // todo: label this as planetHashKey
    signal input PLANETHASH_KEY;
    signal input BIOMEBASE_KEY;
    // SCALE is the length scale of the perlin function.
    // You can imagine that the perlin function can be scaled up or down to have features at smaller or larger scales, i.e. is it wiggly at the scale of 1000 units or is it wiggly at the scale of 10000 units.
    // must be power of 2 at most 16384 so that DENOMINATOR works
    signal input {powerof2, max} SCALE;
    assert(SCALE.max <= 16384);

    signal input {binary} xMirror; // 1 is true, 0 is false
    signal input {binary} yMirror; // 1 is true, 0 is false

    // Private signals
    signal input {max_abs} x;
    signal input {max_abs} y;

    signal output hash;
    signal output biomeBase;

    /* check MiMCSponge(x,y) = pub */
    /*
        220 = 2 * ceil(log_5 p), as specified by mimc paper, where
        p = 21888242871839275222246405745257275088548364400416034343698204186575808495617
    */
    component mimc = MiMCSponge(2, 220, 1);

    mimc.ins[0] <== x;
    mimc.ins[1] <== y;
    mimc.k <== PLANETHASH_KEY;

    hash <== mimc.outs[0];

    /* check perlin(x, y) = p */
    signal {max_abs} p[2];
    p.max_abs = x.max_abs;
    p <== [x,y];
    biomeBase <== MultiScalePerlin()(p, BIOMEBASE_KEY, SCALE, xMirror, yMirror);
}

template mainBiomebase() {
    // Public signals
    // todo: label this as planetHashKey
    signal input PLANETHASH_KEY;
    signal input BIOMEBASE_KEY;
    // SCALE is the length scale of the perlin function.
    // You can imagine that the perlin function can be scaled up or down to have features at smaller or larger scales, i.e. is it wiggly at the scale of 1000 units or is it wiggly at the scale of 10000 units.
    // must be power of 2 at most 16384 so that DENOMINATOR works
    signal input SCALE;
    signal input xMirror; // 1 is true, 0 is false
    signal input yMirror; // 1 is true, 0 is false

    // Private signals
    signal input x;
    signal input y;
    
    signal {powerof2, max} TaggedSCALE <== AddMaxValueTag(16384)(addPowerOf2Tag()(SCALE));
    signal output (hash, biomeBase) <== Biomebase()(PLANETHASH_KEY, BIOMEBASE_KEY, TaggedSCALE, AddBinaryTag()(xMirror), AddBinaryTag()(yMirror), 
                                        Add_MaxAbs_Tag(2**32-1)(x), 
                                        Add_MaxAbs_Tag(2**32-1)(y));
}

component main { public [ PLANETHASH_KEY, BIOMEBASE_KEY, SCALE, xMirror, yMirror ] } = mainBiomebase();
