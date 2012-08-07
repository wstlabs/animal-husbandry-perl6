use v6;
use Farm::Sim::Util;
use Farm::Sim::Util::Poly;
use Farm::Sim::Posse; 
use KeyBag::Ops; 


sub kombify() is export  { 
    my @s = [<r>]           ∘∘ 6; say @s;  #   1 sheep-equivalent tuple  -> r6
    my @p = ( <d s>, @s)    ∘∘ 2; say @p;  #   5   pig-equivalent tuples -> <d s r6>
    my @c = ('p', @p)       ∘∘ 3; say @c;  #  50   cow-equivalent tuples; takes 10s to gen
#   my @h = ('D', 'c', @c)  ∘∘ 2; say @h;  # 355 horse-equivalent tuples; takes 157s! 

    my $stock = posse( stock-hash() );
    say "stock = ", $stock;

    my @S = sort map { posse($_) }, @s;
    my @P = sort map { posse($_) }, @p;
    my @C = sort map { posse($_) }, @c;

    say "S = ", @S;
    say "P = ", @P;
    say "C = ", @C;

}

sub kombify-slow() is export  { 
    my @s = [<r>]           ∘∘ 6; say @s;  #   1 sheep-equivalent tuple  -> r6
    my @p = ( <d s>, @s)    ∘∘ 2; say @p;  #   5   pig-equivalent tuples -> <d s r6>
    my @c = ('p', @p)       ∘∘ 3; say @c;  #  50   cow-equivalent tuples; takes 10s to gen
    my @h = ('D', 'c', @c)  ∘∘ 2; say @h;  # 355 horse-equivalent tuples; takes 157s! 
}


=begin END

  <r s d p c D h>

  r36 
  r30s r30d
  r24s2 r24sd r24d2                     r24p
  r18s3 r18s2d r18sd2 r18d3             r18sp r18dp
  r12s4 r12s3d r12s2d2 r12sd3 r12d4     r12s2p r12sdp r12d2p    r12p2 

  r6s5 r6s4d r6s3d2 r6s2d3 r6sd4 r6d5 
  r6s3p r6s2dp r6sd2p r6d3p
  r6sp2 r6dp2

  s6 s5d s4d2 s3d3 s2d4 sd5 d6 

  s4p s3dp s2d2p sd3p d4p 

  s2p2 sdp2 d2p2

  p3 


  C = d6 p2d2 p3 pd4 r12d4 r12p2 r12pd2 r12s2d2 r12s2p r12s3d r12s4 r12sd3 r12spd r18d3 r18pd r18s2d r18s3 r18sd2 r18sp r24d2 r24p r24s2 r24sd r30d r30s r36 r6d5 r6p2d r6pd3 r6s2d3 r6s2pd r6s3d2 r6s3p r6s4d r6s5 r6sd4 r6sp2 r6spd2 s2d4 s2p2 s2pd2 s3d3 s3pd s4d2 s4p s5d s6 sd5 sp2d spd3




