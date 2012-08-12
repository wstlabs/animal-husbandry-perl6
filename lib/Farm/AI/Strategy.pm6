class Farm::AI::Strategy {
    has Str $.player;
    has $.debug = 0;

    method trace(*@a)  { if ($!debug > 1)  { say "[$.player]", @a } }
    method debug(*@a)  { if ($!debug > 2)  { say "[$.player]", @a } }
}

=begin END

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
