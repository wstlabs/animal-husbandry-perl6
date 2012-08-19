use v6;
use Farm::Sim::Util::HashTup;
use KeyBag::Deco; 
use KeyBag::Ops; 

# This is where we generate "raw" lists of tuples representing animal 
# trades equivalent to a given value (i.e. before further selection 
# criteria like removing predators, checking for availability against
# the Stock, etc).
#
# The idea is to use a basic technique in combinatorics, in which 
# combinations of certain things can be represtned as characteristic
# polynomials, and groupings of combinations are represented as familiar
# operations like multiplication and exponentiation (or rather, cheap
# knock-offs thereof).   
#
# In our case, what we do is define a "pseudo-multiplication" operator,
# namely '∘', which is just like regular polynomial multiplication except 
# we reduce all coefficients to 1 at the end of each step (i.e. all we 
# care about is distinct groups of power tuples which occur after each 
# multiplication steps, not how many of each).  
#
# We also define pseudo-exponentiation in an analgous way.
#
# So fore example: 
#
#   mul-poly <a b>, <x y>  => <a b>  ∘ <x y>  = <ax ay bx by>
#   mul-poly <a2 b>, <a b> => <a2 b> ∘ <a b2> = <a3 a2b b2a b3 a2b2 ab>
#   pow-poly <x y>, 2      => <x y> ∘∘ 2      = <x2 xy y2>
#
#
# Caveats:
#
#   - there's no notion of multiplying by "unity", i.e. with the 
#     polynomial <1> in this regime.
#
#   - as implemented, the operations are quite brittle.  this is 
#     because we basically we don't do any type checking, let alone  
#     any other kind of validation on the lists we multiply. so unless 
#     the operations are given pure lists of valid characteristics,
#     it's anybody's guesss what will come out at the end.
#

sub mul-poly (@p, @q) is export {
    deflate(
        inflate(@p) X⊎ inflate(@q) 
    )
}

sub pow-poly (@p is copy, Int $k where { $k > 0 }) is export  {
    $k == 1 ?? 
        @p 
    !!  
        mul-poly( @p, pow-poly(@p, $k-1) )
}

# we hijack '∘', aka the function composition operator (U+2218) 
# to do our bidding in the service of our homegrown mul /pow ops.
multi sub infix:<∘> ( @p, @q ) is export { mul-poly @p, @q }
multi sub infix:<∘∘>( @p, $k ) is export { pow-poly @p, $k }


#
# magical "inflate" and "deflate" operators, which convert a list representing 
# a valid characteristic polynomial, e.g. <ab2 abc3 a4c> to a list of (decorated) 
# keybag structs, and visa-versa.
#
sub inflate (@p)  { map { keybag(hashify($_)) }, @p }
sub deflate (@P)  { 
    my %h;
    my @p = stringify-keybag(@P);
    for @p -> $p { %h{$p}++ } 
    %h.keys.sort
}

multi sub stringify-keybag(KeyBag $x) {
    stringify($x.hash)
}

multi sub stringify-keybag(@X)  {
    map { stringify-keybag($_) }, @X
}



=begin END

