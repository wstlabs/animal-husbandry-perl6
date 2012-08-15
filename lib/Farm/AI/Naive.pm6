use Farm::AI::Strategy;
use Farm::Sim::Util::Search;
use Keybag::Ops;

class Farm::AI::Naive
is    Farm::AI::Strategy  {

    method find-trade()  {
        my $S     = self.posse('stock');
        my $P     = self.posse($.player);
        my @need  = $P.need;
        self.trace("S = $S");
        self.trace("P = $P ↦ ", @need); 
        if (@need == 1)  {
            my ($x) = @need;
            self.trace("close [$x]!");
        }  
        for avail-D($S,$P) -> $x  {      
            self.trace("got $x ?") 
        }
        for avail-d($S,$P) -> $x  {      
            self.trace("got $x ?") 
        }
        for @need -> $x {
            self.trace("got $x ?") 
        }
        return Nil;
    }

    method eval-trade($who)  {
        self.trace("p = ", self.p);
        return Bool.roll
    } 

}

=begin END

