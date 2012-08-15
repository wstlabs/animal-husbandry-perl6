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
        if (my $x = $P.wish)  {
            self.debug("wish [$x]!");
            if ($x ∈ $S)  {
                my @t = find-admissible-trades($P,$x);
                self.trace("wish: $x => ", @t);
            }  else  {
                self.trace("wish [$x] not available!");
            }
            
        }  
        for avail-D($S,$P) -> $x  {
            self.debug("doggy $x ?");
            my @t = find-admissible-trades($P,$x);
            self.trace("doggy: $x => ", @t);
        }
        for avail-d($S,$P) -> $x  {
            self.debug("doggy $x ?");
            my @t = find-admissible-trades($P,$x);
            self.trace("doggy: $x => ", @t);
        }
        for @gimme -> $x {
            self.debug("gimme $x ?");
            my @t = find-admissible-trades($P,$x);
            self.trace("gimme: $x => ", @t);
        }
        return Nil;
    }

    method eval-trade($who)  {
        self.trace("p = ", self.p);
        return Bool.roll
    } 

}

=begin END

