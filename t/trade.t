use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Posse;
use Test;
plan *;

{
    my $p = posse("dsr2");
    is_deeply [ $p.base ], [< r s >],   ".base";
    is_deeply [ $p.need ], [< p c h >], ".need";
}


