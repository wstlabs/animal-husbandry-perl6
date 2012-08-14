use Farm::AI::Strategy;
use Keybag::Ops;

class Farm::AI::Naive
is    Farm::AI::Strategy  {

    method find-trade()  {
        my $stock = self.posse('stock');
        my $me    = self.posse($.player);
        my @need  = $me.need; 
        self.trace("p = ", self.p);
        self.trace("me = $me, need = ", @need); 
        if (@need == 1)  {
            self.trace("close!");
        }
        for <D2 D> -> $D { 
            self.trace("big $D ?") 
        }
        for <d4 d3 d2 d> -> $d { 
            self.trace("small $d ?") 
        }
        for @need -> $x {
            self.trace("need $x ?") 
        }
        return Nil;
    }

    method eval-trade($who)  {
        self.trace("p = ", self.p);
        return Bool.roll
    } 

}

=begin END

