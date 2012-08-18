#
# A naive hill climbing strategy.  Doesn't try to do anything fancy -
# just tries the most obvoius thing that could reach the winning state,
# without making any obvious mistakes. 
#
# Basically what the stratgy amounts to is:
#
#  * Oppose all incoming trades (and initiate no trades with outside players).  
#    The cases where cross-player trades seem to make sense are comparatively 
#    few and rare, and besides, we're only playing against other clones of
#    ourself for now.
#
#  * At the beginning of each trading round, if there's an admissible 
#    game-ending trade, execute it (obviously). 
#
#  * "Always buy insurance".  Given the high frequence of F and W rolls,  
#    it basically seems always advisable to buy whatever dogs are available 
#    for sale by the stock.  Not only do surplus dogs hedge against potential 
#    runs of bad die rolls, they also deprive other players or protection.
#
#  * Otherwise, we enumerate a list of small animals we need to increase
#    our diversity (provided by the "gimme" method), and search for trades 
#    which provide these animals (from the stock) -- and, importantly,
#    also don't sacrifice any "insurance" (i.e. big or small dogs).  The 
#    selection from here is far from ideal, but the point is that it's pretty 
#    much guaranteed to always bump us up towards the winning state, except 
#    for a few infrequent corner cases (so-called "upward trades") which 
#    we'll address in a future iteration.
#
# That's about it.  Again, this strategy has plenty of shortcomings, and there 
# some obvious areas for improvement.  But the point is to get something available 
# for benchmarking; and it does appear to be a minimal viable strategy, with that 
# consideration in mind. 
#
# A little more detail as to the inner workings is provided below the END block, BTW.
#
use Farm::AI::Strategy;
use Farm::AI::Search;
use Farm::Sim::Util;
use Farm::Sim::Posse;
use Farm::Sim::Posse::Fly;
use Keybag::Ops;

class Farm::AI::Naive
is    Farm::AI::Strategy  {

    method find-trade  {
        my %trade = self.find-stock-trade;
        %trade ?? { with => 'stock', %trade } !! Nil
    }

    method preserve ($remark ,$P,@t)  {
        self.trace("$remark before $P ⊳ ",@t," ?");
        @t = grep { fly($_) ⊲ $P }, @t; 
        self.trace("$remark after  $P ⊳ ",@t);
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
            return { buying => $x, selling => @t.pick } if @t
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

