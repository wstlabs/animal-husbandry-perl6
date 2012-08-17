use v6;
use Farm::Sim::Util;
use Farm::Sim::Posse;
use Farm::Sim::Dice;
use KeyBag::Ops;


class Farm::Sim::Game  {
    has %!p;         # players (and stock): hash of hashes of animals
    has $!dice;      # combined fox-wolf die object
    has @!e;         # event queue: array of hashes representing events
    has $!cp;        # current player
    has %!tr;        # player trading code objects
    has %!ac;        # player accept trade code objects
    has $!i;         # current step 
    has $!j;         # current round
    has $!m;         # (optional) last round
    has $!n;         # (optional) last step 
    has @!r;         # (optional) canned roll sequence, for testing
    has $!t0; 
    has $!t1; 
    has $!winner;

    has $!verbose;
    method info( *@a)  {       say @a  if $!verbose > 0 }
    method trace(*@a)  { self.emit(@a) if $!verbose > 1 }
    method debug(*@a)  { self.emit(@a) if $!verbose > 2 }
    method emit( *@a)  { say '::',Backtrace.new.[3].subname,' ',@a }

    submethod BUILD(:%!p, :@!e, :$!cp = 'player_1', :%!tr, :%!ac, :@!r, :$!verbose=1, :$!n) {
        %!p<stock> //= posse(stock-hash()); 
        $!dice     //= Farm::Sim::Dice.instance;
        # say "::GAME (game) = $!verbose";
    }

    method reset  {
        self.trace("..");
        $!winner = Nil;
        @!e = @!r = ();
        $!i = $!j = Nil;
        $!cp = 'player_1';
        $!t0 = $!t1 = Nil;
        %!p<stock> //= posse(stock-hash()); 
        for %!p.keys -> $k { %!p{$k} = posse({}) };
        self
    }



    #
    # static (factory-like) instance generators 
    #

    # creates an empty game on $n players 
    method simple (:$k, :$n, :$verbose )  {
        my %p = hash map { ; "player_$_" => posse({}) }, 1..$k;
        self.new(p => %p, :$n, :$verbose)
    }

    # creates a standard contest game on the specified player list 
    # XXX should perhaps check integrity of tr, ac hashes before blindly 
    # passig on to the instance constructor.
    method contest (:@players, :%tr, :%ac, :$n, :$verbose )  {
        my %p = hash map { ; $_ => posse({}) }, @players; 
        self.new(p => %p, :%tr, :%ac, :$n, :$verbose)
    }


    method posse (Str $name)  { %!p{$name}.clone if %!p.exists($name) }
    method players { %!p.keys.sort }
    method table { hash map -> $k,$v { $k => $v.Str      }, %!p.kv }
    method p     { hash map -> $k,$v { $k => $v.longhash }, %!p.kv }
    method elapsed { ($!t1-$!t0).Real }
    method stats { 
        return { 
            :$!i, :$!j, 
            :$!m, $!n, 
            :$!winner,
            dt => self.elapsed 
        } 
    }
    # XXX currently this hash comes out a bit garbled around the vicintiy 
    # of the undefined $!m variable.  what's up with that?


    multi method play()  {
        $!t0 = now;
        $!t1 = Nil; 
        $!i = $!j = 0;
        # say "::GAME verbose = $!verbose, n = $!n";
        self.trace("..");
        self.trace("r = ", @!r);
        while (1)  {
            self.play-round;
            if (self.someone-won)  {
                self.celebrate;
                last
            }  else  {
                self.incr
            }
            last if defined($!m) && $!i >= $!m;
            last if defined($!n) && $!j >= $!n;
            last if @!r.Int > 0  && $!j >  @!r;
        }
        $!t1 //= now;
        return self
    }
    
    method play-round  {
        self.trace("i = $!i, j = $!j, cp = $!cp");
        return self if self.do-trade.someone-won;
        return self.do-roll;
    }

    method do-trade  {
        self.debug("..");
        # my $was   = self.posse($!cp);
        # self.debug("was $was");
        self.effect-trade;
        # my $now   = self.posse($!cp);
        # self.debug("now $now");
        return self
    }

    method do-roll  {
        self.debug("..");
        my $was   = self.posse($!cp);
        my $roll  = @!r[$!i] // $!dice.roll;
        self.debug("was $was");
        self.effect-roll($roll);
        my $now   = self.posse($!cp);
        self.debug("now $now");
        self.show-roll( :$was, :$now );
        return self
    }


    # should be compatible with the analogous section in the original farm.pl,
    # with the exception of the "Null trade" exemption in the middle, which (given
    # the "Unequal trade" exemption just before it) can only be triggered if we're 
    # asked to execute a completely degenerate, empty-for-empty trade.
    #
    # I put this exemption in there both because it seems sensible enough, 
    # even though this case isn't mentioned in the spec, and because it allows
    # us to use the simple junction-based quantifier check in the next step.
    #
    # XXX overall seems to be pretty accurate, but still some isses around 
    # warnings due to undefined values in logging statements.
    # if (%!tr{$!cp} // -> %, @ {;})({%!p}, @!e) -> $_ {
    method effect-trade  {
        self.debug("cp = $!cp"); 
        if (%!tr{$!cp} // -> %, @ {;})(self.p, @!e) -> $_ {
            self.trace("$!cp => ", $_); 
            sub fail(%trade, $reason) { self.reject(%trade, $reason) };
            self.trace("type = ", .<type>);
            self.trace("with = ", .<with>);
            return .&fail("Wrong type")                  if !.exists("type") || .<type> ne "trade";
            return .&fail("Player doesn't exist")        if !.exists("with");
            my $cp      = self.posse($!cp);
            my $op      = self.posse(.<with>);
            self.trace("cp = $cp"); 
            self.trace("op = $op"); 
            self.trace("selling = ", .<selling>);
            self.trace("buying  = ", .<buying>);
            my $selling = posse-from-long(.<selling>);
            my $buying  = posse-from-long(.<buying>);
            self.trace("buying  = $buying");
            self.trace("selling = $selling");
            return .&fail("Player doesn't exist")        if !$op;
            return .&fail("Not enough CP animals")       if                       $cp ⊉ $selling;
            return .&fail("Not enough OP animals")       if .<with> ne 'stock' && $op ⊉ $buying;
            return .&fail("Unequal trade")               if $selling.worth != $buying.worth;
            return .&fail("Null trade")                  unless all($buying,$selling).width >  0;
            return .&fail("Many-to-many trade")          unless any($buying,$selling).width == 1;
            return .&fail("Other player declined trade") unless
                (%!ac{.<with>} // -> %,@,$ {True})(self.p,@!e,$!cp);

            my $truncated = $op ∩ $buying;
            my $remark = $truncated ⊂ $buying ?? " (truncated => $truncated)" !! ""; 
            self.transfer( $!cp, .<with>, $selling   );
            self.transfer( .<with>, $!cp, $truncated );
            my $now = self.posse($!cp);
            my $ij = format-counts($!i,$!j);
            self.info("SWAP $ij $!cp ↦",.<with>,": $selling => $buying" ~ $remark ~ " » $now");
            # say "::GAME verbose = $!verbose";
        }
    }

    #
    # note that we process the [w] and [f] rolls in the same order as in 
    # carl's original version, even though this ordering was apparently not 
    # clearly stated in the printed instructions for the game.  however, 
    # the choice of ordering affects only the event logging, not the outcome 
    # on the player's animals.
    # 
    # note also that in any case, we proceed to attempt to mate with whatever 
    # animal was contained in the roll after the the predator has had his way 
    # with the existing posse. 
    #
    method effect-roll(Str $roll)  {
        self.trace("$!cp ~ $roll");
        self.publish: { :type<roll>, :player($!cp), :$roll };
        given $roll {
            when /[w]/ { 
                my $posse = self.posse($!cp);
                self.debug("posse = $posse");
                if ('D' ∈ $posse)  {
                    self.transfer( $!cp, 'stock', 'D' )
                }
                else  {
                    self.transfer( $!cp, 'stock', $posse.slice([<r s p c>]) )
                }
                proceed;
            }
            when /[f]/ { 
                my $posse = self.posse($!cp);
                self.debug("posse = $posse");
                if ('d' ∈ $posse)  {
                    self.transfer( $!cp, 'stock', 'd' )
                }
                else  {
                    self.transfer( $!cp, 'stock', $posse.slice([<r>]) )
                }
                proceed;
            }
            default  {
                my $stock = self.posse('stock'); 
                my $posse = self.posse($!cp);
                self.debug("posse = $posse");
                self.debug("stock = $stock");
                my $desired = $posse ⚤ $roll;
                self.debug("desired = $desired");
                my $allowed = $desired ∩ $stock;
                self.debug("allowed = $allowed"); 
                self.transfer( 'stock', $!cp, $allowed )
            }
        }
    }

    method transfer($from, $to, $what) {
        self.trace("$from => $to:  $what");
        if ($what)  {
             %!p{$to}    ⊎= $what;
             %!p{$from}  ∖= $what;
        }
        self.publish: { 
            :type<transfer>, :$from, :$to, 
            'animals' => "$what"
        };
    }

    sub deepclone(%h) {
        hash map -> $k, $v {; 
            $k => ($v ~~ Hash ?? deepclone($v) !! $v ) 
        }, %h.kv
    }

    sub trade2info(%t)  {
        my $op = %t<with>;
        my $sell  = posse-from-long(%t<selling>);
        my $buy   = posse-from-long(%t<buying>);
        return { :$op, :$buy, :$sell }
    }

    # the guts of &fail, aka &fail_trade in .effect-trade 
    method reject(%trade, $reason) {
        my %i = trade2info(%trade);
        my $ij = format-counts($!i,$!j);
        self.info("FAIL $ij $!cp ↦ %i<op> : %i<sell> <=> %i<buy> : $reason");
        self.publish: { 
            :type<failed>, 
            :$reason, 
            :trader($!cp),
            :trade(deepclone(%trade)) 
        }
    }

    method celebrate  {
        $!t1 = now;
        self.publish: { :type<win>, :who($!cp) };
        my $winner = self.posse($!cp);
        my $dt     = self.elapsed; 
        my $ij     = format-counts($!i,$!j);
        self.info("WIN! $ij $winner = $!cp, in $dt sec.");
        self
    }


    method publish(%event) {
        self.debug("event = {%event.perl}");
        push @!e, {%event}
    }


    #
    # show what happened recently
    #
    method show-roll( :$was, :$now )  { 
        my %m = self.inspect-roll;
        self.debug("meta = {%m.perl}");
        my $ij = format-counts($!i,$!j);
        my $eaten = (defined %m<puts>) ?? "-%m<puts>" !! "";
        self.info("ROLL $ij %m<player> $was ~ %m<roll> -> +%m<gets> $eaten » $now");
    }

    method inspect-roll {
        self.debug("e.Int = ", @!e.Int);
        my @ev = self.slice-recent-events-upto("type","roll");
        for @ev -> %e  {
            self.debug("e = {%e.perl}")
        }

        my %r = shift @ev;
        self.debug("r = {%r.perl}");
        my $player  = %r<player>;
        my $roll    = %r<roll>;
        self.debug("player  = ", $player);
        self.debug("roll    = ", $roll);

        my (@gets,@puts);
        for @ev -> %e  {
            self.debug("e = {%e.perl}");
            my $animals = %e<animals>;
            my $from    = %e<from>;
            my $to      = %e<to>;
            self.debug("animals = ", $animals);
            self.debug("from    = ", $from);
            self.debug("to      = ", $to);
            if ($from eq 'stock')  { push @gets, $animals }
            if ($to   eq 'stock')  { push @puts, $animals }
        }
        my %s;
        %s<gets> = @gets.join(',') if @gets;
        %s<puts> = @puts.join(',') if @puts;
        return { :$player, :$roll, %s } 
    }

    #
    # slices from the top of the event stack (non-destructively)
    # until a certain criterion -- here unimaginately represented 
    # by a positional $k,$v pair -- is met.  sample output:
    #
    # Array.new(
    #   {"type" => "roll", "player" => "P1", "roll" => "hr"}, 
    #   {"type" => "transfer", "from" => "stock", "to" => "P1", "animals" => "r"}
    # )
    method slice-recent-events-upto(Str $k, Str $v) {
        gather {
            for @!e.reverse -> %e  {
                take {%e};
                last if %e{$k} eq $v 
            }
        }.reverse
    }

    # 0: 1,0
    # 1: 2,0
    # 2: 3,1
    # 3: 4,1
    method incr {
        $!cp = "player_1" unless %!p.exists(++$!cp);
        (++$!i % +self.players) ?? $!j !! ++$!j
    }

    method someone-won( --> Bool ) { 
        self.trace("..");
        if ( so %!p{$!cp}{all <r s p c h>} )  { 
            $!t1 = now;
            $!winner = $!cp;
            return True
        }  else  {
            return False
        }
    }

    # formatting hacks used to keep the ROLL/SWAP/FAIL/WIN! status lines sort of 
    # fixed-width-ish.  3-char defaults for $!i, $!j should be fine for the values 
    # we're dealing with.
    # XXX btw, so where -is- the perlform manpage for perl 6, anyway?
    sub right-justify(Int $k, Any $s --> Str) { (' 'x($k-$s.chars)~$s) }
    sub format-counts($i,$j) { right-justify(3,$i) ~ " " ~ right-justify(3,$j) }
    
};

=begin END
⚤ "»» ..";

