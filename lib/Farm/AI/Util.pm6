use v6;

sub tupify (Str $s) is export { 
    $s ~~ m/(<alpha>\d*)+/ ?? 
        return map -> $t { $t.Str}, $0
    !! die "malformed expression [$s]"
}

sub tup2pair(Str $s) {
    $s ~~ m/(<alpha>)(\d*)/ ?? ($0,$1)
    !! die "malformed tuple elt [$s]"
}  

sub hashify(Str $s) is export { 
    hash map -> $t {
        my ($x,$n) = tup2pair($t);
        $x => $n > 0 ?? $n.Int !! 1 
    }, tupify($s)
}


=begin END

sub hashify(Str $s) is export { 
    my @t = tupify($s);
    # say "hashify [$s] => {@t}";
    hash map -> $t {
        # say "t = [$t]";
        my ($x,$n) = tup2pair($t);
        # say "t = [$t] => $x, $n"; 
        $x => $n > 0 ?? $n.Int !! 1 
    }, tupify($s)
    # }, @t 
}





    # if ( $s ~~ /([a..z])+/ )  {
    # if ( $s ~~ m/ @tups=([a..z]\d)+ / )  {

    say "s = [$s]";
    if ($s ~~ m/(<alpha>\d*)+/ )  {
        say "yes:  ", $0.join(", ");
    }
    else  {
        say "no!";
    }
    return ()

