#
# stub for now
#
use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Posse;
use Farm::AI::Search;
use KeyBag::Ops;
use Test;
plan *;

sub test-equiv(Str $p, Str $x, @trades)  {
    my $P     = posse($p);
    my @found = find-admissible-trades($P,$x);
    is_deeply [sort @found], [sort @trades], "$P,$x";
}


#
# need more of these, please.
#
test-equiv 'r6s',     'd', [<r6 s>];
test-equiv 'r6',      'd', [<r6>];
test-equiv 's',       'd', [<s>];
test-equiv 'ps2r12',  'c', [<ps2r12>];
test-equiv 'ps2r18',  'c', [<ps2r12 psr18>];
test-equiv 'ps2r24',  'c', [<pr24 ps2r12 psr18 s2r24>];
test-equiv 'p3s2',    'c', [<p3 p2s2>];
test-equiv 'p3s2',    'D', [<p3 p2s2>];
test-equiv 'hp4c7s6', 'D', [<c p3 p2s2 ps4 s6>];
test-equiv 'hp4c7s6', 'h',  [<  p3s6 p4s4 c2 cp3 cp2s2 cps4 cs6 >];
test-equiv 'hp4c7s6', 'D2', [<h p3s6 p4s4 c2 cp3 cp2s2 cps4 cs6 >];

# some empty cases
test-equiv 's',       's', [];
test-equiv 'd',       'd', [];
test-equiv 'c',       'd', [];
test-equiv 'p2',      'c', [];
test-equiv 'c',      'd2', [];

=begin END


