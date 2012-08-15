use v6;
use Farm::Sim::Util;
use Farm::Sim::Posse;
use Farm::AI::Util::Search;
use KeyBag::Ops;

multi MAIN($posse, $animal) {
    die "<posse>  argument not a valid posse string"                unless is-domestic-posse-str($posse); 
    die "<animal> argument not a valid (single-char) animal symbol" unless is-domestic-animal($animal);
    my $me  = posse($posse); 
    my $x  := $animal; # shorthand 
    say "$me seeks $x!";
    my @t = find-equiv($me,$x);
    say "found: ",@t.Int," = ", @t;
    say "found: ",@t.WHICH;
    say "dogful   = ", grep {  m/<[dD]>/ }, @t; 
    say "dogless  = ", grep { !m/<[dD]>/ }, @t; 
    say "fly me = ", fly($posse);
    say "fly x  = ", fly($x);
    say "now...";
    my @nice = find-all-trades($me,$x);
    say "found: $me => ", @nice;
    say fly-stats;
}

sub find-all-trades(Farm::Sim::Posse $p, Str $x)  {
    grep { $p ⊇ fly($_) }, equiv-to($x)
}

sub find-equiv(Farm::Sim::Posse $p, Str $x)  {
    say "::find-equiv $p,[$x]";
    my $have = $p.worth;
    my $need = worth($x); 
    say "::find-equiv |$p| = $have -> |$x| = $need"; 
    return [] unless $have >= $need;
    equiv-to($x)
}


=begin END

{
    say "dogful   = ", grep {  m/<[dD]>/ }, @t; 
    say "dogless  = ", grep { !m/<[dD]>/ }, @t; 
    my @s = map { $_.Str }, @t;
    say "dogful   = ", @s.grep(  m/<[dD]>/ );
    say "dogless  = ", @s.grep( !m/<[dD]>/ );
}

{
    look-at(@t);
    look-at(@t.list);
    look-at(<a b c>);
    look-at([<a b c>]);
    my $foo = [<a b c>];
    look-at($foo);
}

sub look-at(@x) {
    say "which = ", @x.WHICH;
    say "elems = ", @x.elems;
    say " perl = ", @x.perl;
    say " gist = ", @x.gist;
    say "  int = ", @x.Int; 
}





my $x = equiv-to('h');
say "x = ", $x.WHICH;

my @piggy = equiv-to('h').grep(/p/);
say "piggy = ", @piggy.Int;
say "doggy   = ", equiv-to('h').grep(/<[dD]>/).Int;

my @dogs = grep /<[d]>/, equiv-to('h');
say "dogs = ", @dogs.Int;

my %t = hash map -> $k { $k => equiv-to($k).Int }, domestic-animals;
say "t = ", %t;



=begin END
my @dogs = equiv-to('D').Int;
my @dogs = grep /[dD]/, equiv-to('h');
say "doggy   = ", equiv-to('h').grep( /[dD]/ ).Int;
say "dogless = ", equiv-to('h').grep( !/d/   ).Int;
# say "dogless = ", equiv-to('h').grep({ !/[dD]/ }).Int;


