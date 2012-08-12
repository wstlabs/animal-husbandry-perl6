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
        r => @rolls, 
        debug => 1
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
    # from the instructions 
    test-seq '∅',    [<rr>],  'r'    ;
    test-seq 'r3',   [<pr>],  'r5'   ;
    test-seq 's5r3', [<rs>],  's8r5' ;
    test-seq 'c10',  [<rs>],  'c10'  ;
}

{
    # vanilla
    test-seq '∅',    [<rs>],  '∅'    ;
    test-seq 'p',    [<rs>],  'p'    ;
    test-seq 'r',    [<rr>],  'r2'   ;
    test-seq 'r2',   [<rr>],  'r4'   ;
    test-seq 'r',    [<rs>],  'r2'   ;
    test-seq 's',    [<rs>],  's2'    ;
    test-seq 'r2',   [<rs>],  'r3'   ;
    test-seq 'r3',   [<rs>],  'r5'   ;
    test-seq 'sr',   [<rs>],  's2r2' ;
}

{
    # predator (unguarded)
    test-seq 'sr3',  [<fr>],  's'    ;
    test-seq 'sr3',  [<fs>],  's2'   ;
    test-seq 'sr3',  [<fp>],  's'    ;
    test-seq 'rps',  [<fs>],  'ps2'  ;
    test-seq 'rps',  [<fp>],  'p2s'  ;
    test-seq 'pr3',  [<rw>],  '∅'    ;
    test-seq 'p',    [<sw>],  '∅'    ;
    test-seq 'sr2',  [<sw>],  '∅'    ;
    test-seq 'sr3',  [<sw>],  '∅'    ;
    test-seq 'cs',   [<sw>],  '∅'    ;
    test-seq 'hp',   [<sw>],  'h'    ;
    test-seq 'hpc',  [<pw>],  'h'    ;
    test-seq 'hp2',  [<hw>],  'h2'   ;
    test-seq 'pcr',  [<fw>],  '∅'    ;
    test-seq 'hpc',  [<fw>],  'h'    ;
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

