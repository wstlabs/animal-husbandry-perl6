use v6;
use Farm::Sim::Util;
use Farm::Sim::Posse; 
use Farm::AI::Util::Poly;
use KeyBag::Ops; 


# mercilessly spews a freeform list of tuple equivalence classes.  in general
# this is done only as a manual, "out-of-band" step to provide boilerplate to 
# populate the tables over in Farm::AI::Search::Data, which is where the 
# official reference data sets actually live.
#
# note that some of the generation steps can take several seconds, and
# the final step (for 'h' or 'D2' equivalences) can around 2-3 minutes, 
# depending perhaps on what compiler you're running.
sub kombify() is export  { 
    my @s = [<r>]           ∘∘ 6; say @s;  #   1 sheep-equivalent tuple  -> r6
    my @p = ( <d s>, @s)    ∘∘ 2; say @p;  #   5   pig-equivalent tuples -> <d s r6>
    my @c = ('p', @p)       ∘∘ 3; say @c;  #  50   cow-equivalent tuples; takes 10s to gen
    my @h = ('D', 'c', @c)  ∘∘ 2; say @h;  # 355 horse-equivalent tuples; takes 157s! 

    my %N = (
        's' => @s.Int,
        'p' => @p.Int,
        'c' => @c.Int,
        'h' => @h.Int
   );
    say "N = ", %N;

    my $stock = posse( stock-hash() );
    say "stock = ", $stock;

    my @S = sort map { posse($_) }, @s;
    my @P = sort map { posse($_) }, @p;
    my @C = sort map { posse($_) }, @c;

    say "S = ", @S;
    say "P = ", @P;
    say "C = ", @C;

    say "grep against stock:";

    say "cows..";
    my @X = grep { $_ ⊆ $stock }, @C;
    say "C => ", @X.Int; # 47
    say "C = ", @X;

    say "horses.."; 
    my @H = sort map { posse($_) }, @h;
    my @Y = grep { $_ ⊆ $stock }, @H;
    say "H => ", @Y.Int; # 276
    say "H = ", @Y;

}

sub kombify-slow() is export  { 
    my @s = [<r>]           ∘∘ 6; say @s;  #   1 sheep-equivalent tuple  -> r6
    my @p = ( <d s>, @s)    ∘∘ 2; say @p;  #   5   pig-equivalent tuples -> <d s r6>
    my @c = ('p', @p)       ∘∘ 3; say @c;  #  50   cow-equivalent tuples; takes 10s to gen
    my @h = ('D', 'c', @c)  ∘∘ 2; say @h;  # 355 horse-equivalent tuples; takes 157s! 
}


=begin END

