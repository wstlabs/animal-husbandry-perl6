use Farm::Sim::Util;
use Farm::Sim::Posse;
use Farm::AI::Util::Search::Data;
use KeyBag::Ops;

sub table-counts is export {
    hash map -> $k {
        $k => downward-equiv-to($k).Int 
    }, domestic-animals() 
}

sub find-admissible-trades(Farm::Sim::Posse $p, Str $x) is export {
    grep { $p ⊇ fly($_) }, downward-equiv-to($x)
}


my %F;
# flyweight pattern for posse instances - which, theoretically, should save a lot 
# on construction costs -- but currently at the cost of volatility, in currently 
# the instances are rw, and fully open to mutation (so don't do that, please).
multi sub fly(Farm::Sim::Posse $x --> Farm::Sim::Posse) is export { $x }
multi sub fly(             Str $x --> Farm::Sim::Posse) is export {
    die "can't inflate:  not a domestic posse string" unless is-domestic-posse-str($x);
    %F{$x} //= posse($x)
}
sub fly-stats is export { n => %F.keys.Int }


# simple quantifiers which provide a list of available small (or big) dogs,
# respectively, which are owned by $P and which $Q can (nominally) afford to buy.
# Note that this -doesn't- mean that $Q has animals available for trade to buy 
# these dogs from $P; just that in principle it has enough animals available 
# for trade, so that it might be worth searching for matching trades.
multi sub avail-d(Farm::Sim::Posse $P, Farm::Sim::Posse $Q) is export {
    my $k = $P.avail('d',$Q);
    ( map { $_ > 1 ?? "d$_" !! "d" }, 1..$k ).reverse
}
multi sub avail-D(Farm::Sim::Posse $P, Farm::Sim::Posse $Q) is export {
    my $k = $P.avail('D',$Q);
    ( map { $_ > 1 ?? "D$_" !! "D" }, 1..$k ).reverse
}
multi sub avail-d(Pair $p) is export { avail-d($p.kv) }
multi sub avail-D(Pair $p) is export { avail-D($p.kv) }




=begin END

