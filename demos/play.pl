use v6;
use Farm::Sim::Game;

multi MAIN("simple", $n)  {
    say "n = $n";
    my $g = Farm::Sim::Game.simple( 
        k => 3, debug => 1, :$n 
    ).play;
    say "stats = ", $g.stats;
}

multi MAIN("ai", *@names) {
    # say "names = [{@names}]";
    die "Usage: $*PROGRAM_NAME ai <2..6 players>"
        unless (my $N = +@names) ~~ 2..6;
    for "Farm::AI::" <<~<< @names -> $module {
        # say "require [$module] ..";
        require $module;
        my $class = eval($module);
        die "No class definition found for $module"
            if $class ~~ Failure;
        for <trade accept> -> $method {
            die "$module does not have a .$method method"
                unless $class.can($method);
            die ".$method method in $module has wrong arity"
                unless $class.^methods.grep($method)[0].arity
                    == { trade => 3, accept => 4 }{$method};
        }
    }
}

=begin END


