use v6;
use KeyBag::Deco;
use KeyBag::Ops;
use Farm::Sim::Util::HashTup; 


# animals which can...
constant @frisky     = <r s   p c   h    >;  # breed, or count towards a win
constant @domestic   = <r s d p c D h    >;  # cohabitate or be traded
constant @valid-roll = <r s   p c   h f w>;  # occur on a valid die roll 
constant @animals    = <r s d p c D h f w>;  # all animals together 

my %ANIMALS   is ro  = hash @animals    Z=> 1..*; 
my %DOMESTIC  is ro  = hash @domestic   Z=> 1..*; 
my %VALIDROLL is ro  = hash @valid-roll Z=> 1..*; 
my $VALIDROLL is ro  = KeyBag.new(%VALIDROLL);

constant %STOCK = {
    r => 60, s => 24, p => 20, c => 12, h => 6,
    d =>  4, D =>  2
};

# XXX some cheap workarounds for exporting data structs,
# which don't seem to export easily like subs do.
sub stock-hash()          is export { %STOCK }
sub frisky-animals()      is export { @frisky }
sub domestic-animals()    is export { @domestic }
sub is-domestic-animal( Str $x where $x.chars == 1 )  is export { 
    %DOMESTIC.exists($x) 
}
sub is-domestic-posse-str(  Str $s where $s.chars  > 0 )  is export { 
    $s eq '∅' || $s ~~ m/^ (<[rspdcDh]>\d*)+ $/ # XXX make non-capturing 
}

my %LONG2SHORT is ro = < 
    rabbit    r   sheep   s   pig p   cow  c  horse h  
    small_dog d   big_dog D   fox f   wolf w
>;
my %SHORT2LONG is ro = %LONG2SHORT.invert; 

sub long2short (%h) is export {
    hash map -> $long,$v {
        my $x    = %LONG2SHORT{$long} // die "invalid long animal '$long'"; 
        $x => $v
    }, %h.kv
}

sub short2long (%h) is export {
    hash map -> $x,$v {
        my $long = %SHORT2LONG{$x}    // die "invalid short animal '$x'"; 
        $long => $v
    }, %h.kv
}




# like hashify, but restricted that keys are valid animals.
sub hashify-animals(Str $s) is export { 
    hashify($s,%ANIMALS)
}

# print a posse string as a tuple, MSA (most significant animal) first, 
# e.g.:  'sr3', 'Dcp3s4r6', etc.  empty posses are printed as the empty 
# set sign '∅'.
sub stringify-animals(%h) is export  {
    stringify(%h,reverse @domestic)
}


# paranoid version of the breeding op; rejects any symbol
# that's not in a valid dice roll.
#
# XXX possible bug around the fact that 
#
#    all('∅'.keys) ∈ any(Bag)?
#
# meaning that if you feed it the empty set string as an  
# invalid die roll, it will slip through as a false negative!
#
multi sub breed-strict (KeyBag $x, KeyBag $r) is export {
    die "invalid roll" unless all($r.keys) ∈ $VALIDROLL; 
    breed-naive($x,$r)
}

#
# an "unsafe", purely set-theoretic breeding operation with no input 
# constraints.  kept as a separate (private) function simply to represent 
# the basic breeding operation as simply as possible. 
#
# note that although the signatures ask for both inputs to be KeyBags,
# the eventual type that's returned is whatever type $x happens to be 
# (so if it's a Posse, we'll get a Posse object as a result).
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
# actual Posse object; it can also be just a plain old KeyBag, and 
# the trading measure will be computed in the natural way, ignoring
# non-animal keys.  
#
constant %WORTH = {
    r => 1, s => 6, p => 12, c => 36, h => 72,
    d => 6,                  D => 36
};
multi sub worth (KeyBag $x --> Int) is export { $x ∙ %WORTH }
multi sub worth (Str $x    --> Int) is export { 
                '∅' eq $x  ??         0  !! 
    is-domestic-animal($x) ?? %WORTH{$x} !! 
    die "not a valid (domestic) animal symbol"
}
# XXX as a slight bug, currently this works on single-char animal
# symbols only.  this is because currently it's inconvenient to provide
# a function which evaluates the worth of a posse-like string, with or 
# without converting it to Posse object, without creating a dependency 
# loop between the two modules.




=begin END

# multi sub worth-in-trade (KeyBag $x --> Int) is export { $x ∙ %WORTH }
# multi sub worth-in-trade (Str $x    --> Int) is export { 

my %LONG2SHORT is ro = {
    rabbit    => 'r', sheep   => 's', pig => 'p', cow  => 'c', horse  => 'h',
    small_dog => 'd', big_dog => 'D', fox => 'f', wolf => 'w',
};

# my $FRISKY    is ro  = KeyBag.new( hash @frisky     Z=> True xx @frisky );

constant %STOCK = {
    r => 60,  s => 24,  p => 20,  c => 12,  h => 6,
              d =>  4,            D =>  2
};

my %RANK     is ro  = hash @frisky Z=> 1..5;
my %iRANK    is ro  = %RANK.invert; 

constant %EXCHANGE = { 
    s => 'r6', p => 's2', c => 'p3', h => 'c2', 
    d => 's',             D => 'c' 
};

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


