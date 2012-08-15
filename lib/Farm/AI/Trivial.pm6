use Farm::AI::Strategy;

#
# equiavalent to the 'Dumb' strategy, but refactored to use the
# abstract Strategy class as a base.
#
class Farm::AI::Trivial
is    Farm::AI::Strategy  {

    method find-trade()  {
        my $pair = ( 'r6' => 's' );
        return ( stock => $pair )
    }

    method eval-trade($who)  {
        return Bool.roll
    } 

}

=begin END

