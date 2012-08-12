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

#
# basic smoketest (non-deterministic)
#
{
    my $g;
    lives_ok { $g = Farm::Sim::Game.simple( k => 1) }; 
    lives_ok { $g.play(3) }; 
}


#
# deterministic unit tests
#

{
    # vanilla
    test-seq 'p',   [<sw>],  '∅'    ;
    test-seq 'r',   [<rs>],  'r2'   ;
    test-seq 'r2',  [<rs>],  'r3'   ;
    test-seq 'r3',  [<rs>],  'r5'   ;
    test-seq 'sr',  [<rs>],  's2r2' ;
}

{
    # predator (unguarded)
    test-seq 'sr3', [<fr>],  's'    ;
    test-seq 'sr3', [<fs>],  's2'   ;
    test-seq 'sr3', [<fp>],  's'    ;
    test-seq 'rps', [<fs>],  'ps2'  ;
    test-seq 'rps', [<fp>],  'p2s'  ;
    test-seq 'pr3', [<rw>],  '∅'    ;
    test-seq 'sr2', [<sw>],  '∅'    ;
    test-seq 'sr3', [<sw>],  '∅'    ;
    test-seq 'cs' , [<sw>],  'c'    ;
    test-seq 'hpc', [<pw>],  'h'    ;
    test-seq 'hp2', [<hw>],  'h2'   ;
    test-seq 'sr3', [<fw>],  '∅'    ;
    test-seq 'hpc', [<fw>],  '∅'    ;
}

{
    # predator (guarded)
    test-seq 'dr3', [<fs>],  'r3'   ;
    test-seq 'dr3', [<fr>],  'r5'   ;
    test-seq 'dp',  [<fp>],  'p2'   ;
    test-seq 'Dr',  [<wr>],  'r2'   ;
    test-seq 'Ds',  [<ws>],  's2'   ;
    test-seq 'Dp',  [<wp>],  'p2'   ;
}


=begin END

some tests cases:
sr6 ~ fw
sr2 ~ sw -> +s -sr2 » s

