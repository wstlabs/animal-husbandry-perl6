use v6;
use Farm::Sim::Game; 
use Farm::Sim::Util::Load;

multi MAIN("simple", $n)  {
    my $g = Farm::Sim::Game.simple( 
       k => 3, :$n, loud => 1
    ).play;
}

multi MAIN("ai", $m, $n, *@names) {
    die "Usage: $*PROGRAM_NAME ai <m> <n> <2..6 players>"
        unless (my $k = +@names) ~~ 2..6;
    # say "::MAIN names = [{@names}]";
    for "Farm::AI::" <<~<< @names -> $module {
        require_strict($module)
    }

    my %strategy;
    my @players = map -> $i,$name  { 
        my $player = "player_{$i+1}";
        # say "::MAIN name = $name, player = [$player]";
        %strategy{$player} = (eval "Farm::AI::$name").new( player => $player );
        $player
    }, @names.kv;
    # say "::MAIN players    = ", @players;
    # say "::MAIN strategies = ", %strategy.values; 

    my %tr = hash 
        map -> $who {
            ; $who => -> %p,@e     { %strategy{$who}.trade(%p,@e) }
        }, @players
    ;
    # say "::MAIN tr = ", %tr;

    my %ac = hash
        map -> $who {
            ; $who => -> %p,@e,$tp { %strategy{$who}.accept(%p,@e,$tp) }
        }, @players
    ; 
    # say "::MAIN ac = ", %ac;

    for (1..$m) -> $i  {
        my $game = Farm::Sim::Game.contest(
            players => @players, :%tr, :%ac, loud => 2 
        );
        # say "::MAIN game ($i) = ", $game.WHICH; 
        $game.play($n);
        my $stats = $game.stats;
        # my $stats = $game.play($n).stats;
        say "STAT $i = ", $stats; 
    }

}


=begin END

