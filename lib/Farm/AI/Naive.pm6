use Farm::AI::Strategy;
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
        for $S{'D'}...1 -> $k  {      
            self.trace("got D$k ?") 
        }
        for $S{'d'}...1 -> $k  {      
            self.trace("got d$k ?") 
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

