use v6;
use KeyBag::Deco;
use KeyBag::Ops;

#
# some general-purpose utilities, with a current focused on 
# string <=> hash conversion.
#

constant @forsale  = <r s p c h>;          # sometimes,
constant @domestic = <r s p c h d D>;      # it's actually OK
constant @animals  = <r s p c h d D f w>;  # to repeat yourself.

my %ANIMAL   is ro  = hash @animals Z=> True xx @animals;
my %RANK     is ro  = hash @forsale Z=> 1..5;
my %iRANK    is ro  = %RANK.invert; 

# XXX obviously the next two hashes are related - we'd rather skip
# the task of deriving one from the other, but it might be a good idea 
# to do some QA to verify that they're in step with each other.
constant %EXCHANGE = { 
    s => 'r6', p => 's2', c => 'p3', h => 'c2', d => 's', D => 'c' 
};
constant %WORTH = {
    r => 1, s => 6, p => 12, c => 30, h => 72,
            d => 6, D => 12
};

my %T is rw = ( r => [], s => ['r6'] );

sub tupify (Str $s) is export { 
    $s ~~ m/^ (<alpha>\d*)+ $/ ?? 
        return map -> $t { $t.Str}, $0
    !! die "malformed string representation [$s]"
}

# returns a "raw" pair of split tuple components, e.g.:
#
#   r2 => ("r","2"), r1 => ("r","")
#
sub tup2raw(Str $s) {
    $s ~~ m/(<alpha>)(\d*)/ ??  (
        $0.Str, $1.Str
    ) !! die "malformed tuple element [$s]"
}  

sub tup2pair(Str $s) {
    my ($x,$n) = tup2raw($s);
    my Int $k = 
        $n eq '' ?? 1      !! 
        $n >= 0  ?? $n.Int !! 
        # umm, should never happen theoretically, 
        # given the regex in tup2raw, but:
        die "invalid tuple exponent '$n'"
    ;
    ($x,$k)
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
        my ($x,$k) = tup2pair($t);
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



#
# A Posse's nominal trading value (in rabbits), based on standard
# conversion rates.  Note that the input arg doesn't need to be an
# actual Posse object; it can also be just a plain old KeyBag,
# and the trading measure will be computed in the natural way. 
#
sub worth-in-trade (KeyBag $x --> Int) is export { $x ∙ %WORTH }





#
# some simple structures and access functions to determine
# which animals are (in principle) available for for mutual 
# exchange, without considering what's available in the 
# stock (or in another player's posse) at the moment.
#


sub is-forsale  (Str $x)   {  %RANK.exists($x)  }
sub animal-rank (Str $x)   {  %RANK{$x}         }

sub next-forsale (Str $x)  {  my $n = animal-rank($x); %iRANK{ ++$n } }
sub prev-forsale (Str $x)  {  my $n = animal-rank($x); %iRANK{ --$n } }
sub exchange     (Str $x)  {  %EXCHANGE{$x}  }

sub combify (Str $x) is export {
    say "combify($x) ..";
    die "can't combify '$x' - not for sale!"    
        unless is-forsale($x);

    return %T{$x}.clone if %T.exists($x); 
    my $y = exchange($x);
    if ($y)  {
        return [ "spin($x => $y)" ];
    }
    else {
        return Nil
    }
}

sub combi (Str $s) is export {
    return %T{$s} // combify($s) 
}

sub show-secret-structs is export {
    say "T = ", %T;
    say "RANK  = ", %RANK;
    say "iRANK = ", %iRANK;
    say "animal-rank  = ", hash map -> $k { $k => animal-rank($k)  }, @forsale;
    say "next-forsale = ", hash map -> $k { $k => next-forsale($k) }, @forsale;
    say "prev-forsale = ", hash map -> $k { $k => prev-forsale($k) }, @forsale;
    say "exchange     = ", hash map -> $k { $k => exchange($k)     }, @animals;
}




=begin END

hmm:

    say "exchange     = ", hash @animals Z=> exchange($_);

yields:

    Nominal type check failed for parameter '$a'; expected Str but got Any instead


            $k => "boo [$k]" 


    $x eq 'd' ?? animal-rank('p') !! 
    $x eq 'D' ?? animal-rank('c') !!  $RANK{$x}

