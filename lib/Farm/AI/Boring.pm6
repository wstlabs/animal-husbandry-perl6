use Farm::AI::Strategy;
use Keybag::Ops;

# an an obviously boring and tedious strategy, but which at least
# does some basic hill climbing, and so might reach the winning state,
# eventually.
class Farm::AI::Boring
is    Farm::AI::Strategy  {

    sub find-pair(Farm::Sim::Posse $s, Farm::Sim::Posse $p)  {
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
        self.debug("player = ", $.player);
        my $P = self.posse($.player);
        my $S = self.posse('stock');
        self.trace("S = $S, P = $P");
        my $pair = find-pair($S,$P); 
        return $pair ?? ( stock => $pair ) !! Nil;
    }

    method eval-trade($who)  {
        return Bool.roll
    } 

}

=begin END

# wtf?  this line was generating "can't parse blockoid" 
# errors, the other day.  
self.debug ("pair = ", $pair.WHICH, " = ", $pair);

