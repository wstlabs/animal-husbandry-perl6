use v6;
use Farm::Sim::Util;
use Farm::Sim::Util::Poly;
use Farm::Sim::Posse; 
use KeyBag::Ops; 


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

