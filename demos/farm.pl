use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Posse;
use KeyBag::Ops;


my $y = Farm::Sim::Posse.new;
say "y = $y = ", $y.WHICH;
$y.sum-in-place({ r => 2, s => 1 });
# say "y = $y => ", $y.stringy-symbols();
$y.sum-in-place({ p => 1 }); # ok 
say "y = $y => ", $y.worth();

=begin END

