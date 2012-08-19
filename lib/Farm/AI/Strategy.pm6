#
# an abstract Strategy class.
#
# basically what it provides is (1) a somewhat more lightweight interface 
# to the data structures provided by the Game harness, and (2) a simple-ish 
# facility for inline logging at selectable levels of detail, provided by 
# a parameter which gets dipatched at construction.
#
#
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

    sub inflate-posse-hash(%p) is export {
        hash map -> $k,$v {
            $k => posse-from-long($v)
        }, %p.kv
    }

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
        self.update(%p, @e);
        my %trade = self.find-trade; 
        return { type => 'trade', expand(%trade) } if %trade; 
    }

    # XXX actually, since we're currently not attempting to process 
    # cross-player trades, we haven't completed the interface on this 
    # part yet.  But basically it needs to fish through the recent event 
    # history to find the most recent %trade, and pass that nicely to
    # our native handler, .eval-trade().
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


