use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::AI::Posse;
use Farm::AI::Dice;


my $dice = Farm::AI::Dice.inst;
say "dice = $dice = ", $dice.WHICH;
my $d2   = Farm::AI::Dice.inst;
say "dice = $d2 = ",     $d2.WHICH;
say "dice = ", $dice;
say "f = ", $dice.f();
say "w = ", $dice.w();
