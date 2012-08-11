use v6;
use Farm::Sim::Game;
use Farm::Sim::Posse;


multi MAIN($n)  {
    say "n = $n";
    my $game = Farm::Sim::Game.simple(3);
    $game.play($n);
}

=begin END

#    say "args = ", @*ARGS;
# my $N = $ARGS[0] // 3;
# say "first = ", $*ARGS[0];

