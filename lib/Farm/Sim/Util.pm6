use v6;
use KeyBag::Deco;
use KeyBag::Ops;
use Farm::Sim::Util::HashTup; 


constant @forsale  = <r s p c h>;          # sometimes,
constant @domestic = <r s p c h d D>;      # it's actually OK
constant @animals  = <r s p c h d D f w>;  # to repeat yourself.

my %DOMESTIC is ro  = hash @domestic Z=> True xx @domestic;
my %RANK     is ro  = hash @forsale Z=> 1..5;
my %iRANK    is ro  = %RANK.invert; 

constant %STOCK = {
    r => 60,  s => 24,  p => 20,  c => 12,  h => 6,
              d =>  4,            D =>  2
};

sub stock-hash() is export { %STOCK }


#
# XXX obviously the next two hashes are related - we'd rather skip
# the task of deriving one from the other, but it might be a good idea 
# to do some QA to verify that they're mutually in synch. 
#
# Until then, it's pretty easy to check the numbers by visually aligning
# their respective columns, for which purpose we've tweaked the spacing
# somewhat.
#
constant %EXCHANGE = { 
    s => 'r6', p => 's2', c => 'p3', h => 'c2', 
    d => 's',             D => 'c' 
};
constant %WORTH = {
    r => 1,
    s => 6,    p => 12,   c => 36,   h => 72,
    d => 6,               D => 36
};

my %T is rw = ( 
    r => [],
    s => ['r6']
);

# like hashify, but restricted that keys are valid animals.
sub hashify-animals(Str $s) is export { 
    hashify($s,%DOMESTIC)
}

sub stringify-animals(%h) is export  {
    stringify(%h,@domestic)
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

=begin END

sub combify (Str $x) is export {
    say "combify('$x') ..";
    die "can't combify '$x' - not for sale!"    
        unless is-forsale($x);

    return %T{$x}.clone if %T.exists($x); 
    my $t = exchange($x);
    if ($t)  {
        my ($y,$k) = tup2pair($t);
        return [ "spin($x => $y^$k)" ];
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






hmm:

    say "exchange     = ", hash @animals Z=> exchange($_);

yields:

    Nominal type check failed for parameter '$a'; expected Str but got Any instead


            $k => "boo [$k]" 


    $x eq 'd' ?? animal-rank('p') !! 
    $x eq 'D' ?? animal-rank('c') !!  $RANK{$x}

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

sub stringify-animals(%h) is export  {
    # say "::stringify-animals:  h = ", %h;
    # say "::stringify-animals:  domestic = ", @domestic; 
    # my @wtf = ('r','s','f');
    # my @wtf = ('r','s','f');
    # my $s = stringify(%h, @wtf); 
    # say "::stringify-animals:  s = ", $s; 
    stringify(%h,@domestic)
}


