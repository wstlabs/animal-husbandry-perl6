use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Game;
use Farm::Sim::Posse;
use Test;
plan *;

sub test-seq($initial, @rolls, $expected)  {
    my $g;
    my $posse = posse($initial);
    my $rolls = ~@rolls;
    $g = Farm::Sim::Game.new(
        p => { "P1" => $posse },
        r => @rolls
    ).play;
    my $result = $g.posse("P1");
    ok $result eq $expected, "$initial ~ <$rolls> -> $expected ? [$result]";
}

{
    my $g;
    lives_ok { $g = Farm::Sim::Game.simple( k => 1) }; 
    lives_ok { $g.play(3) }; 
}

{
    test-seq 'p',   [<sw>],  '∅'    ;
    test-seq 'r',   [<rs>],  'r2'   ;
    test-seq 'r2',  [<rs>],  'r3'   ;
    test-seq 'r3',  [<rs>],  'r5'   ;
    test-seq 'sr',  [<rs>],  's2r2' ;
    test-seq 'sr2', [<sw>],  '∅'    ;
}

=begin END

some tests cases:
sr6 ~ fw
sr2 ~ sw -> +s -sr2 » s
