pragma circom 2.1.4;

template CalculateTotal(n) {
    signal input in[n];
    signal output out;
    var sum = in[0];
    for (var i = 1; i < n; i++) {
        sum += in[i];
    }
    out <== sum;
}
