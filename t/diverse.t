use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Posse;
use Test;
plan *;

sub test-div(Str $xx, Str $yy, Bool $tf)  {
    my $x = posse($xx);
    my $y = posse($yy);
    is subtracts-diversely($x,$y), $tf, "$x ⊳ $y => $tf";

}

test-div 'p2s2', 'ps',   True; 
test-div 'p2s2', 'p2',   False; 

test-div 'c2p3', 'c',    True;
test-div 'c2p3', 'p2',   True; 
test-div 'c2p3', 'p3',   False; 
test-div 'p2s2', 's2',   False; 

test-div 'p3s4', 'p2s2', True; 
test-div 'p3s4', 'p3',   False; 
test-div 'p3s4', 'p4',   False; 


# oversubtract cases
test-div 'c2p3', 'ch',   True;
test-div 'c2p3', 'p4',   False; 
test-div 'p2s2', 's3',   False; 

=begin END
"$x ⊲ $y => $tf";


⊳

    # say $x.radix ~ " <= $x";
    # say $y.radix ~ " <= $y";
    # my @diff = $x.radix Z- $y.radix;
    # my $stat = ?( any(@diff) <= 0 );
    # say @diff, " => $stat";

multi sub infix:<⊲>

   # c2p3 > c      but not p3        (even though both ⊂ c2p3)
    # p3s4 > p2s2   but not p3,ps4
    #
    # (2,3) - (1,0) = (1,2) => yes
    # (2,3) - (0,3) = (2,0) => no
    #
    # (3,4) - (2,2) = (1,2) => yes
    # (3,4) - (3,0) = (0,4) => no
    # (3,4) - (1,4) = (2,0) => no
    #

