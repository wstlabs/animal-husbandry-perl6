use Farm::AI::Strategy;
use Farm::Sim::Util::Search;
use Farm::Sim::Util;
use Keybag::Ops;

class Farm::AI::Naive
is    Farm::AI::Strategy  {

    method find-trade()  {
        my $S     = self.posse('stock');
        my $P     = self.posse($.player);
        my @need  = $P.need;
        my @gimme = $P.gimme;
        my $wish  = $P.wish;
        self.trace("S = $S");
        self.trace("P = $P ↦ wish = $wish, need = ",@need,", gimme =",@gimme); 
        if ($wish)  {
            self.trace("wish [$wish]!");
        }  
        for avail-D($S,$P) -> $x  {      
            self.trace("Doggy $x ?") 
        }
        for avail-d($S,$P) -> $x  {      
            self.trace("doggy $x ?") 
        }
        for @gimme -> $x {
            next unless worth($x) <= $P.worth;
            self.trace("gimme $x ?") 
        }
        return Nil;
    }

    method eval-trade($who)  {
        self.trace("p = ", self.p);
        return Bool.roll
    } 

}

=begin END

