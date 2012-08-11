use v6;
use Farm::Sim::Game;

multi MAIN($n)  {
    say "n = $n";
    Farm::Sim::Game.simple( 
        k => 3, debug => 1
    ).play($n)
}

=begin END

