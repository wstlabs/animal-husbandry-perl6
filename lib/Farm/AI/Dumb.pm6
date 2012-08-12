class Farm::AI::Dumb {
    has Str $.player;
    has %!t = {
        type => "trade",
        with => "stock",
        selling => { sheep => 1 },
        buying  => { rabbit => 6 },
    }

    has Bool $.done is rw;
    method trade(%p, @e) {
        my $roll = Bool.roll;
        unless ($.done)  { say "p = ", %p }
        $.done //= True;
        say "[$.player] t ? $roll; e = {@e.Int}"; 
        my %t = $roll ?? %!t !! Nil;
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


