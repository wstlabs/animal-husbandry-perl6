#
# an alternate test harness for AH games; largey equivalent to carl's 
# original "farm.pl" script, except for the command-line usage, which
# now goes like the barf provided to the die statement int the second 
# MAIN block, below.
#
# To explain that usage a bit further:
#
#   <k> (required) refers to the number of contests to be run
#   <n> (optional) an upper bound on the number of total of rounds 
#       to be played (may be set very high)
#   <names> (required) are the names of from 2-6 individual strategy class
#       to run, i.e. classes under the namespace Farm::AI 
#   <verbose> is an optional logging level (0..2), defulting to 1. 
#
# Examples:
#
#  perl6 -Ilib demos/play.pl  --n=100 ai 1 Naive Naive 
#  perl6 -Ilib demos/play.pl  --verbose=0 --n=200 ai 50 Naive Naive Naive 
#
# To clarify the logging levels:
#
#    --verbose=0 => totally quiet
#    --verbose=1 => bare "play-by-play" status tracing 
#    --verbose=2 => some internal logging 
#    --verbose=3 => noisy internal logging 
#

#
use v6;
use Farm::Sim::Game; 
use Farm::Sim::Util::Load;

multi MAIN("simple", :$n, :$verbose)  {
    my $g = Farm::Sim::Game.simple( 
       k => 3, :$n, :$verbose 
    ).play;
}

multi MAIN("ai", $k, *@names, :$n=1, :$verbose=1) {
    die 
        "Usage: $*PROGRAM_NAME ai [--n=1..*] [--verbose=0..2] <k=1..*> <2..6 players>\n" ~
        "(Please see header comments for usage description)." 
        unless (my $p = +@names) ~~ 2..6 && $k > 0 && $n > 0;
    # say "::MAIN k=$k, n=$n, verbose=$verbose, names = [{@names}]";
    for "Farm::AI::" <<~<< @names -> $module {
        require_strict($module)
    }

    my %strategy;
    my @players = map -> $i,$name  { 
        my $player = "player_{$i+1}";
        # say "::MAIN name = $name, player = [$player]";
        %strategy{$player} = (eval "Farm::AI::$name").new( 
            player => $player, :$verbose
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

    # XXX stat hashes are slightly buggy; see the commendt above the block 
    # for that method. 
    for (1..$k) -> $i  {
        my $stats = Farm::Sim::Game.contest(
            players => @players, :%tr, :%ac, :$n, :$verbose 
        ).play.stats;
        if ($verbose)  {
            say "STAT $i = ", $stats; 
        }
    }

}

=begin END

        # say "::MAIN game ($i) = ", $game.WHICH; 
        # $game.play();
        # my $stats = $game.stats;
        # my $stats = $game.play($n).stats;

