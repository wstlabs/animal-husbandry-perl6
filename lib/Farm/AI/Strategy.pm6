#
# an abstract Strategy class.
#
# basically what it provides is (1) a somewhat more lightweight interface 
# to the data structures provided by the Game harness, and (2) a simple-ish 
# facility for inline logging at selectable levels of detail, provided by 
# a parameter which gets dipatched at construction.
#
#
use Farm::AI::Strategy::Util;
use Farm::Sim::Posse;
use Farm::Sim::Util;

class Farm::AI::Strategy {
    has Str $.player;

    has $!loud;
    method trace(*@a)  { self.emit(@a) if $!loud > 1 }
    method debug(*@a)  { self.emit(@a) if $!loud > 2 }
    method emit(*@a)   { say '::', Backtrace.new.[3].subname, "[$.player] ", @a } 

    has @!e;
    has %!p;
    method p() { %!p }
    method posse (Str $name)  { %!p{$name}.clone if %!p.exists($name) }
    method players { %!p.keys.sort }

    #
    # "expands" a hash returned by .find-trade(), i.e. from one of  the form
    #    
    #   { buying => { s => 6 }, selling => { s => 1 } }
    # 
    # to hash in terms of "rabbit" and "sheep", like the Game harness expects. 
    #
    sub expand(%t is copy)  {
        %t<buying>  = posse(%t<buying>).longhash;
        %t<selling> = posse(%t<selling>).longhash;
        %t
    }

    method trade(%p, @e) {
        say "::WHAT = $!loud";
        self.update(%p, @e);
        my %trade = self.find-trade; 
        # say ":: x = ", expand(%trade);
        return { type => 'trade', expand(%trade) } if %trade; 
    }

    method accept(%p, @e, $who) {
        self.trace("p = ", {%p});
        self.update(%p, @e);
        self.eval-trade($who)
    }

    # can be overridden by extension classes. 
    # especially if you want them to do something useful.
    multi method find-trade()  { self.debug("not implemented in abstract class"); Nil }
    multi method eval-trade()  { self.debug("not implemented in abstract class"); Nil }

    method update(%p, @e) {
        self.debug("p = ", {%p});
        %!p = inflate-posse-hash(%p);
        @!e = @e; # XXX slow! 
    }
}

=begin END

    #
    # allows for a somewhat more compact (positional) representation in 
    # our extension classes; e.g. they just need to say
    # 
    #    my $pair = ( 'r6' => 's' ) ;
    #    return ( stock => $pair );
    #
    sub expand-details(Pair $p --> Hash)  {
        my ($with,$what) = $p.kv;
        my ($selling,$buying) = map { posse($_).longhash }, $what.kv;
        { :$with, :$selling, :$buying }
    }

    sub expand-trade(Pair $p --> Hash) { 
        $p ?? { :type<trade>, expand-details($p) } !! Nil 
    }

    method trade(%p, @e) {
        self.update(%p, @e);
        my $pair = self.find-trade; 
        self.trace("pair = ", $pair.WHICH);
        self.trace("pair = ", $pair);
        for $pair.kv -> $k,$v {
            self.trace("k = $k = ", $k.WHICH);
            self.trace("v = $v = ", $v.WHICH);
        };
        my %t    = expand-trade($pair)   if $pair;
        return %t; 
    }


