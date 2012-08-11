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
    has $!dice;
    has $!j = 0;
    submethod BUILD(:%!p,:$!cp) {
        %!p<stock> //= posse(%STOCK); 
        $!dice     //= Farm::Sim::Dice.instance;
    }

    # instance generator which creates an empty game on $n players 
    method simple (Int $n)  {
        my %p = hash map { ; "P$_" => posse({}) }, 1..$n;
        self.new(p => %p, cp => "P1")
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
        self.broker($!cp,$roll);
        say "::play done: ?";
        self.incr;
    }

    method broker(Str $player, Str $roll)  {
        my $stock = self.posse('stock'); 
        my $posse = self.posse($player);
        say "++ $player: $posse => $roll";
        given $roll {
            when /[w]/ { 
                if ('D' ∈ $posse)  {
                    self.transfer( $player, 'stock', 'D' )
                }
                else  {
                    self.transfer( $player, 'stock', $posse.slice([<r s p c>]) )
                }
            }
            when /[f]/ { 
                if ('d' ∈ $posse)  {
                    self.transfer( $player, 'stock', 'd' )
                }
                else  {
                    self.transfer( $player, 'stock', $posse.slice([<r>]) )
                }
            }
            default  {
                my $desired = $posse ⚤ $roll;
                my $allowed = $desired ∩ $stock;
                say ":: allowed = $allowed"; 
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
        # self.publish: { :type<transfer>, :$from, :$to, :%animals };
    }

    method incr {
        $!cp = "P1" unless %!p.exists(++$!cp);
        $!j++
    }
    
};


=begin END

⚤
say "»» ..";


                    self.transfer(
                        from: $player,
                        to:   $stock,
                        what: 'D' 
                    )

                if ($allowed)  {
                    $posse ⊎= $allowed;
                    $stock ∖= $allowed;
                }

        say "have: $posse « ", @need.join('');

        my $roll = $Dice.roll;
        if (! $roll ~~ / [fw] / ) {
            my $desired = $X.posse ⚤ $roll;
            my $allowed = $desired ∩ $S.posse;
            if ($allowed)  {
                $X.posse ⊎= $allowed;
                $S.posse ∖= $allowed;
            }
        }


