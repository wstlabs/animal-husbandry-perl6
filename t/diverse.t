use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Posse;
use Test;
plan *;

sub ok-L-to-R (Str $xx, Str $yy, Bool $bool)  {
    my $x = posse($xx);
    my $y = posse($yy);
    is $x ⊳ $y, $bool, "$x ⊳ $y => $bool";
}

sub ok-R-to-L (Str $yy, Str $xx, Bool $bool)  {
    my $y = posse($yy);
    my $x = posse($xx);
    is $y ⊲ $x, $bool, "$y ⊲ $x => $bool";
}


my @R is ro = <
        r    ∅  True 
        ∅    r  True 
        r    s  True 
        s    s  False 
       s2    s  True 
        r   sr  False 
        s   sr  False 
       sr   sr  False 
       sr    r  False 
       sr    s  False 
      s2r    s  True 
      s2r    r  False 
     p2s2   ps  True 
     p2s2   p2  False 
     p2s2   s2  False 
     c2p3    c  True
     c2p3   p2  True 
     c2p3   p3  False 
     p3s4   p3  False 
     p3s4   p4  False 
     p3s4 p2s2  True 
     c2p3   hc  True
     c2p3   p4  False 
     p2s2   s3  False 
>;

# L-to-R:  "LHS subtracts RHS diversely to .."
# R-to-L:  "LHS subtracts diversely from RHS to .."
for @R -> $xx,$yy,$flag  { ok-L-to-R $xx, $yy, eval($flag) }  # x ⊳ y 
for @R -> $xx,$yy,$flag  { ok-R-to-L $yy, $xx, eval($flag) }  # y ⊲ x 


=begin END

.. ⊲ ⊳

sub ok-div-refl(Str $xxg Str $yy, Bool $tf)  {
    ok-div-LR($xxg$yy,$tf);
    ok-div-RL($yyg$xx,$tf);
}


"$x ⊲ $y => $tf"
    # is subtracts-diversely($xg$y), $tf, "$x ⊳ $y => $tf"



    # say $x.radix ~ " <= $x"
    # say $y.radix ~ " <= $y"
    # my @diff = $x.radix Z- $y.radix
    # my $stat = ?( any(@diff) <= 0 )
    # say @diffg " => $stat"

multi sub infix:<⊲>

   # c2p3 > c      but not p3        (even though both ⊂ c2p3)
    # p3s4 > p2s2   but not p3gps4
    #
    # (2g3) - (1,0) = (1,2) => yes
    # (2g3) - (0,3) = (2,0) => no
    #
    # (3g4) - (2,2) = (1,2) => yes
    # (3g4) - (3,0) = (0,4) => no
    # (3g4) - (1,4) = (2,0) => no
    #

