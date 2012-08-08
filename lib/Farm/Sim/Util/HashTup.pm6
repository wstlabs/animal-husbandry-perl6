use v6;

#
# hash <=> tuple <=> string conversion.
#  
# it's mostly to avoid circular dependencies that we keep
# these subs in a separate module.
#

#
# simply splits a string into a list of tuple terms, e.g.:
#
#  "a2b3c" -> ( "a2", "b3", "c" ) 
#  
sub tupify (Str $s) is export { 
    $s ~~ m/^ (<alpha>\d*)+ $/ ?? 
        return map -> $t { $t.Str}, $0
    !! die "malformed string representation [$s]"
}

#
# returns a "raw" pair of split tuple components, e.g.:
#
#   x2 => ("x","2")
#   x1 => ("x","")
#
sub tup2raw(Str $s) {
    $s ~~ m/(<alpha>)(\d*)/ ??  (
        $0.Str, $1.Str
    ) !! die "malformed tuple element [$s]"
}  

#
# converts a string reprsentation of a tuple to a properly 
# normalized and typed (Str,Int) pair, e.g. 
#
#  "x2" -> ("x",2)
#  "x"  -> ("x",1)
#
# note that the fail case should theoreticalliy never happen, 
# but we have to put something in the switch, in case it does.
sub tup2pair(Str $s) {
    my ($x,$n) = tup2raw($s);
    my Int $k = 
        $n eq '' ?? 1      !! 
        $n >= 0  ?? $n.Int !! 
        die "invalid tuple exponent '$n'"
    ;
    ($x,$k)
}  

#
# straightfoward string-to-hash conversion, converting e.g. 
#
#  "ab"    -> { a => 1, b => 1 }
#  "a2b3c" -> { a => 2, b => 3, c -> 2 }
#  "∅"     -> {}
#
# note that in addition to handling the empty symbol ("∅") we
# also accept non-canonical string such as "aa", "a0" and "a01".
#
multi sub hashify(Str $s) is export { 
    return {} if $s eq '∅';
    my Int %h;
    my @t = tupify($s); 
    for @t -> $t {
        my ($x,$k) = tup2pair($t);
        %h{$x} += $k if $k > 0 
    };
    return %h
}

multi sub hashify(Str $s, %v) is export { 
    my %h = hashify($s);
    for %h.keys -> $k {
        die "invalid symbol '$k'" unless %v{$k} 
    }
    return %h
}

multi sub stringify(%h) is export  {
    my @t = map -> $x, Int $k {
        $k > 0 ??
            $k > 1 ?? "$x$k" !! $x
        !! ()
    }, %h.kv.sort;
    return @t ?? @t.join('') !! '∅'
}

multi sub stringify(%h, @s) is export  {
    my @t = map -> $x {
        my $k = %h{$x};
        next unless %h.exists($x);
        $k > 0 ??
            $k > 1 ?? "$x$k" !! $x
        !! ()
    }, @s;
    return @t ?? @t.join('') !! '∅'
}



sub compare-weighted-tuples( %x, %y, @t is copy ) is export  {
    if (@t)  {
        my $t = shift @t;
        my $j = %x{$t}; 
        my $k = %y{$t};
        return
            ( defined $j) && ( defined $k ) ?? 
                $j <=> $k ||
                compare-weighted-tuples(%x,%y,@t)
            !!
            ( defined $j ) ?? Order::Increase !!
            ( defined $k ) ?? Order::Decrease !!
                compare-weighted-tuples(%x,%y,@t)
    }
    else  {
        return Order::Same 
    }
}


=begin END

                # my $stat = $j <=> $k;
                # $stat eqv Order::Same ?? 
                #    compare-weighted-tuples(%x,%y,@t)
                # !! 
                #     $stat

multi sub stringify(%h, @s) is export  {
    # say "::stringify(2): h = ", %h;
    # say "::stringify(2): s = ", @s; 
    my @t = map -> $x {
        my $k = %h{$x};
        next unless %h.exists($x);
        # say "x = [$x] =>  k = ", $k;
        # say "x = [$x] => xk = ", "$x$k"; 
        #  say "x = [$x] =>  x = ", $x; 
        # say "x = [$x] => 'x = ", "$x";
        $k > 0 ??
            $k > 1 ?? "$x$k" !! $x
        !! ()
    }, @s;
    # say "::stringify(2): t = {@t.perl}";
    # say "::stringify(2): t = ", @t; 
    return @t ?? @t.join('') !! '∅'
}
