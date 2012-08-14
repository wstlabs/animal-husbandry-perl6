use Farm::AI::Strategy;
use Keybag::Ops;

#
# basically just does some clumsy 'if-then' switches we came up
# with until something happens.  might reach winning state, or not, 
# but at least it has a chance.
#
class Farm::AI::Boring
is    Farm::AI::Strategy  {

    sub find-pair(Farm::Sim::Posse $s, Farm::Sim::Posse $p)  {
        # say "::find-pair p = ",$p.WHICH;
        if ( $p{'D'} < 2 && $s{'D'} > 0)  {
            return ('c'  => 'D') if $p{'c'} >= 1;
            return ('p3' => 'D') if $p{'p'} >= 3;
            return ('s6' => 'D') if $p{'s'} >= 6; 
        }
        if ( $p{'d'} < 4 && $s{'d'} > 0) { 
            return ('s'  => 'd') if $p{'s'} >= 1;
            return ('r6' => 'd') if $p{'r'} >= 6;
            return ('p2' => 'd') if $p{'p'} >= 2;
        }
        if ( $p{'h'} < 1 && $s{'h'} > 0) { 
            return ('c2'  => 'h') if $p{'c'} >= 2;
        }
        if ( $p{'c'} < 1 && $s{'c'} > 0) { 
            return ('s6'  => 'c') if $p{'s'} >= 6;
            return ('p3'  => 'c') if $p{'p'} >= 3;
        }
        if ( $p{'p'} < 1 && $s{'p'} > 0) { 
            return ('s2'  => 'p') if $p{'s'} >= 2;
        }
        if ( $p{'s'} < 1 && $s{'s'} > 0) { 
            return ('r6'  => 's') if $p{'r'} >= 6;
        }
        return Nil
    }

    method find-trade()  {
        self.trace("player = ", $.player);
        my $me     = self.posse($.player);
        # self.trace("me = ", $me);
        my $stock = self.posse('stock');
        # self.trace("p = ", self.p);
        # self.trace("me = $me, need = ", $me.need); 
        # self.trace("me = ", $me.WHICH);
        # self.trace("me = ", $me.hash);
        my $pair = find-pair($stock,$me); 
        self.trace("pair = ", $pair.WHICH, " = ", $pair);
        return $pair ?? ( stock => $pair ) !! Nil
    }



    method eval-trade($who)  {
        self.trace("p = ", self.p);
        return Bool.roll
    } 

}

=begin END
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


