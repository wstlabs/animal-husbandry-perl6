use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::AI::Posse;


my $y = Farm::AI::Posse.new;
say "y = $y";
$y.sum-in-place({ r => 2, s => 1 });
say "y = $y => ", $y.stringy-symbols();
$y.sum-in-place({ p => 1 }); # ok 
say "y = $y => ", $y.worth();

=begin END

