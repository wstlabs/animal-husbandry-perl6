#
# equiavalent to the 'Dumb' strategy, but refactored to use the
# abstract Strategy class as a base (also, we uniformly reject all 
# offered trades, instead of rolling a dice). 
#
use Farm::AI::Strategy;

class Farm::AI::Empty
is    Farm::AI::Strategy  {

    method find-trade()  {
        return ( stock => ('r6' => 's') )
    }

    method eval-trade($who)  {
        return False 
    } 

}

