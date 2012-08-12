use Farm::AI::Strategy;

class Farm::AI::Bogus 
is    Farm::AI::Strategy  {

    has %!t = {
        legit => {
            type => "trade",
            with => "stock",
            selling => { sheep => 1 },
            buying  => { rabbit => 6 },
        },
        invalid-type => {
            type => "bogus-type",
            with => "stock",
            selling => { sheep => 1 },
            buying  => { rabbit => 6 },
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

