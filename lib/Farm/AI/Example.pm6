#
# verbatim from https://gist.github.com/1154298 
# (except for this comment)
#
class Farm::AI::Example {
    has Str $.player;

    method trade(%players, @events) {
        if Bool.roll {
            return {
                type => "trade",
                with => "stock",
                selling => { sheep => 1 },
                buying  => { rabbit => 6 },
            }
        }
        else {
            return;
        }
    }

    method accept(%players, @events, $trader) {
        return Bool.roll;
    }
}
