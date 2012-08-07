use v6;
use Farm::Sim::Util::HashTup;
use KeyBag::Deco; 
use KeyBag::Ops; 


multi sub stringify-keybag(KeyBag $x) {
    stringify($x.hash)
}

multi sub stringify-keybag(@X)  {
    map { stringify-keybag($_) }, @X
}

#
# magical "inflate" and "deflate" operators, which convert a list representing 
# a valid characteristic polynomial, e.g. <ab2 abc3 a4c> to a list of (decorated) 
# keybag structs, and visa-versa.
#
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
#   mul-poly <a b>, <x y>  ->  ax ay bx by
#   mul-poly <x y>, <x y>  ->  x2 xy y2
#
# Limitations:
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
    $k == 1 ?? 
        @p 
    !!  
        mul-poly( @p, pow-poly(@p, $k-1) )
}

# let's unimaginatively hijack U+2218, aka the function composition operator,
multi sub infix:<∘> ( @p, @q ) is export { mul-poly @p, @q }
multi sub infix:<∘∘>( @p, $k ) is export { pow-poly @p, $k }



=begin END

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




