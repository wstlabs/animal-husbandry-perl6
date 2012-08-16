use Farm::Sim::Util;
use Farm::AI::Strategy;
use Farm::AI::Search;
use Keybag::Ops;

class Farm::AI::Naive
is    Farm::AI::Strategy  {

    method find-trade  {
        my %trade = self.find-stock-trade;
        %trade ?? { with => 'stock', %trade } !! Nil
    }

    method find-stock-trade  {
        my $S     = self.posse('stock');
        my $P     = self.posse($.player);
        my @need  = $P.need;
        my @gimme = $P.gimme;
        my $wish  = $P.wish;
        self.trace("S = $S");
        self.trace("P = $P ↦ need = ",@need," ↦ $wish, [",@gimme,"]"); 
        if (my $x = $P.wish)  {
            self.debug("wish [$x]!");
            if ($x ∈ $S)  {
                my @t = find-admissible-trades($P,$x);
                self.trace("wish: $P,$x => ", @t);
            }  else  {
                self.trace("wish [$x] not available!");
            }
            
        }  
        self.trace("dogful: ", avail-dogs($S,$P));
        for avail-D($S,$P) -> $x  {
            self.debug("doggy $x ?");
            my @t = find-admissible-trades($P,$x);
            if (@t)  {
                my $y = @t.pick;
                self.trace("doggy: $P,$x => ", @t, " => $y!");
                return { selling => $y, buying => $x } 
            }
            else  { self.trace("doggy: $P,$x => ", @t) }
        }
        for avail-d($S,$P) -> $x  {
            self.debug("doggy $x ?");
            my @t = find-admissible-trades($P,$x);
            if (@t)  {
                my $y = @t.pick;
                self.trace("doggy: $P,$x => ", @t, " => $y!");
                return { selling => $y, buying => $x } 
            }
            else  { self.trace("doggy: $P,$x => ", @t) }
        }
        for @gimme -> $x {
            self.debug("gimme $x ?");
            my @t = find-admissible-trades($P,$x).grep({!m/[dD]/});
            if (@t)  {
                my $y = @t.pick;
                self.trace("gimme: $P,$x => ", @t, " => $y!");
                return { selling => $y, buying => $x } 
            }
            else  { self.trace("doggy: $P,$x => ", @t) }
        }
        return Nil;
    }

    method eval-trade($who)  {
        self.trace("p = ", self.p);
        return Bool.roll
    } 

}

=begin END

