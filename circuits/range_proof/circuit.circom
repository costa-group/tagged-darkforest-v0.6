pragma circom 2.0.3;

include "circuits/comparators.circom";
include "circuits/bitify.circom";

// NB: RangeProof is inclusive.
// input: field element, whose abs is claimed to be <= than max_abs_value
// output: none
// also checks that both max and abs(in) are expressible in `bits` bits
template RangeProof(bits) {
    signal input {max}in;
    signal input max_abs_value;

    /* check that both max and abs(in) are expressible in `bits` bits  */
    _ <== Num2Bits(bits+1)(in + (1 << bits));
    _ <== Num2Bits(bits)(max_abs_value);

    /* check that in + max is between 0 and 2*max */
    signal lowerBound <== LessThan(bits+1)([max_abs_value + in, 0]);
    lowerBound === 0;
    signal upperBound <== LessThan(bits+1)([2*max_abs_value, max_abs_value + in]);
    upperBound === 0;
}

// input: n field elements, whose abs are claimed to be less than max_abs_value
// output: none
template MultiRangeProof(n, bits) {
    signal input {max} in[n];
    signal input max_abs_value;
    for (var i = 0; i < n; i++) {
        RangeProof(bits)(in[i],max_abs_value);
    }
}

/*
template RPTester() {
    signal input a;
    component rp = RangeProof(10);
    rp.in <== a;
    rp.max_abs_value <== 100;
}

component main = RPTester();
*/
