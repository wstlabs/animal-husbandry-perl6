use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Posse;
use Farm::Sim::Util::HashTup;
use KeyBag::Deco;
use KeyBag::Ops;
use Test;
plan *;

multi sub op-ok (Str $xx, Str $yy, Str $zz)  {
    my $x  = posse($xx);
    my $y  = posse($yy);
    my $z  = posse($zz);
    my $s   = $x ⚤ $y;
    my $ss  = $x ⚤ $yy;
    is "$s",  "$z",   "obj $x ⚤ $yy => $z";
    is "$ss", "$z",   "str $x ⚤ $yy => $z";
} 

multi sub op-ok (Str $xx, Str $yy, Nil $z)  {
    my $x  = posse($xx);
    my $y  = keybag(hashify($yy));
    my $s   = $x ⚤ $y;
    ok $s eqv Nil, "obj $x ⚤ $yy => Nil";
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

#
# politely decline breeding requests from foxes and wolves
#
{
    op-ok       'r',  'rw',  Nil  ;
    op-ok       'r',  'rf',  Nil  ;
    op-ok       'r',  'fw',  Nil  ;
    op-ok       'rs', 'fs',  Nil  ;
    op-ok       's2', 'fs',  Nil  ;
}

#
# throw if we're given anything invalid, i.e. which can't possibly
# represent a valid pair of die rolls (including strings with big or 
# small dog symbols).
#
# XXX most of these work, but currently the throw isn't properly typed.
#
{
    op-dies-ok  'r',  'rd'  ;
    op-dies-ok  'r',  'rD'  ;
    op-dies-ok  'r',  'rx'  ;
    op-dies-ok  'r',  '  '  ; 
    op-dies-ok  'r',  ' r'  ; 
    op-dies-ok  'r',  ''    ; 
    op-dies-ok  'r',  '∅'   ; # XXX fails!
    op-dies-ok  'r',  'abc' ;
}


=begin END

    # my $ss  = $x ⚤ $yy;
    # ok $ss eqv Nil, "str $x ⚤ $yy => Nil";
    # say "z  = ", $z.WHICH, " = ", $z;
    # say "s  = ", $s.WHICH, " = ", $s;
    # say "ss = ", $ss.WHICH, " = ", $ss;

