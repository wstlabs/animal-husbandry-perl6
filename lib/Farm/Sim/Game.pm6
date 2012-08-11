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
    submethod BUILD(:%!p, :@!e, :$!cp = 'P1') {
        %!p<stock> //= posse(%STOCK); 
        $!dice     //= Farm::Sim::Dice.instance;
        $!j = 0;
    }

    # instance generator which creates an empty game on $n players 
    method simple (Int $n)  {
        my %p = hash map { ; "P$_" => posse({}) }, 1..$n;
        self.new(p => %p)
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
        my $roll  = $!dice.roll;
        my $posse = self.posse($!cp);
        my @need  = $posse.need;
        say "::play step: $!j";
        say "::play curr: $!cp";
        say "::play have: $posse";
        say "::play need: ", @need.join('');
        say "::play roll: $roll";
        self.publish: { :type<roll>, :player($!cp), :$roll };
        self.broker($!cp,$roll);
        say "::play done: ?";
        self.show-recent;
        self.incr;
    }

    method broker(Str $player, Str $roll)  {
        my $stock = self.posse('stock'); 
        my $posse = self.posse($player);
        say "++ $player: $posse ~ $roll";
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
                my $desired = $posse ⚤ $roll;
                my $allowed = $desired ∩ $stock;
                say "::broker allowed = $allowed"; 
                self.transfer( 'stock', $player, $allowed )
            }
        }
    }

    method transfer($from, $to, $what) {
        say "xx $from => $to:  $what";
        if ($what)  {
             %!p{$to}    ⊎= $what;
             %!p{$from}  ∖= $what;
        }
        else  {
            # say "nothing to do!";
        }
        # say "now: ", self.table;
        self.publish: { 
            :type<transfer>, :$from, :$to, 
            'animals' => "$what"
        };
    }

    method publish(%event) {
        say "::publish ", {%event};
        push @!e, {%event}
    }

    method show-recent  {
        my $meta = self.inspect-recent;
        say "meta = ", $meta;
    }

    method inspect-recent {
        say "::inspect e = ", @!e.Int;
        my @top = self.slice-recent-events-upto("type","roll");
        say "::inspect top = {@top.perl}";
        for @top -> %e  {
            say "::inspect e = ", {%e}
        }
        # XXX ugh. why won't this work in p6?
        # my (%re,%te,@xtra) = @top;
        my %re = shift @top;
        my %te = shift @top;
        say "::inspect re = ", %re;
        say "::inspect te = ", %te;
        my $player  = %re<player>;
        my $roll    = %re<roll>;
        my $animals = %te<animals>;
        my $from    = %te<from>;
        my $to      = %te<to>;
        say "::inspect player  = ", $player;
        say "::inspect roll    = ", $roll;
        say "::inspect animals = ", $animals;
        say "::inspect from    = ", $from;
        say "::inspect to      = ", $to;
        say "::inspect e = ", @!e.Int;
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
say "»» ..";

