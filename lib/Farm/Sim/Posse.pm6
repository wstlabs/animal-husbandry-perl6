use v6;
use KeyBag::Deco;
use KeyBag::Ops;
use Farm::Sim::Util;
use Farm::Sim::Util::HashTup;

my @frisky is ro = frisky-animals();

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
        stringify-animals(self.hash)
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
    #    my $roll = $dice.roll;
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
        breed-strict self, keybag(hashify($r)) 
    }
    multi method breed (KeyBag $r) {
        breed-strict self, $r
    }

    #
    # A Posse's nominal trading value, expressed in terms of rabbits.
    #
    method worth { worth-in-trade(self) }


    #
    # A Posse's "base" is simply a list of basic animal types in its possession 
    # which contribute towards victory -- in other words, a Boolean slice through
    # the set <r s p c h>, expressed as an ordered list. 
    #
    # While a Posse's "need" is a list of basic animal types which contribute 
    # towards victory, but which it does not yet possess.
    #
    # Naturally, these two lists are complements of each other.
    #
    method base  { grep {  self.exists($_) }, @frisky } 
    method need  { grep { !self.exists($_) }, @frisky }

    # provides the number of distinct animal types in our possession.
    #
    # would seem superflous, given that it's equivalent to either .keys or .base
    # coerced to Int context.  however, it seems to behave more nicely with any()
    # junctions, such that our test for many-to-many-ness reduces simply to 
    #
    #    .&fail("Many-to-many") unless any($buy,$sell).width == 1;
    #   
    # provided that we've verified earlier that all($buy,$sell).width > 0. 
    method width { self.keys.Int }


    # returns a hash representation of our multiset, keyed by long animal names.  
    # used for interface compatiblity with the original game.
    method longhash { short2long(self.hash) }

    #
    # a boolean comparison method which basically says we can subtract  
    # the argument from the invocant without losing breeding diversity.
    # 
    # Examples:
    # e.g. { c2p3 > c }  but not { c2p3 > p3 }, even though both ⊂ c2p3
    # p3s4 > p2s2 but not p3 or ps4
    #
    multi method contains-diversely (Farm::Sim::Posse $p --> Bool)  {
        # for self.base -> $k {
        #     return False if self.at_key($k) > $p.at_key($k)
        # }
        return True
    }

    # (2,3) - (1,0) = (1,2) => yes 
    # (2,3) - (0,3) = (2,0) => no
    #
    # (3,4) - (2,2) = (1,2) => yes
    # (3,4) - (3,0) = (0,4) => no
    # (3,4) - (1,4) = (2,0) => no 
    #
    # D2c2 > Dc but not D2 c2
    # D2c3 > Dc, c2 but not D2 
    #
    # (2,2) - (1,1) = (1,1) => yes 
    # (2,2) - (0,2) = (2,0) => no 
    # (2,2) - (2,0) = (0,2) => no 
    #
    # (2,3) - (1,1) = (1,2) => yes 
    # (2,3) - (0,2) = (2,1) => yes 
    # (2,3) - (2,0) = (0,3) => no 

}


#
# XXX we'd also like to provide overrides for .gist and .perl, but something's 
# not quite working.
#
# multi method gist(Any:D $ : --> Str) { "posse({ self.pairs>>.gist.join(', ') })" }
# multi method perl(Any:D $ : --> Str) { 'Farm::Sim::Posse.new(' ~ self.hash.perl ~ ')' }

#
# A convenient 'quasi-constructor', analagous to set(), keybag(), etc. 
# Note however that we tweak the signatures somewhat -- in order to allow Str
# arguments, it seems we need to disallow tuple-like contexts (and we'd rather
# just tweak those here, than redo the whole contstructor).  So at any rate, 
# constructions like 
#
#    posse( r => 1 ) 
#
# aren't allowed; so just use posse({ r => 1 }) instead.
#
multi sub posse()      is export { Farm::Sim::Posse.new() } 
multi sub posse($arg)  is export {
    given $arg {
        when Str                                     { Farm::Sim::Posse.new(hashify-animals($arg)) }
        when Set | KeySet | Associative | Positional { Farm::Sim::Posse.new($arg)          }
    }
}
sub posse-from-long(%h) is export { posse(long2short(%h)) }


# go forth and multiply!
multi sub infix:<⚤>(Farm::Sim::Posse $x, Any $r --> Farm::Sim::Posse) is export {  $x.breed($r) }


=begin END

constant %weights = { 
    r => 1, s => 6, p => 12, c => 30, h => 72,
    d => 6, D => 12 
};


# use X::Farm::Sim;
# X::Farm::Sim::Dice::Invalid::Roll.new( r => $r);

