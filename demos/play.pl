#
# an alternate test harness for AH games; largey equivalent to carl's 
# original "farm.pl" script, except for the command-line usage, which
# now goes like this:
#
#  perl6 -Ilib demos/play.pl  ai <m> <n> <names>
#
# Where 
#
#   <m> refers to the number of contests to be run 
#   <n> sets an upper bound on the number of total of player 
#       rounds to be run; and
#   <names> are the names of from 2-6 individual strategy class
#       to run, i.e. classes under the namespace Farm::AI 
#
# Examples:
#
#  perl6 -Ilib demos/play.pl  ai 1 100 Naive Naive Naive 
#
#

#
use v6;
use Farm::Sim::Game; 
use Farm::Sim::Util::Load;

multi MAIN("simple", $n)  {
    my $g = Farm::Sim::Game.simple( 
       k => 3, :$n, loud => 1
    ).play;
}

multi MAIN("ai", $m, $n, *@names) {
    die 
        "Usage: $*PROGRAM_NAME ai <m> <n> <2..6 players>\n" ~
        "(Please see header comments for usage description)." 
        unless (my $k = +@names) ~~ 2..6 && $m > 0;
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

