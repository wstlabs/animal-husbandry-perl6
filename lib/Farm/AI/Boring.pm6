use Farm::AI::Strategy;
use Keybag::Ops;

#
# basically just does some clumsy 'if-then' switches we came up
# with until we got bored.  not likely to win, but at at least
# survives longer than the Dumb strategy.
#
class Farm::AI::Boring
is    Farm::AI::Strategy  {

    has %!Ds6 = {
        type => "trade", with => "stock",
        buying  => { big_dog => 1 },
        selling => { sheep   => 6 }, 
    };

    has %!Dp3 = {
        type => "trade", with => "stock",
        buying  => { big_dog => 1 },
        selling => { pig     => 3 }, 
    };

    has %!Dc = {
        type => "trade", with => "stock",
        buying  => { big_dog => 1 },
        selling => { cow     => 1 }, 
    };

    has %!cs6 = {
        type => "trade", with => "stock",
        buying  => { cow     => 1 },
        selling => { sheep   => 6 }, 
    };


    has %!cp3 = {
        type => "trade", with => "stock",
        buying  => { cow     => 1 },
        selling => { pig     => 3 }, 
    };

    has %!ds = {
        type => "trade", with => "stock",
        buying  => { small_dog => 1 },
        selling => { sheep     => 1 }, 
    };

    has %!dr6 = {
        type => "trade", with => "stock",
        buying  => { small_dog => 1 }, 
        selling => { rabbit    => 6 }, 
    };

    has %!ps2 = {
        type => "trade", with => "stock",
        buying  => { pig    => 1 },
        selling => { sheep  => 2 }, 
    };

    has %!sr6 = {
        type => "trade", with => "stock",
        buying  => { sheep  => 1 },
        selling => { rabbit => 6 }, 
    };



    method find-trade()  {
        my $me    = self.posse($.player);
        my $stock = self.posse('stock');
        self.trace("p = ", self.p);
        self.trace("me = $me, need = ", $me.need); 
        if ( $stock ∋ 'D'  ) {
            return %!Dc  if $me{'c'} >= 1;
            return %!Dp3 if $me{'p'} >= 3;
            return %!Ds6 if $me{'s'} >= 6; 
        }
        if ( $me{'d'} < 2 ) {
            return %!ds  if $me{'s'} >=  1;
            return %!dr6 if $me{'r'} >=  6;
        }
        if ( $me{'c'} < 1 ) {
            return %!cs6  if $me{'s'} >  8;
            return %!cp3  if $me{'p'} >  3;
        }
        if ( $me{'p'} < 1 ) {
            return %!ps2  if $me{'s'} >= 3;
        }
        if ( $me{'s'} < 1 ) {
            return %!sr6  if $me{'r'} >  6;
        }
        return Nil;
    }

    method eval-trade($who)  {
        self.trace("p = ", self.p);
        return Bool.roll
    } 

}

=begin END

