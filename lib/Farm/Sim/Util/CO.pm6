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



multi sub stringify-keybag(KeyBag $x) {
    # my @t = map -> $t, $k {
    #   ($k > 1) ?? "$t$k" !! $t
    #}, $x.hash.kv.sort;
    # @t.join('')
    stringify($x.hash)
}

multi sub stringify-keybag(@X)  {
    map { stringify-keybag($_) }, @X
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

# "inflate" and "deflate" operators, that convert a list representing  
# a valid characteristic polynomial, e.g. <ab2 abc3 a4c> to a list of
# (decorated) keybag structs, and visa-versa.
sub inflate (@p)  { map { keybag(hashify($_)) }, @p }
sub deflate (@P)  { 
    my @p = stringify-keybag(@P);
    my %h;
    for @p -> $p {
        %h{$p}++
    } 
    %h.keys.sort
}

#
# in which we perform a pseudo-multiplication op on valid characteristic 
# polynomials @p, @q, whereby we add the exponents on all like terms, but we 
# don't bother to keep track of the arithmetic multiplicative coefficients -- 
# all we care whether a given combinatorial term exists or not in our 
# sequence of interest, not is multiplicity.
#
# So we get, e.g.:
#
#   mul-poly <a b>, <x y> =>  ax ay bx by
#   mul-poly <x y>, <x y> =>  x2 xy y2
#
# Drawbacks:
#
#   - there's no notion of multiplying by "unity", i.e.
#     the polynomial <1> in this regime.
#
#   - the particular sequence of operations is quite brittle;
#     if @p and @q do not, in fact, denote valid charecteristic 
#     polynomials as desired, then you're pretty much guaranteed
#     to get a nasty stack trace.
#
sub mul-poly (@p, @q) is export {
    deflate(
        inflate(@p) X⊎ inflate(@q) 
    )
}

#
# iterative form of the mul-poly op
#
sub pow-poly (@p is copy, Int $k where { $k > 0 }) is export  {
    $k < 2 ?? 
        @p 
    !!  
        mul-poly( @p, pow-poly(@p, $k-1) )
}

# we unimaginatively hijack U+2218, aka the function composition operator: 
multi sub infix:<∘> ( @p, @q ) is export { mul-poly @p, @q }
multi sub infix:<∘∘>( @p, $k ) is export { pow-poly @p, $k }


=begin END



# U+2039, U+203A
multi sub infix:<‹*›>(@p,@q) is export { mul-poly @p,@q }

E2 : 226 = 
‹∙∙›
‹*›
‹**›

∘
∘∘

#
# long-winded form of mul-poly, for debugging. 
#


sub mul-poly-long (@p, @q) is export {
    my @P = inflate(@p); 
    my @Q = inflate(@q); 
    # say "mul-poly p => ", stringify-keybag(@P); 
    # say "mul-qoly q => ", stringify-keybag(@Q); 
    my @S = @P X⊎ @Q;
    # say "mul-poly s => ", stringify-keybag(@S);
    my @s = deflate(@S);
    return @s; 
}

sub mul-poly (@p, @q) is export {
    my @P = inflate(@p); 
    my @Q = inflate(@q); 
    # say "mul-poly p = @p => {@P.perl}";
    # say "mul-poly q = @q => {@Q.perl}";
    say "mul-poly p => ", stringify(@P); 
    say "mul-qoly q => ", stringify(@Q); 
    my @S = @P X⊎ @Q;
    say "mul-poly s => ", stringify(@S);
    my @s = deflate(@S);
    return @s; 
}

