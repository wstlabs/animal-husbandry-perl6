use Farm::AI::Strategy;

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
        my $cp = self.posse($.player);
        self.trace("::find-trade p = ", self.p);
        self.trace("::find-trade me = $cp, need = ", $cp.need); 
        if ( $cp{'D'} < 1 ) {
            return %!Dc  if $cp{'c'} >= 1;
            return %!Dp3 if $cp{'p'} >= 3;
            return %!Ds6 if $cp{'s'} >= 6; 
        }
        if ( $cp{'d'} < 2 ) {
            return %!ds  if $cp{'s'} >=  1;
            return %!dr6 if $cp{'r'} >=  6;
        }
        if ( $cp{'c'} < 1 ) {
            return %!cs6  if $cp{'s'} >  8;
            return %!cp3  if $cp{'p'} >  3;
        }
        if ( $cp{'p'} < 1 ) {
            return %!ps2  if $cp{'s'} >= 3;
        }
        if ( $cp{'s'} < 1 ) {
            return %!sr6  if $cp{'r'} >  6;
        }
        return Nil;
    }

    method eval-trade($who)  {
        self.trace("::eval-trade p = ", self.p);
        return Bool.roll
    } 

}

=begin END
        my %t = 
            given $cp  {
                when /s2/ { %!p } 
                when /s/  { %!d } 
                when /r/  { %!s } 
                default   { %!s }
            }
        ;
    has %!s = {
        type => "trade", with => "stock",
        selling => { rabbit => 6 }, 
        buying  => { sheep => 1 }
    };

    has %!d = {
        type => "trade", with => "stock",
        selling => { sheep => 1 }, 
        buying  => { small_dog => 1 }
    };

    has %!p = {
        type => "trade", with => "stock",
        selling => { sheep => 2 }, 
        buying  => { pig => 1 }
    };


    method find-trade()  {
        my $cp = self.posse($.player);
        self.trace("::find-trade p = ", self.p);
        self.trace("::find-trade me = $cp, need = ", $cp.need); 
        my %t = 
            $cp{'d'} < 2 ??
                $cp{'s'} > 1 ?? %!d !! 
                $cp{'r'} > 6 ?? %!s !! Nil
            !!
                $cp{'s'} > 2 ?? %!p !! 
                $cp{'r'} > 6 ?? %!s !! Nil
        ;
        return %t;
    }

    method eval-trade($who)  {
        self.trace("::eval-trade p = ", self.p);
        return Bool.roll
    } 

}

=begin END
        my %t = 
            given $cp  {
                when /s2/ { %!p } 
                when /s/  { %!d } 
                when /r/  { %!s } 
                default   { %!s }
            }
        ;
