use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::AI::Util;
use Test;
plan *;

{
    ok  hashify('∅')  eqv {},                   "∅";
    ok  hashify('r')  eqv { r => 1 },           "r";
    ok  hashify('r2') eqv { r => 2 },           "r2";
    ok  hashify('rr') eqv { r => 2 },           "rr";
    ok  hashify('rs') eqv { r => 1, s => 1 },   "sr";
    ok  hashify('sr') eqv { r => 1, s => 1 },   "rs";
}

{
    my $s;
    dies_ok { $s = hashify('x') }, "x";
    dies_ok { $s = hashify('')  }, "(empty)";
}


