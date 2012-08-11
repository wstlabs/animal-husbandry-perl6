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

    method broker(Farm::Sim::Posse $posse, Str $roll)  {
        my $stock = %!p<stock>;
        say "++ $posse => $roll";
        given $roll {
            when /[w]/ { say "++ wolf!" }
            when /[f]/ { say "++ fox!" }
            default  {
                my $desired = $posse ⚤ $roll;
                my $allowed = $desired ∩ $stock;
                if ($allowed)  {
                    $posse ⊎= $allowed;
                    $stock ∖= $allowed;
                }
            }
        }
    }
    
    method play_round  {
        my $roll  = $!dice.roll;
        my $posse = self.posse($!cp);
        my @need  = $posse.need;
        say "step: $!j";
        say "curr: $!cp";
        say "have: $posse";
        say "need: ", @need.join('');
        self.broker($posse,$roll);
        say "roll: $roll » ? ";
        self.incr;
    }

    method incr {
        $!cp = "P1" unless %!p.exists(++$!cp);
        $!j++
    }
    
    method play(Int $n where { $n > 0 })  {
        self.play_round() for 1..$n 
    }

};


=begin END

⚤

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


