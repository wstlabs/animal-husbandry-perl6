use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::AI::Posse;
use Test;
plan *;

#
# still a few broken cases, here and there. 
#

# 
# basics
#
{
    my $y;
    lives_ok { $y = Farm::AI::Posse.new },            "new (empty)";
    # say "y = ", $y.WHICH;
    is "$y", '∅',                                     "eq '∅'";
    is $y.worth(), 0,                                 "worthless";
    # say "y = $y = ", $y.WHICH; 
    lives_ok { $y.sum-in-place({ r => 2, s => 1 }) }, "valid sum r2s";
    lives_ok { $y.sum-in-place({ p => 1 }) },         "valid sum p";
    # say "y = $y => ", $y;
    is "$y", 'r2sp',                                  "stringy";
    is $y.worth(), 20,                                "worthy";
    lives_ok { $y.sum-in-place({}) },                 "empty sum (canon)"; 
    lives_ok { $y.sum-in-place({ p => 0 }) },         "empty sum (degenerate)";
    is "$y", 'r2sp',                                  "verify empty sums";
}


# 
# cloning & (dis)entanglement
#
{

    my ($x, $y);
    lives_ok { 
        $x = Farm::AI::Posse.new({ r => 2, s => 1 })
    },                            "new (non-empty)";
    is "$x", 'r2s', "stringy";
    lives_ok { $y = $x.clone() }, "clone (deep)";
    # say "x = $x = ", $x.WHICH; 
    # say "y = $y = ", $y.WHICH; 
    isnt $x.WHICH, $y.WHICH,      "distinct";
    ok { $y eqv $x },             "y eqv x";
    ok { $x eqv $y },             "x eqv y";
    ok { $y eq $x },              "y eq x";
    ok { $x eq $y },              "x eq y";
    lives_ok { $y{'p'} = 3 },     "munge y";
    is "$y", 'r2sp3',             "stringy";
    nok $y eqv $x,                "y !eqv x";
    nok $x eqv $y,                "y !eqv x";
}

#
# failing (NYI) cases
# as in, we note these as fails because they represent bugs to fix.
#
{
    my $y = Farm::AI::Posse.new({});
    dies_ok { $y.sum-in-place({ f => 1 }) },       "X sum-in-place";
}

{
    my $y = Farm::AI::Posse.new({});  
    dies_ok { $y{'f'} = 1 },                       "X assignment";
    # dies_ok { $y{'f'}++ },                       "X incr";
}

=begin END

