use Farm::Sim::Posse;

class Farm::AI::Strategy {
    has Str $.player;

    has $.debug = 0;
    method trace(*@a)  { if ($!debug > 1)  { say "[$.player]", @a } }
    method debug(*@a)  { if ($!debug > 2)  { say "[$.player]", @a } }

    sub inflate-posse-hash(%p)  {
        hash map -> $k,$v { 
            $k => posse-from-long($v)
        }, %p.kv
    } 

    has @!e;
    has %!p;
    method p() { %!p }
    method posse (Str $name)  { %!p{$name}.clone if %!p.exists($name) }
    method players { %!p.keys.sort }

    method trade(%p, @e) {
        self.trace("::trade [$.player] p = ", {%p});
        %!p = inflate-posse-hash(%p);
        @!e = @e; # XXX slow! 
        my %t = self.find-trade; 
        self.trace("::trade [$.player] t = ", {%t});
        return %t;
    
    }

    method find-trade()  {
        die "not implemented in abstract class";
        # self.trace("::find-trade [$.player] p = ", {!%p})
    }
}

=begin END

    method accept(%p, @e, $who) {
        my $roll = Bool.roll;
        # say "[$.player] a $who ? e = {@e.Int}"; 
        # say "[$.player] r : $roll";
        return $roll
    }
}


=begin END
