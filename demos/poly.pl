use v6;
use Farm::Sim::Util::CO;

# dump-kombi();

my @j = 12,24;
for @j -> $j {
    my $t = kombify($j);
    say "kombi($j) = ", $t;
    # dump-kombi();
}

say mul-poly <a b>, <x y>;
say mul-poly <x y>, <x y>;
say mul-poly <d r6 s>, <d r6 s>;

say <x y> ∘ <x y>;

say pow-poly <x y>, 3;
say <x y> ∘∘ 4;
say <a b> ∘∘ 5;
say [<r>] ∘∘ 6;

my @s = [<r>]           ∘∘ 6; say @s;  #   3 sheep - equivalent tuples
my @p = ( <d s>, @s)    ∘∘ 2; say @p;  #   5 pig   - equivalent tuples 
my @c = ('p', @p)       ∘∘ 3; say @c;  #  50 cow   - equivalent tuples; takes 10s to gen
# my @h = ('D', 'c', @c)  ∘∘ 2; say @h;  # 355 horse - equivalent tuples; takes 157s! 

=begin END

