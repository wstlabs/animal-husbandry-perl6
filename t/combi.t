use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Posse;
use KeyBag::Ops;
use Test;
plan *;

sub ok-gen  (Str $x, List $a)  {
    # say "x = $x";
    # say "a = $a.WHICH = ", $a; 
    ok $x, "$x - gen";
}

ok-gen 'r', [];
ok-gen 's', [<  r6  >];
ok-gen 'p', [<  s2 sr6 r12  >];

=begin END

