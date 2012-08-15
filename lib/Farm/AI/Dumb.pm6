#
# basically the same as carl's original Example strategy,
# except that it emits a trade ( r6 => s ) that we're rather
# more likely to see in the first few turns of a simulation.
# 
class Farm::AI::Dumb {
    has Str $.player;

    has %!t = {
        type => "trade",
        with => "stock",
        selling => { rabbit => 6 },
        buying  => { sheep => 1 },
    }

    method trade(%p, @e) {
        return %!t;
    }

    method accept(%p, @e, $who) {
        return Bool.roll 
    }
}

