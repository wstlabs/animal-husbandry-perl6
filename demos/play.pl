use v6;
use Farm::Sim::Game; 
use Farm::Sim::Util::Load;

multi MAIN("simple", $n)  {
    say "n = $n";
    my $g = Farm::Sim::Game.simple( 
        k => 3, debug => 1, :$n 
    ).play;
    say "stats = ", $g.stats;
}

multi MAIN("ai", *@names) {
    die "Usage: $*PROGRAM_NAME ai <2..6 players>"
        unless (my $N = +@names) ~~ 2..6;
    for "Farm::AI::" <<~<< @names -> $module {
        require_strict($module)
    }
}

=begin END

