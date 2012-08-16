use Farm::AI::Strategy;

#
# equiavalent to the 'Dumb' strategy, but refactored to use the
# abstract Strategy class as a base.
#
class Farm::AI::Trivial
is    Farm::AI::Strategy  {

    has %!t = {
        with => "stock",
        selling => "r6",
        buying  => "s" 
    }

    method find-trade()  {
        return %!t;
    }

    method eval-trade($who)  {
        return Bool.roll
    } 

}

=begin END

