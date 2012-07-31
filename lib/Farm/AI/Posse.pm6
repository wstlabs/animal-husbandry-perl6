use v6;
use KeyBag::Deco;

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

constant $emptyset = '∅'; # U+2205;
constant %weights = { 
    r => 1, s => 6, p => 12, c => 30, h => 72,
    d => 6, D => 12 
};

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

role Farm::AI::Bag::Worthy {
    method worth {
        666 
        # self · %weights
    }
}


class Farm::AI::Posse 
is    KeyBag::Deco 
does  Farm::AI::Bag::Stringy[ BEGIN { 'r','s','p','c','h','d','D' } ] 
does  Farm::AI::Bag::Worthy {}

=begin END



