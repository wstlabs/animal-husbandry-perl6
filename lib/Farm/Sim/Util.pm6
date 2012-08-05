use v6;
use KeyBag::Deco;
use KeyBag::Ops;

#
# some general-purpose utilities, with a current focused on 
# string <=> hash conversion.
#

constant @forsale = <r s p c h>;
constant @animals = <r s p c h d D f w>;
my %ANIMAL is ro  = hash @animals Z=> ( True xx @animals );    

sub tupify (Str $s) is export { 
    $s ~~ m/^ (<alpha>\d*)+ $/ ?? 
        return map -> $t { $t.Str}, $0
    !! die "malformed string representation [$s]"
}

sub tup2pair(Str $s) {
    $s ~~ m/(<alpha>)(\d*)/ ??  (
        $0.Str, $1.Str
    ) !! die "malformed tuple element [$s]"
}  


# straightfoward string-to-hash conversion, converting e.g. "rs" to 
# the hash { r => 1, s => 1 }, and handling corner cases such as the
# empty symbol, and accepting non-canonical strings such as "rr"
# as well as degenerate cases like "r0" and "r01".
#
# note that we'll throw at the tupify() step if we're given structurally 
# invalid input, i.e. not matching the regex up in that sub.  that leaves 
# structurally valid strings containing invalid (non-animal) chars, which
# we choose to catch in a separate step, down in the for loop below.
sub hashify(Str $s) is export { 
    return {} if $s eq '∅';
    my Int %h;
    my @t = tupify($s); 
    for @t -> $t {
        my ($x,$n) = tup2pair($t);
        my $k = 
            $n eq '' ?? 1  !! 
            $n > 0   ?? $n !! 
        0;
        die "malformed string representation:  invalid symbol '$x'" 
            unless %ANIMAL{$x};
        %h{$x} += $k if $k > 0 
    };
    return %h
}

sub stringify(%h) is export  {
    my @t = map -> $x,$k {
        $k > 0 ??
            $k > 1 ?? "$x$k" !! $x
        !! ()
    }, %h.kv; 
    return @t ?? @t.join('') !! '∅'
}

# breed 'strictly', that is, politely declining requests to breed with 
# foxes and wolves (by returning Nil), but rejecting outright any KeyBag
# containing anything but valid, "for-sale" animal chars.
#
# note that although the signatures ask for both inputs to be KeyBags,
# the eventual type that's returned is whatever type $x happens to really
# be (so if it's a Posse, we'll get a Posse object as a result).
#
# XXX has a bug around the fact that '∅' ∈ any(Bag), apparently!
# also, the KeyBag should be a KeySet; but the ∈ op isn't implemented 
# for pure Sets yet.
#
multi sub breed-strict (KeyBag $x, KeyBag $r) is export {
    return Nil         if any('f','w') ∈ $r;
    die "invalid!" unless all($r.keys) ∈ KeyBag.new(@forsale);
    breed-naive($x,$r)
}

#
# a purely set-theoretic breeding operation, with no input constraints. 
# kept as a separate (private) function simply to represent the basic
# breeding operation as simply as possible. 
#
multi sub breed-naive (KeyBag $x, KeyBag $r)  {
    my $s = KeySet.new($r);
    return ( 
        ($x ∩ $s) ⊎ $r
    ) / 2 
}

my %T = (
    'r' => []
);

sub combify (Str $s) is export {
}
sub combi (Str $s) is export {
    return [<NYI>]
}




=begin END







# constant @forsale = <r s p c h>;
# my $FORSALE is ro = keybag(@forsale);

#
#    hash map @animals -> $a { $a => True }; 
#

#
# Provides the magical 'spawn' method, determining how many
# animals could (in principle) be provided when a posse 'breeds' 
# with the animals contained in a f/w die roll -- but NOT yet
# subject to the constraints of what's available in the stock,
# and equivalent to the infix <⚤> operator defined below.
#
# ... (XXX finish) ..
# So a typical usage might go like this:  if $X represents
#
#   my $animals_successfully_bred = ( $X.posse ⚤ $roll) ∩ $S.animals
#
# Or,
#
#   $P ⊎= ( $P ⚤ $roll) ∩ $S
#
# Note: ideally, we'd just like to do:
#
#   ( (self ∩ $x.keys) ⊎ $x ) / 2 
#
# but certain planets don't quite seem aligned for that yet. 
#
role Farm::Sim::Bag::Frisky {
    multi method spawn (Any $x) {
        my $r = posse($x);
        return Nil if any('f','w') ∈ $r;
        my $s = KeySet.new($r);
        self.inter($s).sum($r) / 2
    }
}

