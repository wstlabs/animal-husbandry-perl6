use v6;
use Farm::Sim::CO;

dump-kombi();
my @j = 12;

for @j -> $j {
    my $t = kombify($j);
    say "kombi($j) = ", $t;
    dump-kombi();
}



