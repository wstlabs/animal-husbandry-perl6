use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Posse;
use Farm::Sim::Dice;


my $dice = Farm::Sim::Dice.instance;
say "dice = $dice = ", $dice.WHICH;
my $d2   = Farm::Sim::Dice.instance;
say "dice = $d2 = ",     $d2.WHICH;
say "dice = ", $dice;
say "f = ", $dice.f().WHICH;
say "w = ", $dice.w().WHICH;
say "f = ", $dice.f();
say "w = ", $dice.w();

for (1..5)  {
    say $dice.roll
}

my %h = $dice.dist();
say "dist = ", %h; 
