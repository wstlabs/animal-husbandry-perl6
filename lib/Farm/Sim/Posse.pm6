use v6;
use KeyBag::Deco;
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

role Farm::Sim::Bag::Frisky {
    multi method spawn (Any $x) {
        self.spawn( self.new($x) )
    }
    multi method spawn (KeyBag $b) {
        return Nil
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

# go forth and multiply
multi sub infix:<⚤ >(Farm::Sim::Posse $x,Any $y --> KeyBag) is export {  $x.spawn($y) }


=begin END

    multi method spawn (Str $s) {
        self.spawn( self.new($s) )
    }

sub posse(*@a) is export {
    Farm::Sim::Posse.new(|@a);
}



does  Farm::Sim::Bag::Stringy[ BEGIN { 'r','s','p','c','h','d','D' } ] 

role Farm::Sim::Bag::Stringy[@x]  {
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

