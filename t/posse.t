use v6;
BEGIN { @*INC.unshift: './lib'; }
use Farm::Sim::Posse;
use KeyBag::Ops;
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
    lives_ok { $y = Farm::Sim::Posse.new },            "new (empty)";
    is "$y", '∅',                                     "eq '∅'";
    is $y.worth(), 0,                                 "worthless";
    lives_ok { $y.sum-in-place({ r => 2, s => 1 }) }, "valid sum r2s";
    lives_ok { $y.sum-in-place({ p => 1 }) },         "valid sum p";
    is "$y", 'psr2',                                  "stringy";
    is $y.worth(), 20,                                "worthy";
    lives_ok { $y.sum-in-place({}) },                 "empty sum (canon)"; 
    lives_ok { $y.sum-in-place({ p => 0 }) },         "empty sum (degenerate)";
    is "$y", 'psr2',                                  "verify empty sums";
}


# 
# cloning & (dis)entanglement
#
{

    my ($x, $y);
    lives_ok { $x = posse({ r => 2, s => 1 }) },   "new (non-empty)";
    is "$x", 'sr2', "stringy";
    lives_ok { $y = $x.clone() }, "clone (deep)";
    isnt $x.WHICH, $y.WHICH,      "distinct";
    ok { $y eqv $x },             "y eqv x";
    ok { $x eqv $y },             "x eqv y";
    ok { $y eq $x },              "y eq x";
    ok { $x eq $y },              "x eq y";
    lives_ok { $y{'p'} = 3 },     "munge y";
    is "$y", 'p3sr2',             "stringy";
    nok $y eqv $x,                "y !eqv x";
    nok $x eqv $y,                "y !eqv x";
}

#
# failing (NYI) cases
#
# as in, we note these as fails because they represent bugs to fix.   which is difficult
# in the moment because it involves fixing the underlying KeyBag class. 
#
{  my $y = posse({});          dies_ok { $y.sum-in-place({ f => 1 }) },  "invalid sum-in-place"  }
{  my $y = posse({});          dies_ok { $y{'f'} = 1 },                  "invalid assignment"    }
{  my $y = posse({});          dies_ok { $y{'f'}++   },                  "invalid increment"     }
{  my $y = posse({ r => 1 });  dies_ok { $y{'r'} -= 2  },                "underflow"             }
{  my $y = posse({ r => 1 });  dies_ok { $y{'r'} /= 0  },                "divide-by-zero"        }

=begin END

