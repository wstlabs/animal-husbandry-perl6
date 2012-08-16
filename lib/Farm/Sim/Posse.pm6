use v6;
use KeyBag::Deco;
use KeyBag::Ops;
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

    #
    # a boolean comparison method which basically says that, assuming
    # we can (validly) subtract the argument from the invocant, that we
    # can do so without breeding diversity.
    # 
    # Examples:
    # e.g. { c2p3 > c }  but not { c2p3 > p3 }, even though both ⊂ c2p3
    # p3s4 > p2s2 but not p3 or ps4
    #
    # Note that a True output on this relation does -not- imply that
    # we're a containing superset of the argument (or RHS).  There are 
    # actually two separate reasons for this:
    #
    #  - this comparison is done -only- on the @frisky set, i.e. <rspch>,
    #    and completely ignores keys in the set <dDfw>. 
    #
    #  - even within the @frisky set, the operator is designed to be 
    #    interface-compatible with the usual set-theoretic minus operation,
    #    i.e. it happily allows to consider an argument (RHS) which has 
    #    radix values greater than the LHS (i.e. which would subtract 
    #    to something below zero, were we not rounding up).
    #
    multi method contains-diversely (Farm::Sim::Posse $arg --> Bool)  {
        ?( any(self.radix Z- $arg.radix) <= 0 )
    }

    #
    # some examples illustrating the above; these should be put 
    # in a little unit test, perhaps:
    #
    # c2p3 > c      but not p3        (even though both ⊂ c2p3)
    # p3s4 > p2s2   but not p3,ps4
    #
    # (2,3) - (1,0) = (1,2) => yes 
    # (2,3) - (0,3) = (2,0) => no
    #
    # (3,4) - (2,2) = (1,2) => yes
    # (3,4) - (3,0) = (0,4) => no
    # (3,4) - (1,4) = (2,0) => no 
    #
    # D2c2 > Dc     but not D2,c2
    # D2c3 > Dc,c2  but not D2 
    #
    # (2,2) - (1,1) = (1,1) => yes 
    # (2,2) - (0,2) = (2,0) => no 
    # (2,2) - (2,0) = (0,2) => no 
    #
    # (2,3) - (1,1) = (1,2) => yes 
    # (2,3) - (0,2) = (2,1) => yes 
    # (2,3) - (2,0) = (0,3) => no 
    #

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
multi sub infix:<⚤>(Farm::Sim::Posse $x,              Any $y --> Farm::Sim::Posse)  is export {  $x.breed($y) }
multi sub infix:<⊳>(Farm::Sim::Posse $x,              Any $y --> Bool)              is export {  $x.contains-diversely($y) }
multi sub infix:<⊲>(             Any $x, Farm::Sim::Posse $y --> Bool)              is export {  $y.contains-diversely($x) }

=begin END


# sub circumfix:["⎣","⎦"] (Farm::Sim::Posse $Q, Farm::Sim::Posse $P, Str $x) is export { $Q.avail($P,$x) } 
# sub circumfix:<⌊ ⌋>(Farm::Sim::Posse $Q, Farm::Sim::Posse $P, Str $x) is export { $Q.avail($P,$x) } 
# sub circumfix:<⎣⎦>(Farm::Sim::Posse $Q, Farm::Sim::Posse $P, Str $x) is export { $Q.avail($P,$x) } 
# ===SORRY!===
# Unable to find starter and stopper from ''
# sub circumfix:["‹","›x"]($e){$e.floor}






