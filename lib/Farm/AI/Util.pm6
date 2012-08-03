use v6;

#
# some general-purpose utilities, with a  current focused on 
# string <=> hash conversion.
#

sub tupify (Str $s) is export { 
    $s ~~ m/(<alpha>\d*)+/ ?? 
        return map -> $t { $t.Str}, $0
    !! die "malformed string representation [$s]"
}

sub tup2pair(Str $s) {
    $s ~~ m/(<alpha>)(\d*)/ ?? ($0,$1)
    !! die "malformed tuple element [$s]"
}  

sub hashify(Str $s) is export { 
    return {} if $s eq '∅';
    my @t = tupify($s); 
    hash map -> $t {
        my ($x,$n) = tup2pair($t);
        $x => $n > 0 ?? $n.Int !! 1 
    }, @t 
}

=begin END

