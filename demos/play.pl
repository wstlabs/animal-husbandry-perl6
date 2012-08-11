use v6;
use Farm::Sim::Game;

multi MAIN($n)  {
    say "n = $n";
    my $game = Farm::Sim::Game.simple(3);
    $game.play($n);
}

=begin END

