use Farm::AI::Strategy;

class Farm::AI::Bogus 
is    Farm::AI::Strategy  {

    has %!t = {
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
        mull-trade => {
            type => "trade", with => "stock",
            selling => { }, buying  => { },
        }
    };

    multi method find-trade()  {
        self.trace("find-trade p = ", self.p);
        self.trace("find-trade me = ", self.posse($.player)); 
        my $roll = %!t.keys.roll; 
        my %t = %!t{$roll};
        self.trace("::find-trade $roll => ",{%t});
        return %t;
    }

    multi method eval-trade(Str $who)  {
        self.trace("::eval-trade [$.player] p = ", self.p);
        return Bool.roll
    } 

}

=begin END
    method trade(%p, @e) {
        self.trace("p = ", {%p}) unless $.done //= True;
    }

