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
    op-ok       'sr',   'sp', 's'   ;
    op-ok       's',    'rs', 's'   ;
    op-ok       'sr',   'rp', 'r'   ;
    op-ok       'r',    'rs', 'r'   ;
    op-ok       'r',    'ss', 's'   ;
    op-ok       'r2',   'rs', 'r'   ;
    op-ok       'r2',   'rr', 'r2'  ;
    op-ok       's2r',  'rs', 'rs'  ;
    op-ok       's2r',  'ss', 's2'  ;
    op-ok       'rs',   'rs', 'rs'  ;
    op-ok       'rs',   'rr', 'r'   ;
    op-ok       'rs',   'ss', 's'   ;
    op-ok       'rs',   'rr', 'r'   ;
    op-ok       's2',   'rr', 'r'   ;
    op-ok       'rs',   'pp', 'p'   ;
    op-ok       's2r2', 'sr', 'sr'  ;
    op-ok       's3r3', 'sr', 's2r2'  ;
    op-ok       's4r3', 'sr', 's2r2'  ;
    op-ok       's3r4', 'sr', 's2r2'  ;
    op-ok       's4r4', 'sr', 's2r2'  ;
    op-ok       's5r5', 'sr', 's3r3'  ;
}


#
# XXX failing mixed cases 
#
{
    op-ok       'r2',   'sp', '∅'  ;
    op-ok       's2',   'rp', '∅'  ;
    op-ok       's2r',  'rp', 'r'  ;
    op-ok       's2r',  'rr', 'r'  ;
    op-ok       's2r3', 'ss', 's2' ;
    op-ok       's2r3', 'rp', 'r2' ;
    op-ok       's2r3', 'sp', 's'  ;
}

#
# mixed [f] and [w] cases 
#
{
    op-ok       'r',  'pw',  '∅'  ;
    op-ok       's',  'cf',  '∅'  ;
    op-ok       'r',  'rw',  'r'  ;
    op-ok       'r',  'rf',  'r'  ;
    op-ok       'sr', 'fs',  's'  ;
    op-ok       's2', 'fs',  's'  ;
    op-ok       's3', 'fs',  's2' ;
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
    op-dies-ok  'r',  'abc' ;
    op-dies-ok  'r',  '∅'   ; # XXX fails; see notes to breed-strict
}


=begin END

# deprecated Nil breeding case
multi sub op-ok (Str $xx, Str $yy, Nil $z)  {
    my $x  = posse($xx);
    my $y  = keybag(hashify($yy));
    my $s   = $x ⚤ $y;
    ok $s eqv Nil, "obj $x ⚤ $yy => Nil";
} 

    # my $ss  = $x ⚤ $yy;
    # ok $ss eqv Nil, "str $x ⚤ $yy => Nil";
    # say "z  = ", $z.WHICH, " = ", $z;
    # say "s  = ", $s.WHICH, " = ", $s;
    # say "ss = ", $ss.WHICH, " = ", $ss;

