use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::AI::Posse;
use Test;
plan *;

#
# currently rather broken.
#

{
    # 
    # basic inst 
    #
    my $y;
    lives_ok { $y = Farm::AI::Posse.new },            "new (empty)";
    say "y = ", $y.WHICH;
    is "$y", '∅',                                     "eq '∅'";
    is $y.worth(), 0,                                 "worthless";
    say "y = $y = ", $y.WHICH; 
    lives_ok { $y.sum-in-place({ r => 2, s => 1 }) }, "valid sum r2s";
    lives_ok { $y.sum-in-place({ p => 1 }) },         "valid sum p";
    say "y = $y => ", $y;
    is "$y", 'r2sp',                                  "stringy";
    is $y.worth(), 20,                                "worthy";
    lives_ok { $y.sum-in-place({}) },                 "empty sum (canon)"; 
    lives_ok { $y.sum-in-place({ p => 0 }) },         "empty sum (degenerate)";
    is "$y", 'r2sp',                                  "verify empty sums";
    dies_ok { $y.sum-in-place({ f => 1 }) },          "invalid sum => fail"
}


{

    # 
    # cloning & entanglement
    #
    my ($y, $z);
    lives_ok { 
        $y = Farm::AI::Posse.new({ r => 2, s => 1 })
    },      "new (hash)";
    is "$y", 'r2s', "stringy";
    lives_ok { $z = $y.copy() }, "copy (explicit)";
    say "y = $y = ", $y.WHICH; 
    ok { $z eqv $y },     "z eqv y";
    ok { $y eqv $z },     "y eqv z";
    ok { $z eq $y },      "z eq y";
    ok { $y eq $z },      "z eq y";
    # nok { $z == $y },     "z == y" 
    # say "y = ", $y;
    # say "z = ", $z;
    lives_ok { $z.sum-in-place({ c => 1 }) },   "sum z";
    # say "y = ", $y;
    # say "z = ", $z;
    # XXX eqv not inheriting from Set::Bag?
    nok { $z eqv $y },     "z !eqv y";
    nok { $z eq $y },      "z !eq y";

}

# my $z = $y;
# say "z = $z";

=begin END

