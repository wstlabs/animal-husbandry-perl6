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
        # player needs to have at least 'sr6', and the stock 'sd' in order for 
        # this condition to be triggered, of course.  most likely you'll get 
        # "Not enough CP animals", at least until the game has matured a bit. 
        many-to-many => {
            type => "trade", with => "stock",
            selling => { sheep => 1, rabbit => 6 }, 
            buying  => { sheep => 1, small_dog => 1 },
        },
        null-trade => {
            type => "trade", with => "stock",
            selling => { }, buying  => { },
        }
    };

    method trade(%p, @e) {
        my ($name,%t) = %!junk.roll.kv;
        return %t;
    }

    method accept (%p, @e,$t) {
        return Bool.roll
    } 

}

=begin END

        say "::trade[$.player] $name => ",%t;



