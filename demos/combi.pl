use v6;
use Farm::Sim::Util;

constant @tiere = <r s p c h>;

show-secret-structs();

# a little loop to test autopopultion of the combi table,
# but only when called on a list of animals in ascending rank -
# so it won't work with random access.
for @tiere -> $x {
    say "$x => [", combify($x), "]";
}


