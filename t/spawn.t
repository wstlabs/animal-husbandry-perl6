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
sub op-exhaust-infix ($xx, $yy, $zz)  {
    my $x  = posse($xx);
    my $y  = posse($yy);
    my $z  = posse($zz);
    my $s  = $x ⚤  $y;
    my $ss = $x ⚤  $yy;
    ok $z  eqv $s,   "$x ⚤ $y => $z eqv $s";
    ok $z  eqv $ss,  "$x ⚤ $y => $z eqv $ss";
    ok $z  eq  $s,   "$x ⚤ $yy => $z eq  $s";
    ok $z  eq  $ss,  "$x ⚤ $yy => $z eq  $ss";
} 

sub op-exhaust-method ($xx, $yy, $zz)  {
    my $x  = posse($xx);
    my $y  = posse($yy);
    my $z  = posse($zz);
    my $s  = $x.spawn($y);
    my $ss = $x.spawn($yy);
    ok $z  eqv $s,   "$x.spawn($y) => $z eqv $s";
    ok $z  eqv $ss,  "$x.spawn($y) => $z eqv $ss";
    ok $z  eq  $s,   "$x.spawn($yy) => $z eq  $s";
    ok $z  eq  $ss,  "$x.spawn($yy) => $z eq  $ss";
} 

{
    op-exhaust-infix    'r', 'r2', 'r';
    op-exhaust-method   'r', 'r2', 'r';
}


#
# a more lightweight eqv test
#
multi sub op-ok (Str $xx, Str $yy, Str $zz)  {
    my $x  = posse($xx);
    my $y  = posse($yy);
    my $z  = posse($zz);
    my $s   = $x ⚤ $y;
    my $ss  = $x ⚤ $yy;
    is "$s",  "$z",   "obj $x ⚤ $y => $z";
    is "$ss", "$z",   "str $x ⚤ $yy => $z";
} 

multi sub op-ok (Str $xx, Str $yy, Nil $z)  {
    my $x  = posse($xx);
    my $y  = posse($yy);
    my $s   = $x ⚤ $y;
    ok $s eqv Nil, "obj $x ⚤ $y => Nil";
    # my $ss  = $x ⚤ $yy;
    # ok $ss eqv Nil, "str $x ⚤ $yy => Nil";
    # say "z  = ", $z.WHICH, " = ", $z;
    # say "s  = ", $s.WHICH, " = ", $s;
    # say "ss = ", $ss.WHICH, " = ", $ss;
} 

sub op-dies-ok (Str $xx, Str $yy)  {
    dies_ok {
        my $x  = posse($xx);
        my $y  = posse($yy);
        my $s  = $x ⚤ $y;
    },"$xx ⚤ $yy => throws";
}

#
# homogenous cases 
#
{
    op-ok       'r',  'rp', 'r'  ;
    op-ok       'r',  'rr', 'r'  ;
    op-ok       'r2', 'rp', 'r'  ;
    op-ok       'r3', 'rr', 'r2' ;
    op-ok       '∅',  'rr', 'r'  ;
    op-ok       '∅',  'rs', '∅'  ;
}

#
# small mixed cases 
#
{
    op-ok       'r',    'sp', '∅'   ;
    op-ok       'rs',   'sp', 's'   ;
    op-ok       's',    'rs', 's'   ;
    op-ok       'rs',   'rp', 'r'   ;
    op-ok       'r',    'rs', 'r'   ;
    op-ok       'r',    'ss', 's'   ;
    op-ok       'r2',   'rs', 'r'   ;
    op-ok       'r2',   'rr', 'r2'  ;
    op-ok       'rs2',  'rs', 'rs'  ;
    op-ok       'rs2',  'ss', 's2'  ;
    op-ok       'rs',   'rs', 'rs'  ;
    op-ok       'rs',   'rr', 'r'   ;
    op-ok       'rs',   'ss', 's'   ;
    op-ok       'rs',   'rr', 'r'   ;
    op-ok       's2',   'rr', 'r'   ;
    op-ok       'rs',   'pp', 'p'   ;
    op-ok       'r2s2', 'rs', 'rs'  ;
    op-ok       'r3s3', 'rs', 'r2s2'  ;
    op-ok       'r4s3', 'rs', 'r2s2'  ;
    op-ok       'r3s4', 'rs', 'r2s2'  ;
    op-ok       'r4s4', 'rs', 'r2s2'  ;
    op-ok       'r5s5', 'rs', 'r3s3'  ;
}


#
# XXX failing mixed cases 
#
{
    op-ok       'r2',   'sp', '∅'  ;
    op-ok       's2',   'rp', '∅'  ;
    op-ok       'rs2',  'rp', 'r'  ;
    op-ok       'rs2',  'rr', 'r'  ;
    op-ok       'r3s2', 'ss', 's2' ;
    op-ok       'r3s2', 'rp', 'r2' ;
    op-ok       'r3s2', 'sp', 's'  ;
}

{
    op-ok       'r',  'rw',  Nil  ;
    op-ok       'r',  'fs',  Nil  ;
    op-ok       'r',  'fw',  Nil  ;
    op-ok       'rw', 'rw',  Nil  ;
    op-ok       'rs', 'fs',  Nil  ;
    op-ok       'w',  'rw',  Nil  ;
    op-ok       's2', 'fs',  Nil  ;
    op-ok       'f2', 'fs',  Nil  ;
    op-ok       'fs', 'fs',  Nil  ;
    op-ok       'fw', 'fw',  Nil  ;
}

{
    op-dies-ok  'r',  'rd' ;
    op-dies-ok  'r',  'rD' ;
    op-dies-ok  'r',  'rx' ;
}


=begin END

    # say "z  = ", $z.WHICH, " = ", $z;
    # say "s  = ", $s.WHICH, " = ", $s;
    # say "ss = ", $ss.WHICH, " = ", $ss;
    # ok $s eqv $z,  "$x ⚤ $y => $s eqv $z (exp)";

    dies_ok {
        my $x  = posse($xx);
        my $y  = posse($yy);
        my $s  = $x.spawn($y);
    },"$x.spawn($y) => die";

