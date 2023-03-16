/*
    Prove: Public (x,y,PLANETHASH_KEY) is such that:
    - MiMCSponge(x,y) = pub
    - perlin(x, y) = perl
*/
pragma circom 2.0.3;

include "circuits/mimcsponge.circom";
include "circuits/bitify.circom";
include "../perlin/perlin.circom";


template Reveal() {
    // Public signals
    signal input x;
    signal input y;
    signal input PLANETHASH_KEY;
    signal input SPACETYPE_KEY;
    signal input {powerof2, max} SCALE; /// must be power of 2 at most 16384 so that DENOMINATOR works
    assert(SCALE.max <= 16384);
    signal input {binary} xMirror; // 1 is true, 0 is false
    signal input {binary} yMirror; // 1 is true, 0 is false

    signal output pub;
    signal output perl;

    /* check abs(x), abs(y) <= 2^31 */
    _ <== Num2Bits(32)(x + (1 << 31));
    _ <== Num2Bits(32)(y + (1 << 31));

    /* check MiMCSponge(x,y) = pub */
    /*
        220 = 2 * ceil(log_5 p), as specified by mimc paper, where
        p = 21888242871839275222246405745257275088548364400416034343698204186575808495617
    */
    component mimc = MiMCSponge(2, 220, 1);

    mimc.ins[0] <== x;
    mimc.ins[1] <== y;
    mimc.k <== PLANETHASH_KEY;

    pub <== mimc.outs[0];

    /* check perlin(x, y) = p */
    perl <== MultiScalePerlin()([x,y],SPACETYPE_KEY,SCALE, xMirror, yMirror);
}

template mainReveal(){
    // Public signals
    signal input x;
    signal input y;
    signal input PLANETHASH_KEY;
    signal input SPACETYPE_KEY;
    signal input SCALE; /// must be power of 2 at most 16384 so that DENOMINATOR works
    signal input  xMirror; // 1 is true, 0 is false
    signal input yMirror; // 1 is true, 0 is false
  
    signal {powerof2, max} TaggedSCALE <== AddMaxValueTag(16384)(addPowerOf2Tag()(SCALE));
    signal output (pub, perl) <== Reveal()(x,y,PLANETHASH_KEY,SPACETYPE_KEY,TaggedSCALE,AddBinaryTag()(xMirror),AddBinaryTag()(yMirror));
}

template addPowerOf2Tag(){
    signal input in;
    //To add constraints.
    signal output {powerof2} out <== in;
}

component main { public [ x, y, PLANETHASH_KEY, SPACETYPE_KEY, SCALE, xMirror, yMirror ] } = mainReveal();
