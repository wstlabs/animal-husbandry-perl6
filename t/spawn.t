use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Posse;
use KeyBag::Ops;
use Test;
plan *;

sub lets-spawn ($xx, $yy, $zz)  {
    my $x  = posse($xx);
    my $y  = posse($yy);
    my $z  = posse($zz);
    my $s  = $x.spawn($y);
    my $ss = $x.spawn($yy);
    ok $s eq  $z,  "$x ⚤  $y => $s eq  $z";
    ok $s eqv $z,  "$x ⚤  $y => $s eqv $z";
    say "s = ", $s.WHICH, " = ", $s;
    say "z = ", $z.WHICH, " = ", $z;
} 


{
    lets-spawn 'r', 'rr', 'r';
}


=begin END

breed('r', 'rr');
breed('r', 'rs');
breed('rr', 'rs');
breed('rr', 'rr');

