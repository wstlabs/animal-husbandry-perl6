class Farm::AI::Dumb {
    has Str $.player;
    has $.debug = 0;

    has %!t = {
        type => "trade",
        with => "stock",
        selling => { rabbit => 6 },
        buying  => { sheep => 1 },
    }

    method info(*@a)   { if ($!debug > 0)  { say @a } }
    method trace(*@a)  { if ($!debug > 1)  { say @a } }
    method debug(*@a)  { if ($!debug > 2)  { say @a } }

    has Bool $.done is rw;
    method trade(%p, @e) {
        self.trace("::trade [$.player] p = ", {%p})
            unless $.done //= True;
        # my $roll = Bool.roll;
        # say "[$.player] t ? $roll; e = {@e.Int}"; 
        # my %t = $roll ?? %!t !! Nil;
        my %t = %!t;
        self.trace("::trade [$.player] t = ", {%t});
        return %t;
    
    }

    method accept(%p, @e, $who) {
        my $roll = Bool.roll;
        # say "[$.player] a $who ? e = {@e.Int}"; 
        # say "[$.player] r : $roll";
        return $roll
    }
}


=begin END

    sub nice (@e) {
        my $n = @e;
        return "n = $n; {@e.perl}"
    }

