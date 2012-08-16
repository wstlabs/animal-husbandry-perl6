use Farm::Sim::Posse;

#
# allows for a somewhat more compact (positional) representation in
# our extension classes; e.g. they just need to say
#
#    my $pair = ( 'r6' => 's' ) ;
#    return ( stock => $pair );
#

sub expand-details(Pair $p) is export  {
    my ($with,$what) = $p.kv;
    my ($selling,$buying) = $what.kv;
    my %selling = posse($selling).longhash;
    my %buying  = posse($buying).longhash;
    { :$with, selling => %selling, buying => %buying }
}

sub expand-trade(Pair $p) is export {
    $p ?? { :type<trade>, expand-details($p) } !! Nil
}

sub inflate-posse-hash(%p) is export {
    hash map -> $k,$v { 
        $k => posse-from-long($v)
    }, %p.kv
} 

sub show-pair(Str $s, Pair $p) is export  {
    say "::$s $p = ", $p.WHICH;
    for $p.kv -> $k,$v {
        say "::: k = $k = ", $k.WHICH;
        say "::: v = $v = ", $v.WHICH;
    }
}

=begin END
sub expand-details(Pair $p) is export  {
    show-pair("expand-details, p = ", $p);
    my ($with,$what) = $p.kv;
    show-pair("expand-details, what = ", $what);
    my @t = map { posse($_).longhash }, $what.kv;
    say "::: t = ", @t.perl;
    for $what.kv -> $x {
        say "::: x = $x = ", $x.WHICH;
        say "::: x => ", posse($x).longhash.WHICH;
        say "::: x => ", posse($x).longhash.perl;
    }
    my ($selling,$buying) = $what.kv;
    say "::: selling = ", $selling.perl;
    say "::: buying = ", $buying.perl;
    my %selling = posse($selling).longhash;
    my %buying  = posse($buying).longhash;
    { :$with, selling => %selling, buying => %buying }
}
# my (%selling,%buying) = map -> $x { {posse($x).longhash} }, $what.kv;


