use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::AI::Util;

sub test_it(Str $s)  {
    my %h = hashify($s);
    say "ok: $s => ", %h;
}

test_it("abc");
test_it("r2p3ch");

=begin END

my @t = tupify("r2p3ch");
say "t = ", @t;


