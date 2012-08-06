use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Util::HashTup;
use Test;
plan *;

sub test_bij($s, %h)  {
    ok  hashify($s)   eqv %h, "$s --> Hash";
    ok  stringify(%h) eq  $s, "$s <-- Hash";
}

sub test_surj($s, %h)  {
    my $x;
    ok  hashify($s) eqv %h,       "$s --> Hash eqv Hash";
}

#
# straightforward (bijective) cases
#
{
    test_bij '∅',    {}                  ;
    test_bij 'x',    { x => 1 }          ;
    test_bij 'x2',   { x => 2 }          ;
    test_bij 'x666', { x => 666 }        ;
    test_bij 'xy',   { x => 1, y => 1 }  ;
    test_bij 
        'x2y3zw', { 
            x => 2, y => 3, z => 1, w => 1 
        }
    
}



#
# non-bijective cases
#
{
    test_surj( 'xx',   { x => 2 } );
    test_surj( 'x3x2', { x => 5 } );
    test_surj( 'x0',   {}          );
    test_surj( 'x01',  { x => 1 }  );
    test_surj( 'x0y',  { y => 1}   );
    test_surj( 'x0x',  { x => 1 }  );
}

#
# failing cases
#
{
    constant @malformed = ( 
        '',
        ' ',' x','x0 ';
        '2x', '3x2', 
        '∅∅', 'a∅', '∅b', 
        '∅0', '∅1', '∅2', 
        '∅2a', 'a∅2', 'x0∅', 'a1∅',
        'r-1', 'r1/2', 'r1.0',
        '0r', '1r', '2r3',
         0, 1, 2, '2'
    );

    for @malformed -> $s {
        dies_ok { my %h = hashify($s) }, "malformed: $s"
    }

}





