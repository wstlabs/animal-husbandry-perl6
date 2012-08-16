use Farm::Sim::Util;
use Farm::Sim::Posse;
use Farm::Sim::Posse::Fly;
use Farm::AI::Search::Data;
use KeyBag::Ops;

sub table-counts is export {
    hash map -> $k {
        $k => downward-equiv-to($k).Int 
    }, domestic-animals() 
}

#   
# finds what we call "admissible" trades for the given canonical search 
# term $x, i.e. all tuples which can be validly traded for $x and are 
# contained in Posse $p.
#
# XXX some definite weirdness going on, here.  All we're trying to do is 
# do a grep on the innards of $t, itself a Capture representing a memoized
# Array instance.  But when we do it the way we want to:
#
#   my $t = downward-equiv-to($x);
#   return grep { $p ⊇ fly($_) }, @$t
#
# rakudo comes back with: 
#
#   ===SORRY!===
#   Non-declarative sigil is missing its name
#  
# However, if we unwind the above sequence -- which seems to work in 
# other contexts, btw -- by gratuitously inserting a few intermediate 
# container instances below, then the squawking goes away.  
#
# Unfortunately, aside from being awkward looking, this also de-singletonizes 
# the list references we had so carefully memoized up in Farm::AI::Search::Data,
# where the original sub decl lives.  So hopefully we'll get to find out what's 
# happening here.
#
sub find-admissible-trades(Farm::Sim::Posse $p, Str $x) is export {
    my $t = downward-equiv-to($x);
    my @a = @$t;
    my @b = grep { $p ⊇ fly($_) }, @a;
    return @b; 
}


# simple quantifiers which provide list of available small dogs, big dogs
# (or both) which are owned by $P and which $Q can nominally afford to buy.
# so in set builder notation:
#
#   find @dogs -> $dog {
#       $Q ⊇ $dog && worth($dog) <= worth($Q) 
#   } 
#
# leaving open the question of whether $P can produce any $buy tuples
# to purchase the @dogs it wants from $Q.
#
# Note that this -doesn't- mean that $Q has animals available for trade to buy 
# these dogs from $P; just that in principle it has enough animals available 
# for trade, so that it might be worth searching for matching trades.

# ...returns some subset of the list <D2 D>
multi sub avail-D(Farm::Sim::Posse $P, Farm::Sim::Posse $Q) is export {
    my $k = $P.avail('D',$Q);
    ( map { $_ > 1 ?? "D$_" !! "D" }, 1..$k ).reverse
}
# ...returns some subset of the list <d4 d3 d2 d>
multi sub avail-d(Farm::Sim::Posse $P, Farm::Sim::Posse $Q) is export {
    my $k = $P.avail('d',$Q);
    ( map { $_ > 1 ?? "d$_" !! "d" }, 1..$k ).reverse
}


# ...returns some subset of the list <D2 D d4 d3 d2 d>
multi sub avail-dogs(Farm::Sim::Posse $P, Farm::Sim::Posse $Q) is export {
    return ( avail-D($P,$Q), avail-d($P,$Q) )
}

#
# deprecated pair-based constructors.  
#
# multi sub avail-d(Pair $p) is export { avail-d($p.kv) }
# multi sub avail-D(Pair $p) is export { avail-D($p.kv) }
# multi sub avail-dogs(Pair $p) is export { avail-dogs($p.kv) }




=begin END

sub find-admissible-trades-loud(Farm::Sim::Posse $p, Str $x) is export {
    my $t = downward-equiv-to($x);
    say "::find-admissible-trades 1 $x => = {$t.WHICH} = ", $t; 
    my @a = @$t;
    say "::find-admissible-trades 2 $x => = {@a.WHICH} = ", @a; 
    my @b = grep { $p ⊇ fly($_) }, @a;
    say "::find-admissible-trades 3 $x => = {@b.WHICH} = ", @b;
    return @b; 
}


===SORRY!===
Non-declarative sigil is missing its name
 
