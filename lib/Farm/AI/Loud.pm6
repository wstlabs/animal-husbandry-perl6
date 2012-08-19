#
# A "loud" version of the Naive strategy, functionally equivalent 
# (at the time of commit) but with excess logging enabled. 
#
use Farm::AI::Strategy;
use Farm::AI::Search;
use Farm::Sim::Util;
use Farm::Sim::Posse;
use Keybag::Ops;

class Farm::AI::Loud
is    Farm::AI::Strategy  {

    method find-trade  {
        my %trade = self.find-stock-trade;
        %trade ?? { with => 'stock', %trade } !! Nil
    }

    method preserve ($remark,$P,@t)  {
        self.trace("$remark before $P ⊳ ",@t," ?");
        @t = grep { fly($_) ⊲ $P }, @t; 
        self.trace("$remark after  $P ⊳ ",@t);
        @t
    }

    method dogsort($remark,@t)  {
        self.trace("$remark before ",@t," ?");
        @t = @t.sort: { $^a ‹d› $^b };
        self.trace("$remark after  ",@t);
        @t
    }

    method find-stock-trade  {
        my $S     = self.posse('stock');
        my $P     = self.current;
        self.trace("now = $P"); 
        if ((my $x = $P.wish) ∈ $S)  {
            my @t = find-admissible-trades($P,$x);
            @t = self.preserve("wish $x",$P,@t)         if @t;
            return { buying => $x, selling => @t.pick } if @t
        }  
        self.trace("doggy = ", avail-dogs($S,$P)); 
        for avail-dogs($S,$P) -> $x  {
            my @t = find-admissible-trades($P,$x);
            @t = self.dogsort("doggy $x",@t)             if @t;
            return { buying => $x, selling => @t.shift } if @t
        }
        self.trace("gimme = ", $P.gimme);
        for $P.gimme -> $x {
            my @t = find-admissible-trades($P,$x).grep({!m/<[dD]>/});
            @t = self.preserve("give $x",$P,@t)         if @t;
            return { buying => $x, selling => @t.pick } if @t
        }
        return Nil;
    }

    method eval-trade(Str $with)  {
        return False 
    } 

}

=begin END

    #
    # So here's what that mysterious "find admissible trades" sub that
    # appears in the main switch above looks like: 
    #
    sub find-admissible-trades(Farm::Sim::Posse $P, Str $x) is export {
        my $t = downward-equiv-to($x);
        grep { $P ⊇ fly($_) }, @$t
    }

    # It normally lives in Farm::AI::Search, and in that module it looks
    # a bit different, due to some compiler(?) glitches I can't yet seem
    # to get around.  But basically what it does is look for what we'll
    # call "downward-equivalent" trades, that is, trades which our given
    # search term $x can (in principle) buy but without yet checking for
    # actual availability against any particular player, using a table
    # of pre-computed lookups.  And then in this sub we do the actual
    # grepping  ...
    #

