use v6;
use Farm::Sim::Util;
use Farm::Sim::Posse;
use Farm::AI::Search;
use Farm::AI::Search::Data;
use KeyBag::Ops;

multi MAIN($posse, $animal) {
    die "<posse>  argument not a valid posse string"                unless is-domestic-posse-str($posse); 
    # die "<animal> argument not a valid (single-char) animal symbol" unless is-domestic-animal($animal);
    my $me  = posse($posse); 
    my $x  := $animal; # shorthand 
    say "$me seeks $x!";
    my @t = downward-equiv-to($x);
    say "found: ",@t.Int," = ", @t;
    say "found: ",@t.WHICH;
    say "found: ", @t;
    say "dogful   = ", grep {  m/<[dD]>/ }, @t; 
    say "dogless  = ", grep { !m/<[dD]>/ }, @t; 
    say "fly me = ", fly($posse);
    say "fly x  = ", fly($x);
    say "now...";
    my @nice = find-all-trades($me,$x);
    say "found: $me seeks $x => ", @nice;
    say fly-stats;
}

sub find-all-trades(Farm::Sim::Posse $p, Str $x)  {
    grep { $p ⊇ fly($_) }, downward-equiv-to($x)
}

sub find-equiv(Farm::Sim::Posse $p, Str $x)  {
    say "::find-equiv $p,[$x]";
    my $have = $p.worth;
    my $need = worth($x); 
    say "::find-equiv |$p| = $have -> |$x| = $need"; 
    return [] unless $have >= $need;
    downward-equiv-to($x)
}


=begin END

