use Farm::AI::Strategy;
use Keybag::Ops;

class Farm::AI::Trivial
is    Farm::AI::Strategy  {

    method find-trade()  {
        my $pair = ( 'r6' => 's' );
        return ( stock => $pair )
    }

    method eval-trade($who)  {
        self.trace("p = ", self.p);
        return Bool.roll
    } 

}

=begin END

        # self.trace("pair = ", $pair.WHICH);
        # self.trace("pair = {$pair.perl}"); 
        # self.trace("pair = ",$pair.kv); 
        # my $foo = stock => $pair;
        # self.trace("foo = ", $foo.WHICH);
        # self.trace("foo = {$foo.perl}"); 
        # self.trace("foo = ",$foo.kv); 

    method find-xxx()  {
        self.trace("player = ", $.player);
        my $me    = self.posse($.player);
        self.trace("me = ", $me);
        self.trace("me = ", $me.WHICH);
        my $stock = self.posse('stock');
        self.trace("p = ", self.p);
        self.trace("me = $me, need = ", $me.need); 
        self.trace("me = ", $me.WHICH);
        self.trace("me = ", $me.keys);
        for <r s c p h d D> -> $x { self.trace("me - $x => ", $me{$x} ) };
        my $pair = find-pair($me); 
        self.trace("pair = ", $pair.WHICH, " = ", $pair);
        return $pair ?? stock => $pair !! Nil
    }
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


