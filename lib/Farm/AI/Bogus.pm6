class Farm::AI::Bogus {
    has Str $.player;

    has %!t = {
        legit => {
            type => "trade",
            with => "stock",
            selling => { sheep => 1 },
            buying  => { rabbit => 6 },
        },
        bogus => {
            type => "bogus",
            with => "stock",
            selling => { sheep => 1 },
            buying  => { rabbit => 6 },
        }
    };

    has Bool $.done is rw;
    method trade(%p, @e) {
        my $roll = %!t.keys.roll; 
        unless ($.done)  { say "p = ", %p }
        $.done //= True;
        say "[$.player] t ? $roll; e = {@e.Int}"; 
        my %t = $roll ne 'empty' ?? %!t{$roll} !! Nil;
        say "[$.player] r : ",%t; 
        return %t;
    
    }

    method accept(%p, @e, $who) {
        my $roll = Bool.roll;
        say "[$.player] a $who ? e = {@e.Int}"; 
        say "[$.player] r : $roll";
        return $roll
    }

    sub nice (@e) {
        my $n = @e;
        return "n = $n; {@e.perl}"
    }
}


