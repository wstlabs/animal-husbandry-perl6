#
# A naive hill climbing strategy.  Doesn't try to do anything fancy;
# at each step it just tries the most obvius thing that could reach the 
# winning state, without making any obvious mistakes. 
#
# For a more detailed description, see the README at the top of this 
# distribution.
#
use Farm::AI::Strategy;
use Farm::AI::Search;
use Farm::Sim::Util;
use Farm::Sim::Posse;
use Keybag::Ops;

class Farm::AI::Naive
is    Farm::AI::Strategy  {

    method find-trade  {
        my %trade = self.find-stock-trade;
        %trade ?? { with => 'stock', %trade } !! Nil
    }

    method find-stock-trade  {
        my $S     = self.posse('stock');
        my $P     = self.current;
        if ((my $x = $P.wish) ∈ $S)  {
            my @t = find-admissible-trades($P,$x).grep: { $_ ⊲ $P }; 
            return { buying => $x, selling => @t.pick  } if @t
        }  
        for avail-dogs($S,$P) -> $x  {
            my @t = find-admissible-trades($P,$x).sort: { $^a ‹d› $^b };
            return { buying => $x, selling => @t.shift } if @t
        }
        for $P.gimme -> $x {
            my @t = find-admissible-trades($P,$x).grep: { !m/<[dD]>/ };
            return { buying => $x, selling => @t.pick  } if @t
        }
        return Nil;
    }

    method eval-trade(Str $with)  {
        return False 
    } 

}

=begin END


    sub find-admissible-trades(Farm::Sim::Posse $P, Str $x) is export {
        my $t = downward-equiv-to($x);
        grep { $P ⊇ fly($_) }, @$t
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

