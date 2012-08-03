use v6;

#
# some general-purpose utilities, with a current focused on 
# string <=> hash conversion.
#

constant @animals = <r s p c h d D f w>;
my %animalish is ro = 
     hash @animals Z=> ( True xx @animals.Int );    

sub tupify (Str $s) is export { 
    $s ~~ m/^ (<alpha>\d*)+ $/ ?? 
        return map -> $t { $t.Str}, $0
    !! die "malformed string representation [$s]"
}

sub tup2pair(Str $s) {
    $s ~~ m/(<alpha>)(\d*)/ ??  (
        $0.Str, $1.Str
    ) !! die "malformed tuple element [$s]"
}  


# straightfoward string-to-hash conversion, converting e.g. "rs" to 
# the hash { r => 1, s => 1 }, and handling corner cases such as the
# empty symbol, and accepting non-canonical strings such as "rr"
# as well as degenerate cases like "r0" and "r01".
#
# note that we'll throw at the tupify() step if we're given structurally 
# invalid input, i.e. not matching the regex up in that sub.  that leaves 
# structurally valid strings containing invalid (non-animal) chars, which
# we choose to catch in a separate step, down in the for loop below.
sub hashify(Str $s) is export { 
    return {} if $s eq '∅';
    my Int %h;
    my @t = tupify($s); 
    for @t -> $t {
        my ($x,$n) = tup2pair($t);
        my $k = 
            $n eq '' ?? 1  !! 
            $n > 0   ?? $n !! 
        0;
        die "malformed string representation:  invalid symbol '$x'" 
            unless %animalish{$x};
        %h{$x} += $k if $k > 0 
    };
    return %h
}

sub stringify(%h) is export  {
    my @t = map -> $x,$k {
        $k > 0 ??
            $k > 1 ?? "$x$k" !! $x
        !! ()
    }, %h.kv; 
    return @t ?? @t.join('') !! '∅'
}

=begin END

#
#    hash map @animals -> $a { $a => True }; 
#

#    say "tup2pair($t) => $x ^ $n <= $k"; 


