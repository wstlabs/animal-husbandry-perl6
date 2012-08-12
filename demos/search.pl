use v6;
use Farm::Sim::Util::Search;

say table-counts;

my $x = equiv-to('h');
say "x = ", $x.WHICH;

my @piggy = equiv-to('h').grep(/p/);
say "piggy = ", @piggy.Int;
say "doggy   = ", equiv-to('h').grep(  /d/   ).Int;

my @dogs = grep /<[d]>/, equiv-to('h');
say "dogs = ", @dogs.Int;

=begin END
my @dogs = grep /[dD]/, equiv-to('h');
say "doggy   = ", equiv-to('h').grep( /[dD]/ ).Int;
say "dogless = ", equiv-to('h').grep( !/d/   ).Int;
# say "dogless = ", equiv-to('h').grep({ !/[dD]/ }).Int;


