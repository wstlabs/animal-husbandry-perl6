use Farm::AI::Strategy;
use Keybag::Ops;

class Farm::AI::Empty
is    Farm::AI::Strategy  {

    method find-trade()  {
        return 'r6' => 's'
    }

    method eval-trade($who)  {
        self.trace("p = ", self.p);
        return Bool.roll
    } 

}

=begin END

