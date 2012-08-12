use v6;
use Farm::Sim::Util::Search;

say table-counts;

my $x = equiv-to('h');
say "x = ", $x.WHICH;

my @piggy = equiv-to('h').grep({/p/});
say "piggy = ", @piggy.Int;


