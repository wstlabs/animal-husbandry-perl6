use v6;
use KeyBag::Deco;
use Farm::AI::Util;

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
role Farm::AI::Bag::Stringy  {
    method Str()  {
        stringify(self.hash)
    }
}

role Farm::AI::Bag::Worthy {
    method worth {
        self ∙ %weights;
    }
}


class Farm::AI::Posse 
is    KeyBag::Deco 
does  Farm::AI::Bag::Stringy
does  Farm::AI::Bag::Worthy  {}

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
multi sub posse()     is export { Farm::AI::Posse.new() } 
multi sub posse($arg) is export {
    given $arg {
        when Str                                     { Farm::AI::Posse.new(hashify($arg)) }
        when Set | KeySet | Associative | Positional { Farm::AI::Posse.new($arg)          }
        default                                      { die "signature not supported"      } 
    }
}

=begin END

sub posse(*@a) is export {
    Farm::AI::Posse.new(|@a);
}



does  Farm::AI::Bag::Stringy[ BEGIN { 'r','s','p','c','h','d','D' } ] 

role Farm::AI::Bag::Stringy[@x]  {
    my %x is ro = map -> $k { $k => 1 }, @x;
    method stringy-symbols { @x }
    method Str()  {
        my @t = map -> $k {
            my $n = self.at_key($k);
            $n > 0 ?? 
                $n > 1 ?? "$k$n" !! $k 
            !! ()
        }, @x; 
        return @t ?? @t.join('') !! $emptyset
    }
}

constant $emptyset = '∅'; # U+2205;

