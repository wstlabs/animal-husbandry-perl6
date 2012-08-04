use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Posse;
use Test;
plan *;

sub lets_spawn ($x,$y,$z)  {
    ok posse($x).spawn($y) eqv posse($z), "$x ⚤ $y => $z";
    say "spawn = ", posse($x).spawn($y), " => ", posse($z);
} 

{
    lets_spawn 'r', 'rs', 'r';
}


