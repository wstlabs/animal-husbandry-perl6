# 
# XXX deprecated
#
use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Util;
use Test;
plan *;

=begin END

sub ok-gen  (Str $x, List $exp)  {
    my $got = combi($x);
    is_deeply $got, $exp, "$x - get";
}

ok-gen 'r', [];
ok-gen 's', [<  r6  >];
ok-gen 'p', [<  s2 sr6 r12  >];


