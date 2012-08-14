use Farm::AI::Strategy::Util;
use Farm::Sim::Posse;
use Farm::Sim::Util;

class Farm::AI::Strategy {
    has Str $.player;

    has $.loud = 2;
    method trace(*@a)  { self.emit(@a) if $.loud > 1 }
    method debug(*@a)  { self.emit(@a) if $.loud > 2 }
    method emit(*@a)   { say '::', Backtrace.new.[3].subname, "[$.player] ", @a } 

    has @!e;
    has %!p;
    method p() { %!p }
    method posse (Str $name)  { %!p{$name}.clone if %!p.exists($name) }
    method players { %!p.keys.sort }

    sub expand-details(Pair $p --> Hash)  {
        my ($with,$what) = $p.kv;
        # say ":: with = ", $with;
        # say ":: what = ", $what;
        # say ":: what = ", $what.WHICH;
        # say ":: what.kv   = ", $what.kv;
        # say ":: kv   = ", $what.kv.WHICH;
        my ($selling,$buying) = map { posse($_).longhash }, $what.kv;
        # say "selling = {$selling.perl} = ", $selling.WHICH;
        # say "buying = {$buying.perl} = ", $buying.WHICH;
        { :$with, :$selling, :$buying }
    }

    sub expand-trade(Pair $p --> Hash) { 
        $p ?? { :type<trade>, expand-details($p) } !! Nil 
    }

    method trade(%p, @e) {
        self.trace("p = ", {%p});
        self.update(%p, @e);
        my $pair = self.find-trade(); 
        self.debug("pair = ", $pair.WHICH);
        self.debug("pair = {$pair.perl}");
        my %d    = expand-details($pair) if $pair;
        self.debug("d    = ", %d);
        my %t    = expand-trade($pair)   if $pair;
        self.debug("t    = ", %t);
        return %t; 
    }

    method accept(%p, @e, $who) {
        self.trace("p = ", {%p});
        self.update(%p, @e);
        my $stat = self.eval-trade($who);
        self.trace("stat = ", $stat);
        return $stat
    }

    multi method find-trade()          { self.trace("not the droids you're looking for .."); Nil }
    multi method eval-trade()          { self.trace("not the droids you're looking for .."); Nil }

    method update(%p, @e) {
        %!p = inflate-posse-hash(%p);
        @!e = @e; # XXX slow! 
    }
}

=begin END
    # method eval-trade(Str $who)  { die "not implemented in abstract class"; }

    method posse (Str $name)  { 
        # self.trace("name = $name");
        # self.trace("xist = ", %!p.exists($name));
        # self.trace("orig = ", %!p{$name}.WHICH);
        # my $it = %!p{$name}.clone if %!p.exists($name);
        # self.trace("it   = ", $it.WHICH);
        # return $it
        %!p{$name}.clone if %!p.exists($name);
    }

    sub pair2long(Pair $p) { 
        my ($buying,$selling) = map { short2long($_) }, $p.kv;
        return { :$buying, :$selling }
    }
    # sub stock-trade(Pair $p) { :type<trade>, :with<stock>, pair2long($p) } 


