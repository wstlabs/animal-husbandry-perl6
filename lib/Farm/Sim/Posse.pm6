use v6;
use KeyBag::Deco;
use KeyBag::Ops;
use Farm::Sim::Util;

#
# A 'Posse' is any collection of animals that we might find together 
# in some 'stable' configuration -- that is, without bloodshed immediately 
# ensuing (so we exclude wolves and foxes.)
#
# In other words, any meaningful configuration of animals that we might
# find together in between 'atomic' actions can be represented as a Posse. 
# So Player / Stock state, as well as components of proposed trades (valid
# or otherwise) can be represented as Posse objects.
#

constant %weights = { 
    r => 1, s => 6, p => 12, c => 30, h => 72,
    d => 6, D => 12 
};

# note that stringify() will blow up if we've managed
# to stuff invalid animal syms into our keybag somehow. 
role Farm::Sim::Bag::Stringy  {
    method Str()  {
        stringify(self.hash)
    }
}

role Farm::Sim::Bag::Worthy {
    method worth {
        self ∙ %weights;
    }
}

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
        my $p = posse($x);
        my $s = KeySet.new($p);
        self.inter($s).sum($p) / 2
    }
}

class Farm::Sim::Posse 
is    KeyBag::Deco 
does  Farm::Sim::Bag::Stringy
does  Farm::Sim::Bag::Worthy  
does  Farm::Sim::Bag::Frisky  {
    #
    # XXX we'd like to override these, but something's not quite working.
    #
    # multi method gist(Any:D $ : --> Str) { "posse({ self.pairs>>.gist.join(', ') })" }
    # multi method perl(Any:D $ : --> Str) { 'Farm::Sim::Posse.new(' ~ self.hash.perl ~ ')' }
}

# a convenient 'quasi-constructor', analagous to set(), keybag(), etc. 
# note however that we tweak the signatures somewhat -- in order to allow Str
# arguments, it seems we need to disallow tuple-like contexts (and we'd rather
# just tweak those here, than redo the whole contstructor).  so in any case, 
# constructions like 
#
#    posse( r => 1 ) 
#
# are now forbidden; just use posse({ r => 1 }) instead.
# XXX make an exception for the default case to throw (instead of just having it die). 
multi sub posse()     is export { Farm::Sim::Posse.new() } 
multi sub posse($arg) is export {
    given $arg {
        when Str                                     { Farm::Sim::Posse.new(hashify($arg)) }
        when Set | KeySet | Associative | Positional { Farm::Sim::Posse.new($arg)          }
        default                                      { die "signature not supported"       } 
    }
}

# go forth and multiply!
multi sub infix:<⚤>(Farm::Sim::Posse $x,Any $y --> Farm::Sim::Posse) is export {  $x.spawn($y) }


=begin END

    #
    # XXX we'd like to represent the operation up in .spawn() as
    #
    #    ( self ⊎ $x ) / 2 
    #
    # but doing so yields
    #
    #     Calling 'infix:<⊎>' will never work with argument types (Farm::Sim::Bag::Frisky, Any) 
    #

    multi method spawn (Str $s) {
        self.spawn( self.new($s) )
    }


    multi method spawn (Any $x) {
        say ".spawn self        = ", self.WHICH, " => ", self.Str(), " = ", self;
        say ".spawn x           = ", $x.WHICH,   " => $x = ", $x;
        my $s = self.sum($x);
        my $y = $s / 2; 
        say ".spawn self+x      = ", $s.WHICH,   " => $s = ", $s;
        say ".spawn (self+x)/2  = ", $y.WHICH,   " => $y = ", $y;
        return $y;
        # self.sum($x) / 2 
    }

    multi method spawn (Any $x) {
        say ".spawn self        = ", self.WHICH, " => ", self.Str(), " = ", self;
        say ".spawn x           = ", $x.WHICH,   " => $x = ", $x;
        my $z = posse($x);
        say ".spawn z           = ", $z.WHICH,   " => $z = ", $z;
        my $s = self.sum($z);
        my $y = $s / 2; 
        say ".spawn self+z      = ", $s.WHICH,   " => $s = ", $s;
        say ".spawn (self+z)/2  = ", $y.WHICH,   " => $y = ", $y;
        return $y;
        # self.sum($x) / 2 
    }

