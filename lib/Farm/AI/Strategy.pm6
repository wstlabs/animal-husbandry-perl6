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

    has @!e;
    has %!p;
    has Str $!player;
    method p() { %!p }
    method players { %!p.keys.sort }
    method posse (Str $name)  { %!p{$name}.clone if %!p.exists($name) }
    method current { self.posse($!player) }
    method who     { $!player }

    has $!loud;
    method trace(*@a)  { self.emit(@a) if $!loud > 1 }
    method debug(*@a)  { self.emit(@a) if $!loud > 2 }
    method emit(*@a)   { say '::', Backtrace.new.[3].subname, "[$!player] ", @a } 

    submethod BUILD(:$!loud=0, :%!p, :$!player) { }


    #
    # expands a hash returned by .find-trade(), i.e. from one of  the form
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
        # say "::AI loud = $!loud";
        # say "::AI player = $!player";
        self.update(%p, @e);
        # say "::AI p = ", %p;
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


