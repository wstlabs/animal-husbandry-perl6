use v6;
use Farm::Sim::Util;
use Farm::Sim::Posse; 
use Farm::AI::Util::Poly;
use KeyBag::Ops; 


sub count-hash-of-lists(%h)  {
    hash map -> $k { $k => %h{$k}.list.Int }, %h.keys 
}

# mercilessly spews a freeform list of tuple equivalence classes.  in general
# this is done only as a manual, "out-of-band" step to provide boilerplate to 
# populate the tables over in Farm::AI::Search::Data, which is where the 
# official reference data sets actually live.
#
# note that some of the generation steps can take several seconds, and
# the final step (for 'h' or 'D2' equivalences) can around 2-3 minutes, 
# depending perhaps on what compiler you're running.
sub kombify() is export  { 
    #
    # "first-order" searches on single-letter breeding animals
    #
    say "generating equivalence classes; may take a while (4-5 min)..";
    say "s = 6 ...";  my @s = (    <d s r6>    );   #   3 sheep-equivalent tuples 
    say "p = 12 ..."; my @p = (  <p>,   @s ∘∘ 2);   #   7   pig-equivalent tuples 
    say "c = 36 ..."; my @c = ( <D c>,  @p ∘∘ 3);   #  52   cow-equivalent tuples; takes 10s to gen
    say "h = 72 ..."; my @h = (         @c ∘∘ 2);   # 355 horse-equivalent tuples; takes 157s! 

    #
    # "second-order" searches on small dog tuples (d3,d4) that don't happen to be 
    # equivalent to single-animal trades, but which are sometimes desirable for purchase
    # if the stock happens to have them available.
    # 

    # say "d3 = 18 ..."; my @d3 = @p ∘ @s;       # 13  d3-equivalent tuples
    # say "d4 = 24 ..."; my @d4 = @p ∘ @p;       # 22  d4-equivalent tuples

    say "d3 = 18 ..."; my @d3 = grep { !m/<[d]>/ }, @p ∘ @s; # 13 dogful, 6 dogless
    say "d4 = 24 ..."; my @d4 = grep { !m/<[d]>/ }, @p ∘ @p; # 22 dogful, 9 dogless      

    say "let's see, now:";
    say '  ', +@s,  ' s- or d-  equivalent trades';
    say '  ', +@p,  ' p- or d2-     "        "   ';
    say '  ', +@d3, ' d3-           "        "   ';
    say '  ', +@d4, ' d4-           "        "   ';
    say ' ',  +@c,  ' c- or D-      "        "   ';
    say       +@h,  ' h- or D2-     "        "   ';
    # XXX sorry, gave up trying to figure out what's up with heredocs and formatting 
    # in rakudo.  easier just to format that table by hand.

    my @k = < s p c h d3 d4 >;
    my %T = hash map -> $k { $k => eval '@'~$k     }, @k;
    say "|T| = ", count-hash-of-lists(%T);


    my $stock = posse( stock-hash() );
    say "restricting for stock-admissibility (S = $stock) ..";
    my %A = map -> $k {
        my @inflated =  map {  posse($_)  }, %T{$k}.list; 
        $k =>          grep { $_ ⊆ $stock }, @inflated
    }, @k;
    say "|A| = ", count-hash-of-lists(%A);

    # finally, let's do some kind of sorting on the way out; while there 
    # are ways we can sort these tuples so that they (sort of) come out in 
    # a sensible order, with higher-ranking animals generally closer to the 
    # front of the line, the default alpha sort will be fine for now.
    my %S = hash map { 
        my @s = %A{$_}.list.Str.sort({ $^a leg $^b });
        $_ => @s 
    }, @k;
    say "|S| = ", count-hash-of-lists(%S);
    
    return %S;
}


=begin END

        # my @s = %A{$_}.list.sort;
        # $_ => @s; 

Hmm.  This works:

    my %S = hash map { 
        my @s = %A{$_}.list.sort;
        $_ => @s; 
    }, @k;

But this doesn't:

    my %S = hash map { 
        $_ => %A{$_}.list.sort
    }, @k;





    {
        my %N = map -> $k { $k => %T{$k}.list.Int }, @k; 
        say "|T| = ", %N;
    }
    {
        my %N = map -> $k { $k => %T{$k}.list.Int }, @k; 
        say "|S| = ", %S;
    }

    return Nil;


    my @P = sort map { posse($_) }, @p;
    my @C = sort map { posse($_) }, @c;

    say "S = ", @S;
    say "P = ", @P;
    say "C = ", @C;

    say "grep against stock:";

    say "cows..";
    my @X = grep { $_ ⊆ $stock }, @C;
    say "C => ", @X.Int; # 47
    say "C = ", @X;

    # say "horses.."; 
    # my @H = sort map { posse($_) }, @h;
    # my @Y = grep { $_ ⊆ $stock }, @H;
    # say "H => ", @Y.Int; # 276
    # say "H = ", @Y;

}

sub kombify-slow() is export  { 
    my @s = [<r>]           ∘∘ 6; say @s;  #   1 sheep-equivalent tuple  -> r6
    my @p = ( <d s>, @s)    ∘∘ 2; say @p;  #   5   pig-equivalent tuples -> <d s r6>
    my @c = ('p', @p)       ∘∘ 3; say @c;  #  50   cow-equivalent tuples; takes 10s to gen
    my @h = ('D', 'c', @c)  ∘∘ 2; say @h;  # 355 horse-equivalent tuples; takes 157s! 
}



