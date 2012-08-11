use v6;
use Farm::Sim::Util;
use Farm::Sim::Posse;
use Farm::Sim::Dice;
use KeyBag::Ops;

my @frisky is ro = frisky-animals();
constant %STOCK = {
    r => 60, s => 24, p => 20, c => 12, h => 6, 
    d =>  4, D =>  2
};

class Farm::Sim::Game  {
    has %!p;
    has $!cp;
    has @!e;
    has $!dice;
    has $!j;
    has @!r, 
    has $!debug;
    submethod BUILD(:%!p, :@!e, :$!cp = 'P1', :@!r, :$!debug) {
        %!p<stock> //= posse(%STOCK); 
        $!dice     //= Farm::Sim::Dice.instance;
        $!j = 0;
    }

    method trace(*@a)  { if ($!debug > 0)  { say @a } }
    method debug(*@a)  { if ($!debug > 1)  { say @a } }

    # instance generator which creates an empty game on $n players 
    # method simple ($n,$debug)  {
    method simple (:$k,:$debug)  {
        my %p = hash map { ; "P$_" => posse({}) }, 1..$k;
        self.new(p => %p, :$debug)
    }

    method posse (Str $name)  { %!p{$name}.clone }
    method players { %!p.keys.sort }
    method table {
        hash map -> $k,$v {
            $k => $v.Str
        }, %!p.kv
    }


    method play(Int $n where { $n > 0 })  {
        self.play_round() for 1..$n 
    }
    
    method play_round  {
        my $roll  = @!r[$!j] // $!dice.roll;
        my $posse = self.posse($!cp);
        my @need  = $posse.need;
        self.trace("::play step: $!j");
        self.trace("::play curr: $!cp");
        self.trace("::play have: $posse");
        self.trace("::play need: ", @need.join('') );
        self.trace("::play roll: $roll");
        self.publish: { :type<roll>, :player($!cp), :$roll };
        self.broker($!cp,$roll);
        self.trace( "::play done: ?");
        self.show-recent;
        self.incr;
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
    method broker(Str $player, Str $roll)  {
        my $stock = self.posse('stock'); 
        my $posse = self.posse($player);
        self.trace("++ $player: $posse ~ $roll");
        given $roll {
            when /[w]/ { 
                if ('D' ∈ $posse)  {
                    self.transfer( $player, 'stock', 'D' )
                }
                else  {
                    self.transfer( $player, 'stock', $posse.slice([<r s p c>]) )
                }
                proceed;
            }
            when /[f]/ { 
                if ('d' ∈ $posse)  {
                    self.transfer( $player, 'stock', 'd' )
                }
                else  {
                    self.transfer( $player, 'stock', $posse.slice([<r>]) )
                }
                proceed;
            }
            default  {
                self.trace("::effect posse = $posse");
                self.trace("::effect roll  = $roll"); 
                my $desired = $posse ⚤ $roll;
                self.trace("::effect desired = $desired");
                self.trace("::effect stock   = $stock"); 
                my $allowed = $desired ∩ $stock;
                self.trace("::effect allowed = $allowed"); 
                self.transfer( 'stock', $player, $allowed )
            }
        }
    }

    method transfer($from, $to, $what) {
        self.trace("xx $from => $to:  $what");
        if ($what)  {
             %!p{$to}    ⊎= $what;
             %!p{$from}  ∖= $what;
        }
        else  {
            # self.trace("nothing to do!");
        }
        # self.trace("now: ", self.table);
        self.publish: { 
            :type<transfer>, :$from, :$to, 
            'animals' => "$what"
        };
    }

    method publish(%event) {
        self.trace("::publish ", {%event});
        push @!e, {%event}
    }

    method show-recent  {
        my $meta = self.inspect-recent;
        self.trace("meta = ", $meta);
    }

    method inspect-recent {
        self.trace("::inspect e = ", @!e.Int);
        my @top = self.slice-recent-events-upto("type","roll");
        self.trace("::inspect top = {@top.perl}");
        for @top -> %e  {
            self.trace("::inspect e = ", {%e})
        }
        # XXX ugh. why won't this work in p6?
        # my (%re,%te,@xtra) = @top;
        my %re = shift @top;
        my %te = shift @top;
        self.trace("::inspect re = ", %re);
        self.trace("::inspect te = ", %te);
        my $player  = %re<player>;
        my $roll    = %re<roll>;
        my $animals = %te<animals>;
        my $from    = %te<from>;
        my $to      = %te<to>;
        self.trace("::inspect player  = ", $player);
        self.trace("::inspect roll    = ", $roll);
        self.trace("::inspect animals = ", $animals);
        self.trace("::inspect from    = ", $from);
        self.trace("::inspect to      = ", $to);
        self.trace("::inspect e = ", @!e.Int);
        if ($from eq 'stock') {
            return { :$player, :$roll, gets => $animals, :$from }
        }
        else {
            return { :$player, :$roll, puts => $animals, :$to }
        }

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
        $!cp = "P1" unless %!p.exists(++$!cp);
        $!j++
    }
    
};


=begin END

⚤
"»» ..";

