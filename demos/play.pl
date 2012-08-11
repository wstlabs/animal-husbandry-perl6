use v6;
use Farm::Sim::Game;

multi MAIN($n)  {
    say "n = $n";
    my $g = Farm::Sim::Game.simple( 
        k => 3, debug => 1, :$n 
    ).play;
    say "stats = ", $g.stats;
}

=begin END


