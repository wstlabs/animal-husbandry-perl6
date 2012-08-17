#
# an alternate test harness for AH games; largey equivalent to carl's 
# original "farm.pl" script, except for the command-line usage, which
# now goes like this:
#
#  perl6 -Ilib demos/play.pl  ai <m> <n> <names>
#
# Where 
#
#   <k> (required) refers to the number of contests to be run 
#   <n> (required) upper bound on the number of total of rounds to be played
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

multi MAIN("simple", :$n, :$loud)  {
    my $g = Farm::Sim::Game.simple( 
       k => 3, :$n, :$loud 
    ).play;
}

multi MAIN("ai", $k, *@names, :$n=1, :$loud=0) {
    die 
        "Usage: $*PROGRAM_NAME ai [--n=1..*] [--loud=0..2] <k> <2..6 players>\n" ~
        "(Please see header comments for usage description)." 
        unless (my $p = +@names) ~~ 2..6 && $k > 0 && $n > 0;
    # say "::MAIN k=$k, n=$n, loud=$loud, names = [{@names}]";
    for "Farm::AI::" <<~<< @names -> $module {
        require_strict($module)
    }

    my %strategy;
    my @players = map -> $i,$name  { 
        my $player = "player_{$i+1}";
        # say "::MAIN name = $name, player = [$player]";
        %strategy{$player} = (eval "Farm::AI::$name").new( 
            player => $player, :$loud
        );
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

    for (1..$k) -> $i  {
        # say "::MAIN game ($i):  n = $n ..";
        my $game = Farm::Sim::Game.contest(
            players => @players, :%tr, :%ac, :$n, :$loud 
        );
        # say "::MAIN game ($i) = ", $game.WHICH; 
        $game.play();
        my $stats = $game.stats;
        # my $stats = $game.play($n).stats;
        say "STAT $i = ", $stats; 
    }

}


=begin END

