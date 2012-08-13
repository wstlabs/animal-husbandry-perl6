use Farm::AI::Strategy::Util;

class Farm::AI::Strategy {
    has Str $.player;

    has $!debug = 2;
    method trace(*@a)  { if ($!debug > 1)  { say "++[$.player]", @a } }
    method debug(*@a)  { if ($!debug > 2)  { say "++[$.player]", @a } }

    has @!e;
    has %!p;
    method p() { %!p }
    method posse (Str $name)  { %!p{$name}.clone if %!p.exists($name) }
    method players { %!p.keys.sort }

    method trade(%p, @e) {
        self.trace("trade p = ", {%p});
        # say "::trade p = ", {%p};
        self.update(%p, @e);
        # say "::trade find .."; 
        my %t = self.find-trade(); 
        self.trace("trade t = ", {%t});
        # say "trade t = ", {%t};
        return %t;
    }

    method accept(%p, @e, $who) {
        self.trace("accept p = ", {%p});
        self.update(%p, @e);
        my $stat = self.eval-trade($who);
        self.trace("accept stat = ", $stat);
        return $stat
    }

    multi method find-trade()          { say "::find-trade not the droids you're looking for .." }
    multi method eval-trade()          { say "::eval-trade not the droids you're looking for .." }
    # method find-trade()          { die "not implemented in abstract class"; }
    # method eval-trade(Str $who)  { die "not implemented in abstract class"; }

    method update(%p, @e) {
        %!p = inflate-posse-hash(%p);
        @!e = @e; # XXX slow! 
    }
}

=begin END

    # self.trace("::find-trade [$.player] p = ", {!%p})

    sub inflate-posse-hash(%p)  {
        hash map -> $k,$v { 
            $k => posse-from-long($v)
        }, %p.kv
    } 


    }
}


=begin END
