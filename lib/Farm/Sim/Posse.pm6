use v6;
use KeyBag::Ops;
use KeyBag::Deco;
use Farm::Sim::Util;
use Farm::Sim::Util::HashTup;

my @frisky is ro = frisky-animals();

#
# a 'Posse' is a collection of the valid animals in the Animal Husbandry
# game, i.e. from the set
#
#    < r s p c h d D f w >
#
# As such they are the generic container for any use case in which we 
# might need to find look at a collection of animals together: 
#
#   - a player's herd (or the animals available in the stock);
#   - a buy / sell component of a proposed or active trade; 
#   - a dice roll 
#
# That said, there are no other constraints imposed on the combination
# of animals in a Posse instance -- so in particular, a Posse does not 
# need to represent a valid instance of any of the above.
#

#
# a simple stringify role, which we keep provide in a Role so
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
    # of animals that could (in principle) be provided when a Posse mates with 
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
    method worth { worth(self) }


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
    method base  { grep {  self.exists($_) }, @frisky.reverse } 
    method need  { grep { !self.exists($_) }, @frisky.reverse }
    method wins  { so self{all @frisky} } 
 

    # returns a 5-element "signature" of the keybag height over the
    # ordered list of breeding symbols, i.e. <hcpsr>.  used e.g. for
    # diversity comparisons.
    method radix { map { self.at_key($_) // 0 }, @frisky.reverse }

    #
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


    # an awkwardly named function which computes a quick upper bound on 
    # the number of animal $x that can be bought by posse $P. 
    #
    # although this number is computable for any domestic animal $x, 
    # generally it's only in cases when when the posse $P wants to buy 
    # a multiple that animal from us, i.e. when $x = 'd'|'D'.
    #
    multi method avail(Str $x, Farm::Sim::Posse $P) is export {
        die "invalid short animal string '$x'" unless is-domestic-animal($x);
        my $k = self.at_key($x) // return 0;
        my $w = $P.worth;
        while (worth($x) * $k > $w) { $k-- }
        $k
    }
    multi method avail(Pair $p)  {
        self.avail($p.kv)
    }

    # as in, "gimme some of these".  a quantifier, typically used after
    # the insurance collection phase, which provides a list of animals that
    # the posse needs, and can potentially afford.  unlike .need and .base,
    # we provide the animals in increasing order, on the theory that those
    # are the ones more natural to search for (all other factors, such as
    # stock availability, being equal).
    #
    # note that the gimme set is mutually exclusive with the wish set;
    # this is to avoid attempting to match the same high-value animal twice. 
    #
    method gimme { 
        my @need = self.need; 
        @need > 1 ?? 
            grep { worth($_) <= self.worth }, @need.reverse 
        !! ()
    } 

    # a quantifier which, if we have one and only one animal left to trade for, 
    # returns that animal, else returns an empty list.  by design, the wish set 
    # is mutually exclusive with the gimme set.
    #
    # note that we don't do cost filtering, like we do for the 'gimme' list.
    # this is in part because if we're at the point where we have enough 
    # diversity in our posse to have 4 of 5 animal types, then we almost 
    # certainly can afford all animal types (even horses) anyway.
    #
    # but also, making this quantifier cost-blind means that it can also be
    # used as a boolean quantifier, to signify that we're close to the winning  
    # state.
    method wish  { 
        my @need = self.need; 
        @need == 1 ?? @need.shift !! () 
    }
}


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


# sorts posses according to their "dog measure."  generally useful only
# when evaluating 'D' trades, which are believed to be always immediately 
# desirable, but ideally at the expense of as few small dogs as possible.
multi sub compare-dogful(Farm::Sim::Posse $x, Farm::Sim::Posse $y --> Order) is export  { 
    $x{'D'} <=> $y{'D'} || $x{'d'} <=> $y{'d'}
}
multi sub compare-dogful(Farm::Sim::Posse $x, Str $y              --> Order) is export  { compare-dogful(     $x,fly($y)) }
multi sub compare-dogful(             Str $x, Farm::Sim::Posse $y --> Order) is export  { compare-dogful(fly($x),$y     ) }
multi sub compare-dogful(             Str $x, Str $y              --> Order) is export  { compare-dogful(fly($x),fly($y)) }


#
# A boolean relation which basically says "if we subtract $y from $x, then the
# diversity of animals remains the same." i.e. equivalent to 
#
#   (($x ∖ $y) ∩ $F).Set eqv ($x ∩ $F).Set 
#
# where $F is the set of "frisky" animals, <r s p c h>.  (and perhaps a bit quicker, 
# the way we compute it here.)  
#
# The relation can be used as a filter to maintain conservative trading strategies.
# See the unit test t/diversity.t for more some sample use cases. 
#
multi sub subtracts-diversely(Farm::Sim::Posse $x, Farm::Sim::Posse $y --> Bool) is export {
    for ($x.radix Z=> $y.radix) -> $p {
        my ($m,$n) = $p.kv;
        return False if $m > 0 && $m-$n <= 0
    }
    return True
}
multi sub subtracts-diversely(Str $x, Farm::Sim::Posse $y --> Bool) is export { subtracts-diversely(  fly($x),$y       ) }
multi sub subtracts-diversely(Farm::Sim::Posse $x, Str $y --> Bool) is export { subtracts-diversely(       $x,fly($y)  ) }
multi sub subtracts-diversely(Str $x, Str $y --> Bool)              is export { subtracts-diversely(  fly($x),fly($y)  ) }

#
# a mechanism for flyweight memoization for posse instances.
#
# should theoretically save a lot on construction costs (both time + space),
# BUT currently at a signficant stability cost, in the instances we return are 
# not only fully mutable, but of course globally persistent. 
#
# however, since the current use case the flyweights are used only for 
# read-only comparisons, we don't need to be too worried about that risk, 
# for the time being.
#
my %F;
multi sub fly(Str $x --> Farm::Sim::Posse) is export {
    # XXX this regex check is perhaps rather expensive, so we may want to bypass it at 
    # some point.  but the point is too provide some kind of a coherent message at the 
    # level of the fly() pseudo-constructor itself, rather than at the level of the 
    # posse() constructor.
    die "can't inflate:  not a domestic posse string" unless is-domestic-posse-str($x);
    %F{$x} //= posse($x)
}

# if we're inadvertently called on an existing instance, we default
# to the identity mapping.  but perhaps we should warn or die, instead.
multi sub fly(Farm::Sim::Posse $x --> Farm::Sim::Posse) is export { $x }

# provide some convenient stats about how many instance we're
# recyclying.  in the future we might make this much more detailed.
sub fly-stats is export { n => %F.keys.Int }




#
# Let's do some ops!
#

#
# For the "subtracts-diversely" relation, we borrow an operator from abstract 
# algebra normally used to mean, respectively:
#
#   X contains Y as a proper normal subgroup      if $X ⊳ $Y
#   X is a proper normal subgroup of Y            if $X ⊲ $Y
#
# but in our case they're deemed to mean:
#
#   X subtracts Y diversely                       if $X ⊳ $Y
#   X subtracts diversely from Y                  if $X ⊲ $Y
#
# Idea being that the operator can be loosely contrived to mean 
#
#   X contains Y in a nice way
#   X is contained by Y in a nice way
# 
# respectively, for some value of "nice."
#  
multi sub infix:<⊳>(Any $x, Any $y --> Bool) is export {  subtracts-diversely($x,$y) }
multi sub infix:<⊲>(Any $x, Any $y --> Bool) is export {  subtracts-diversely($y,$x) }


# compares tuples againsrt their "dogful measure".  sorting over this op brings 
# dogless tuples to the front, and dog-heavy tuples to the back of the list.
multi sub infix:<‹d›>(Any $x,Any $y --> Order) is export { compare-dogful($x,$y) }


#
# And then the magical breeding operator, ⚤ , which provdes the number
# of animals when the Posse on the left "breeds" with the Posse on the
# right (which in our use case always happens to be a dice roll), BUT 
# without yet considering whether these animals are available for
# release by the Stock.  
#
# So in the case of a player $P and a dice roll $r:
#
#     $P ⚤ $r = $P.breed($r) = animals player P gets by mating with r (before
#                              controlling for availability from the Stock).
#
multi sub infix:<⚤>(Farm::Sim::Posse $x, Any $y --> Farm::Sim::Posse)  is export {  $x.breed($y) }


=begin END

