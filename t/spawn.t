use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Posse;
use KeyBag::Ops;
use Test;
plan *;

#
# a couple of overly exhaustive eqv checks, to control for the 
# various things that can go wrong with the eqv and eq ops,
# independent of the .spawn op itself
#
sub exhaust-op ($xx, $yy, $zz)  {
    my $x  = posse($xx);
    my $y  = posse($yy);
    my $z  = posse($zz);
    my $s  = $x ⚤  $y;
    my $ss = $x ⚤  $yy;
    ok $s  eq  $z,  "$x ⚤ $y => $s eq  $z";
    ok $s  eqv $z,  "$x ⚤ $y => $s eqv $z";
    ok $ss eq  $z,  "$x ⚤ $y => $ss eqv $z";
    ok $ss eqv $z,  "$x ⚤ $y => $ss eqv $z";
} 

sub exhaust-method ($xx, $yy, $zz)  {
    my $x  = posse($xx);
    my $y  = posse($yy);
    my $z  = posse($zz);
    my $s  = $x.spawn($y);
    my $ss = $x.spawn($yy);
    ok $s  eq  $z,  "$x ⚤ $y => $s eq  $z";
    ok $s  eqv $z,  "$x ⚤ $y => $s eqv $z";
    ok $ss eq  $z,  "$x ⚤ $y => $ss eqv $z";
    ok $ss eqv $z,  "$x ⚤ $y => $ss eqv $z";
} 

{
    exhaust-method 'r', 'r2', 'r';
    exhaust-op     'r', 'r2', 'r';
}


#
# a more lightweight eqv test
#
sub check-op ($xx, $yy, $zz)  {
    my $x  = posse($xx);
    my $y  = posse($yy);
    my $z  = posse($zz);
    my $s  = $x ⚤ $y;
    # ok $s eqv $z,  "$x ⚤ $y => $s eqv $z (exp)";
    is "$s", "$z",   "$x ⚤ $y => $s"
} 

#
# homogenous cases 
#
{
    check-op       'r',  'rp', 'r'  ;
    check-op       'r',  'rr', 'r'  ;
    check-op       'r2', 'rp', 'r'  ;
    check-op       'r3', 'rr', 'r2' ;
    check-op       '∅',  'rr', 'r'  ;
    check-op       '∅',  'rs', '∅'  ;
}

#
# small mixed cases 
#
{
    check-op       'r',    'sp', '∅'   ;
    check-op       'rs',   'sp', 's'   ;
    check-op       's',    'rs', 's'   ;
    check-op       'rs',   'rp', 'r'   ;
    check-op       'r',    'rs', 'r'   ;
    check-op       'r',    'ss', 's'   ;
    check-op       'r2',   'rs', 'r'   ;
    check-op       'r2',   'rr', 'r2'  ;
    check-op       'rs2',  'rs', 'rs'  ;
    check-op       'rs2',  'ss', 's2'  ;
    check-op       'rs',   'rs', 'rs'  ;
    check-op       'r2s2', 'rs', 'rs'  ;
    check-op       'r3s3', 'rs', 'r2s2'  ;
    check-op       'r4s3', 'rs', 'r2s2'  ;
    check-op       'r3s4', 'rs', 'r2s2'  ;
    check-op       'r4s4', 'rs', 'r2s2'  ;
    check-op       'r5s5', 'rs', 'r3s3'  ;
}


#
# XXX failing mixed cases 
#
{
    check-op       'r2',   'sp', '∅'  ;
    check-op       's2',   'rp', '∅'  ;
    check-op       'rs2',  'rp', 'r'  ;
    check-op       'rs2',  'rr', 'r'  ;
    check-op       'rs',   'pp', '∅'  ;
    check-op       'r3s2', 'ss', 's2' ;
    check-op       'r3s2', 'rp', 'r2' ;
    check-op       'r3s2', 'sp', 's'  ;
}


=begin END

    # say "z  = ", $z.WHICH, " = ", $z;
    # say "s  = ", $s.WHICH, " = ", $s;
    # say "ss = ", $ss.WHICH, " = ", $ss;

