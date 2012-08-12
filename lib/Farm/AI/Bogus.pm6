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

    has Bool $.done is rw;
    method trade(%p, @e) {
        self.trace("p = ", {%p}) unless $.done //= True;
        my $roll = %!t.keys.roll; 
        my %t = %!t{$roll};
        self.trace("$roll => ",{%t});
        return %t;
    
    }

    method accept(%p, @e, $who) {
        my $roll = Bool.roll;
        # say "[$.player] a $who ? e = {@e.Int}"; 
        # say "[$.player] r : $roll";
        return $roll
    }
}

