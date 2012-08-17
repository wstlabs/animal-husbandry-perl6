#
# a highly bogus strategy which intentially spews out mostly failing trades
#
use Farm::AI::Strategy;

class Farm::AI::Bogus  {
    has Str $.player;
    has %!junk = {
        legit => {
            type => "trade", with => "stock",
            selling => { sheep => 1 }, buying  => { rabbit => 6 },
        },
        empty-type => {
            with => "stock",
            selling => { sheep => 1 }, buying  => { rabbit => 6 },
        },
        empty-with => {
            type => "trade",
            selling => { sheep => 1 }, buying  => { rabbit => 6 },
        },
        invalid-type => {
            type => "bogus-type", with => "stock",
            selling => { sheep => 1 }, buying  => { rabbit => 6 },
        },
        invalid-player => {
            type => "trade", with => "bogus-player",
            selling => { sheep => 1 }, buying  => { rabbit => 6 },
        },
        unequal-trade => {
            type => "trade", with => "stock",
            selling => { sheep => 2 }, buying  => { rabbit => 6 },
        },
        many-to-many => {
            type => "trade", with => "stock",
            selling => { sheep => 1, rabbit => 6, pig => 2 }, buying  => { cow => 1 },
        },
        null-trade => {
            type => "trade", with => "stock",
            selling => { }, buying  => { },
        }
    };

    method trade(%p, @e) {
        say "::trade[$.player] .."; 
        my ($name,%t) = %!junk.roll.kv;
        say "::trade[$.player] $name => ",%t;
        return %t;
    }

    method accept (%p, @e,$t) {
        return Bool.roll
    } 

}

=begin END



