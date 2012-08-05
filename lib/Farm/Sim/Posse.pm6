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


#
# a simple stringify role, which we keep contained in a Role so
# we can say ".does(Stringy)", at some point.
#
# note that by design stringify() will throw if we've managed to 
# stuff invalid animal syms into our KeyBag somehow (which can happen
# due to the fact that there's no easy way to provide key constraints
# in early versions of the KeyBag class).
#
role Farm::Sim::Posse::Role::Stringy  {
    method Str()  {
        stringify(self.hash)
    }
}


class Farm::Sim::Posse 
is    KeyBag::Deco 
does  Farm::Sim::Posse::Role::Stringy  {
    #
    # The magical .breed() method, in which we determine the "desired" number 
    # of animals that could (in principle) be provided when a Posse "mates" with 
    # the animals represented in a valid roll of a fox/wolf die pair -- but NOT,
    # at this stage, checking to make sure those animals are actually available 
    # in the Stock.
    #
    # Note that the .breed() method can also be accessed via infix <⚤> operator
    # defined below.  So a typical transation between a player agent $X and a 
    # stock agent $S might go like this:
    #
    #    my $roll = $Dice.roll;
    #    if (! $roll ~~ / [fw] / ) {
    #        my $desired = $X.posse ⚤ $roll;
    #        my $allowed = $desired ∩ $S.posse;
    #        if ($allowed)  {
    #            $X.posse ⊎= $allowed; 
    #            $S.posse ∖= $allowed; 
    #        }
    #    }
    #
    multi method breed (Str $r) {
        # die "invalid dice roll '$r'" unless
        #    $r ~~ m/^ [rspchfwdD] ** 2 $/;
        breed-strict self, posse($r) 
    }
    multi method breed (KeyBag $r) {
        breed-strict self, $r
    }

    #
    # a posse's nominal trading value
    #
    method worth { self ∙ %weights }

}

#
# XXX we'd also like to provide overrides for .gist and .perl, but something's 
# not quite working.
#
# multi method gist(Any:D $ : --> Str) { "posse({ self.pairs>>.gist.join(', ') })" }
# multi method perl(Any:D $ : --> Str) { 'Farm::Sim::Posse.new(' ~ self.hash.perl ~ ')' }

# a convenient 'quasi-constructor', analagous to set(), keybag(), etc. 
# note however that we tweak the signatures somewhat -- in order to allow Str
# arguments, it seems we need to disallow tuple-like contexts (and we'd rather
# just tweak those here, than redo the whole contstructor).  so in any case, 
# constructions like 
#
#    posse( r => 1 ) 
#
# are now forbidden; just use posse({ r => 1 }) instead.
multi sub posse()     is export { Farm::Sim::Posse.new() } 
multi sub posse($arg) is export {
    given $arg {
        when Str                                     { Farm::Sim::Posse.new(hashify($arg)) }
        when Set | KeySet | Associative | Positional { Farm::Sim::Posse.new($arg)          }
    }
}

# go forth and multiply!
multi sub infix:<⚤>(Farm::Sim::Posse $x, Any $r --> Farm::Sim::Posse) is export {  $x.breed($r) }


=begin END

# use X::Farm::Sim;
# X::Farm::Sim::Dice::Invalid::Roll.new( r => $r);
