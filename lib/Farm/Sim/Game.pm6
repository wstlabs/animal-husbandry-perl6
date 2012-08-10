use v6;
# use KeyBag::Ops;
use Farm::Sim::Util;
use Farm::Sim::Posse;

my @frisky is ro = frisky-animals();
constant %STOCK = {
    r => 60, s => 24, p => 20, c => 12, h => 6, 
    d =>  4, D =>  2
};

class Farm::Sim::Game  {
    has %!p;
    submethod BUILD(:%!p) {
        %!p<stock> //= posse(%STOCK); 
    }

    # instance generator which creates an empty game on $n players 
    method simple (Int $n)  {
        my %p = hash map -> $k, { "T$k" => posse({}) }, 1..$n;
        self.new(p => %p)
    }

    method posse (Str $name)  { %!p{$name}.clone }
    method players { %!p.keys.sort }
    method table {
        hash map -> $k,$v {
            $k => $v.Str
        }, %!p.kv
    }
};


=begin END

