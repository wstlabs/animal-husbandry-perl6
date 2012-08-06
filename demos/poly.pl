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




