use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Posse;
use Test;
plan *;

sub lets_spawn ($x,$y,$z)  {
    # ok posse($x).spawn($y) eqv posse($z), "$x ⚤ $y => $z";
    my $px = posse($x);
    my $py = posse($y);
    my $pz = posse($z);
    my $r = $px.spawn($py);
    ok $px.spawn($py) eqv $pz, "$x ⚤ $y => $z";
    ok $r eqv $pz, "$r eqv $pz"; 
    say "spawn: = $px ++ $py ==> $pz";  
    say "r  = ", $r.WHICH,  " = ", $r;
    say "pz = ", $pz.WHICH, " = ", $pz;
} 

{
    lets_spawn 'r', 'rs', 'r';
}

=begin END

    # ok posse($x).spawn(posse($y)) eqv posse($z), "$x ⚤ $y => $z";
    say "spawn = ", posse($x).spawn($y), " => ", posse($z);

