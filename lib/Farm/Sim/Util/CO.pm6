use v6;
use Farm::Sim::Util;
use Farm::Sim::Util::Poly;
use Farm::Sim::Posse; 
use KeyBag::Ops; 

sub kombify() is export  { 
    my @s = [<r>]           ∘∘ 6; say @s;  #   1 sheep-equivalent tuple  -> r6
    my @p = ( <d s>, @s)    ∘∘ 2; say @p;  #   5   pig-equivalent tuples -> <d s r6>
    my @c = ('p', @p)       ∘∘ 3; say @c;  #  50   cow-equivalent tuples; takes 10s to gen
    # my @h = ('D', 'c', @c)  ∘∘ 2; say @h;  # 355 horse-equivalent tuples; takes 157s! 
    my $S = posse( stock-hash() );
    say "S = ", $S;
}



=begin END
use KeyBag::Deco; 
use KeyBag::Ops; 

# straightforward "inverse" of the %WORTH table, up in F::S::Util; 
# used for determining combinations of animals whose sums are equal 
# to a given value.
constant %K = {
     1 => [<  r    >],
     6 => [<  s d  >],
    12 => [<  p    >],
    36 => [<  c D  >],
    72 => [<  h    >],
};

my %E = { 
     6 => [<  s d r6  >],
    12 => [<  ss sd dd sr6 dr6 r12  >]
};

# XXX make this a trait
sub is-kosher(Int $j) { $j > 0 && $j % 6 == 0 } 

sub kombi(Int $j) is export {
    return %E{$j}.clone if %E{$j};
}

sub kombify(Int $j) is export {
    die "invalid height '$j'" unless is-kosher($j);
    say "kombify($j) ..";
    return %E{$j}.clone if %E{$j};
    my @avail = grep { $_ < $j }, %E.keys;
    say "avail = ", @avail;
}

sub dump-kombi() is export  {
    for %K.keys -> $j  {
        next if $j < 6;
        say "E($j) = ", %E{$j}
    }
}

=begin END

