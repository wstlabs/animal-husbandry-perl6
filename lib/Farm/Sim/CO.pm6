use v6;

# straightforward "inverse" of the %WORTH table, above;
# used for determining combinations of animals whose sums 
# are equal to a given value.
constant %K = {
     1 => [<  r    >],
     6 => [<  s d  >],
    12 => [<  p    >],
    36 => [<  c D  >],
    72 => [<  h    >],
};

my %E = { 
     6 => [< s d r6 >]
};

sub is-kosher(Int $j) { $j > 0 && $j % 6 == 0 } 

sub kombify(Int $j) is export {
    die "invalid height '$j'" unless is-kosher($j);
    say "kombify($j) ..";
    return %E{$j}.clone if %E{$j};
}

sub dump-kombi() is export  {
    for %K.keys -> $j  {
        next if $j < 6;
        say "E($j) = ", %E{$j}
    }
}


