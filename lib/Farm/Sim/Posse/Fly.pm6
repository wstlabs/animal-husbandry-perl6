use v6;
use Farm::Sim::Posse;
use Farm::Sim::Util;

#
# flyweight memoization for posse instances.
#
# should theoretically save a lot on construction costs (both time + space),
# BUT currently at a signficant stability cost, in the instances we return are 
# not only fully mutable, but of course globally persistent. 
#
# however, since the current use case the flyweights are used only for 
# read-only comparisons, we don't need to be too worried about that risk, 
# for the time being.
#


my %F;
multi sub fly(Str $x --> Farm::Sim::Posse) is export {
    # XXX this regex check is perhaps rather expensive, so we may want to bypass it at 
    # some point.  but the point is too provide some kind of a coherent message at the 
    # level of the fly() pseudo-constructor itself, rather than at the level of the 
    # posse() constructor.
    die "can't inflate:  not a domestic posse string" unless is-domestic-posse-str($x);
    %F{$x} //= posse($x)
}

# if we're inadvertently called on an existing instance, we default
# to the identity mapping.  but perhaps we should warn or die, instead.
multi sub fly(Farm::Sim::Posse $x --> Farm::Sim::Posse) is export { $x }


# provide some convenient stats about how many instance we're
# recyclying.  in the future we might make this much more detailed.
sub fly-stats is export { n => %F.keys.Int }


