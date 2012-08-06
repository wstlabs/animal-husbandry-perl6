use v6;
use Farm::Sim::Util::HashTup;
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

#
# CM = "combinatorial multinomial" = a polynomial over
# some set of single-character symbols whose exponents may
# vary, but whose coefficients are all = 1.  Examples:
# 
#  < x y >, < x2 xy y2 > ... (finish this blurb)
# 



multi sub stringify(KeyBag $x) {
    # my @t = map -> $t, $k {
    #    ($k > 1) ?? "$t$k" !! $t
    # }, $x.hash.kv.sort;
    # @t.join('')
    hashify($x.hash)
}


#
# given CMs multinomials @x, @y, and an exponent $k,
# generates the CM representing the expansion of <x,y>^k, 
# grouped by unique terms.
#
sub spinify(@x, @y, Int $k where $k > 1) is export {
    say "sp k = $k";
    say "sp x = ", @x; 
    say "sp y = ", @y; 
    return () 
}

sub inflate (@p)  {
    map { keybag(hashify($_)) }, @p
}

sub mul-poly (@x, @y) is export {
    # say "sp x = ", @x; 
    # say "sp y = ", @y; 
    # my @X = map -> $x { hashify($x) }, @x;
    # my @Y = map -> $y { hashify($y) }, @y;
    # my @X = map { keybag(hashify($_)) }, @x;
    # my @Y = map { keybag(hashify($_)) }, @y;
    my @X = inflate(@x); 
    my @Y = inflate(@y); 
    say "sp x = @x => {@X.perl}";
    say "sp y = @y => {@Y.perl}";
    return ()
}


