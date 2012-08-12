use v6;
use Farm::Sim::Util;
use Farm::Sim::Posse;
use Farm::Sim::Dice;
use KeyBag::Ops;

constant %STOCK = {
    r => 60, s => 24, p => 20, c => 12, h => 6, 
    d =>  4, D =>  2
};


class Farm::Sim::Game  {
    has %!p;         # players (and stock): hash of hashes of animals
    has $!dice;      # combined fox-wolf die object
    has @!e;         # event queue: array of hashes representing events
    has $!cp;        # current player
    has %!tr;        # player trading code objects
    has %!ac;        # player accept trade code objects
    has $!j;         # current step
    has $!n;         # (optional) last step 
    has @!r;         # (optional) canned roll sequence, for testing
    has $!debug;     # (optional) debug flag
    submethod BUILD(:%!p, :@!e, :$!cp = 'player_1', :%!tr, :%!ac, :$!n, :@!r, :$!debug = 0) {
        %!p<stock> //= posse(%STOCK); 
        $!dice     //= Farm::Sim::Dice.instance;
        $!j = 0;
        $!debug = 1 unless defined($!debug);
    }

    method info(*@a)   { if ($!debug > 0)  { say @a } }
    method trace(*@a)  { if ($!debug > 1)  { say @a } }
    method debug(*@a)  { if ($!debug > 2)  { say @a } }

    #
    # static (factory-like) instance generators 
    #

    # creates an empty game on $n players 
    method simple (:$k, :$n, :$debug )  {
        my %p = hash map { ; "player_$_" => posse({}) }, 1..$k;
        self.new(p => %p, :$n, :$debug)
    }

    # creates a standard contest game on the specified player list 
    # XXX should check integrity of tr, ac hashes 
    method contest (:@players, :%tr, :%ac, :$n, :$debug )  {
        my %p = hash map { ; $_ => posse({}) }, @players; 
        self.new(p => %p, :%tr, :%ac, :$n, :$debug)
    }

    method posse (Str $name)  { %!p{$name}.clone if %!p.exists($name) }
    method players { %!p.keys.sort }
    method table {
        hash map -> $k,$v {
            $k => $v.Str
        }, %!p.kv
    }
    method stats { return { j => $!j } }


    #
    # play for a fixed number of rounds
    #
    multi method play(Int $n where { $n >= 0 })  {
        self.play-round() for 1..$n;
        return self
    }

    #
    # keep playing until we hit some limit specified by
    # parameters given to the constructor 
    #
    multi method play()  {
        while (1)  {
            last if defined($!n) && $!j >= $!n;
            last if @!r.Int > 0  && $!j >= @!r;
            self.play-round() 
        }
        return self
    }
    
    method play-round  {
        self.trace("::play j = $!j, cp = $!cp");
        self.play-trade;
        self.play-roll;
        self.incr;
        return self
    }

    method play-trade  {
        my $was   = self.posse($!cp);
        self.trace("::play-trade: was $was");
        self.effect-trade();
        my $now   = self.posse($!cp);
        self.trace("::play-trade: now $now");
    }

    method play-roll  {
        my $was   = self.posse($!cp);
        my $roll  = @!r[$!j] // $!dice.roll;
        self.trace("::play-roll: was $was");
        self.effect-roll($roll);
        my $now   = self.posse($!cp);
        self.trace("::play-roll: now $now");
        self.show-roll( :$was, :$now );
    }


    # should be compatible with the analogous section in the original farm.pl,
    # with the exception of the "Null trade" exemption in the middle, which (given
    # the "Unequal trade" exemption just before it) can only be triggered if we're 
    # asked to execute a completely degenerate, empty-for-empty trade.
    #
    # I put this exemption in there both because it seems sensible enough, 
    # even though this case isn't mentioned in the spec, and because it allows
    # us to use the simple junction-based quantifier check in the next step.
    method effect-trade  {
        if (%!tr{$!cp} // -> %, @ {;})({%!p}, @!e) -> $_ {
            self.trace("::effect-trade $!cp => ", $_); 
            sub fail(%trade, $reason) { self.reject(%trade, $reason) };
            return .&fail("Wrong type")                  if !.exists("type") || .<type> ne "trade";
            return .&fail("Player doesn't exist")        if !.exists("with");
            my $cp      = self.posse($!cp);
            my $op      = self.posse(.<with>);
            my $selling = posse-from-long(.<selling>);
            my $buying  = posse-from-long(.<buying>);
            self.trace("::effect-trade cp = $cp");
            self.trace("::effect-trade op = $op");
            self.trace("::effect-trade buying  = $buying");
            self.trace("::effect-trade selling = $selling");
            return .&fail("Not enough CP animals")       if                       $cp ⊉ $selling;
            return .&fail("Not enough OP animals")       if .<with> ne 'stock' && $op ⊉ $buying;
            return .&fail("Unequal trade")               if $selling.worth != $buying.worth;
            return .&fail("Null trade")                  unless all($buying,$selling).width >  0;
            return .&fail("Many-to-many trade")          unless any($buying,$selling).width == 1;
            return .&fail("Other player declined trade") unless
                (%!ac{.<with>} // -> %,@,$ {True})(%!p,@!e,$!cp);

            my $truncated = $op ∩ $buying;
            my $remark = $truncated ⊂ $buying ?? " (truncated => $truncated)" !! ""; 
            self.info("SWAP $!cp ↦",.<with>,": $selling <=> $buying" ~ $remark);
            self.transfer( $!cp, .<with>, $selling   );
            self.transfer( .<with>, $!cp, $truncated );
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
        self.trace("::effect-roll $!cp ~ $roll");
        self.publish: { :type<roll>, :player($!cp), :$roll };
        given $roll {
            when /[w]/ { 
                my $posse = self.posse($!cp);
                self.trace("::effect posse = $posse");
                if ('D' ∈ $posse)  {
                    # say "LOSE ", 'D'; 
                    self.transfer( $!cp, 'stock', 'D' )
                }
                else  {
                    # say "LOSE ", ~$posse.slice([<r s p c>]);
                    self.transfer( $!cp, 'stock', $posse.slice([<r s p c>]) )
                }
                proceed;
            }
            when /[f]/ { 
                my $posse = self.posse($!cp);
                self.trace("::effect posse = $posse");
                if ('d' ∈ $posse)  {
                    # say "LOSE ", 'd'; 
                    self.transfer( $!cp, 'stock', 'd' )
                }
                else  {
                    # say "LOSE ", ~$posse.slice([<r>]);
                    self.transfer( $!cp, 'stock', $posse.slice([<r>]) )
                }
                proceed;
            }
            default  {
                my $stock = self.posse('stock'); 
                my $posse = self.posse($!cp);
                self.trace("::effect posse = $posse");
                self.trace("::effect stock = $stock");
                my $desired = $posse ⚤ $roll;
                self.trace("::effect desired = $desired");
                my $allowed = $desired ∩ $stock;
                self.trace("::effect allowed = $allowed"); 
                # say "GAIN ", ~$allowed; 
                self.transfer( 'stock', $!cp, $allowed )
            }
        }
    }

    method transfer($from, $to, $what) {
        self.trace("::transfer $from => $to:  $what");
        if ($what)  {
             %!p{$to}    ⊎= $what;
             %!p{$from}  ∖= $what;
        }
        # self.trace("now: ", self.table);
        self.publish: { 
            :type<transfer>, :$from, :$to, 
            'animals' => "$what"
        };
    }

    sub posse-from-long(%h) { posse(long2short(%h)) }

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
        self.info("FAIL $!cp ↦ %i<op> : %i<sell> <=> %i<buy> : $reason");
        self.publish: { 
            :type<failed>, 
            :$reason, 
            :trader($!cp),
            :trade(deepclone(%trade)) 
        }
    }

    method publish(%event) {
        self.trace("::publish {%event.perl}");
        push @!e, {%event}
    }


    #
    # show what happened recently
    #
    method show-roll( :$was, :$now )  { 
        my %m = self.inspect-roll;
        self.trace("::meta = {%m.perl}");
        self.trace("::was = $was, now = $now");
        my $eaten = (defined %m<puts>) ?? "-%m<puts>" !! "";
        self.info("ROLL %m<player> $was ~ %m<roll> -> +%m<gets> $eaten » $now");
    }

    method inspect-roll {
        # self.debug("::inspect e = ", @!e.Int);
        my @ev = self.slice-recent-events-upto("type","roll");
        # self.debug("::inspect e = ", @!e.Int);
        self.debug("::inspect top = {@ev.perl}");
        for @ev -> %e  {
            self.debug("::inspect e = {%e.perl}")
        }

        my %r = shift @ev;
        self.debug("::inspect r = {%r.perl}");
        my $player  = %r<player>;
        my $roll    = %r<roll>;
        self.debug("::inspect player  = ", $player);
        self.debug("::inspect roll    = ", $roll);

        my (@gets,@puts);
        for @ev -> %e  {
            self.debug("::inspect e = {%e.perl}");
            my $animals = %e<animals>;
            my $from    = %e<from>;
            my $to      = %e<to>;
            self.debug("::inspect animals = ", $animals);
            self.debug("::inspect from    = ", $from);
            self.debug("::inspect to      = ", $to);
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
    # until a certain criterion -- here clumsily represnted by a
    # positional $k, $v pair -- is met.
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

    method incr {
        $!cp = "player_1" unless %!p.exists(++$!cp);
        $!j++
    }
    
};


=begin END


    # if (%!t{$!cp} // -> %, @ {;})({%!p}, @.e) -> $_ {
    # elsif not .{'selling'|'buying'}.values.reduce(&infix:<+>) == 1 {

            sub fail_trade(%trade, $reason) {
                self.publish: { 
                    :type<failed>, :$reason, :trader($!cp),
                    :trade(deepclone(%trade)) 
                }
            };

⚤
"»» ..";

↦ U+21A6

01234567890123456789012345678901234567890123456789012345678901234567890123456789

        # XXX ugh. why won't this work in p6?
        # my (%re,%te,@xtra) = @evens

            say "play j = $!j";
            say "ugh, ", $!j >= $!n;
            # last if (defined $!n) && ($!j >= $!n);
            # last if (@!r.Int > 0) && ($!j >= @!r);
            last if defined($!n) && $!j >= $!n;
            last if @!r.Int > 0  && $!j >= @!r;
            say "play ..";
            self.play-round() 

            {
                self.trace("selling = ", .<selling>.WHICH );
                self.trace("buying  = ", .<buying>.WHICH );
                self.trace("selling = ", .<selling> );
                self.trace("buying  = ", .<buying> );
                my %sell = .<selling>;
                my %buy  = .<buying>;
                self.trace("selling (long)  = ", {%sell}); 
                self.trace("buying  (long)  = ", {%buy});
                self.trace("selling (short) = ", long2short(%sell));
                self.trace("buying  (short) = ", long2short(%buy));
                # self.trace("selling = ", long2short(.<selling>));
                # self.trace("buying  = ", long2short(.<buying>));
            }

