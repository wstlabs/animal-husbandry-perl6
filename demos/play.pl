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

    # say "names = [{@names}]";
    my @players = map -> $i, $name {
        my $player = "player_{$i+1}";
        # say "i = $i, name = $name, player = [$player]";
        (eval "Farm::AI::$name").new( player => "player_{$i+1}" );
    }, @names.kv;
    say "players = ", @players;

    my $game = Game.new(
        p  => hash(map {; "player_$_" => {} },                      1..$N),
        t  => hash(
            map {
                ;
                "player_$_" => -> %p, @e {
                    @players[$_-1].trade(%p, @e)
                }
            }, 1..$N
        ),
        at => hash(
            map {
                ;
                "player_$_" => -> %p, @e, $tp {
                    @players[$_-1].accept(%p, @e, $tp)
                }
            }, 1..$N
        ),
    );

    my $round = 0;
    repeat until $game.e[*-1] ~~ :type<win> {
        say "Round ", ++$round;
        $game.play_round();
    }
    say "$game.who_won() won!";


