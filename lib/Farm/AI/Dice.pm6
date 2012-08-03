use v6;
use KeyBag::Deco; 
use Farm::AI::Util;

constant %f = {r => 6, s => 2, p => 2, h => 1, f => 1};
constant %w = {r => 6, s => 3, p => 1, c => 1, w => 1};

class Farm::AI::Dice  {
    has $!f; 
    has $!w; 
    my $inst = Farm::AI::Dice.bless(*);
    method new  {!!!}
    method inst { $inst }
    submethod BUILD  { 
        $!f = keybag(%f); 
        $!w = keybag(%w);
    }

    # returns a two-character string, e.g. 'rs' representing an ordered pair of
    # (f,w) die rolls.
    multi method roll() { $!f.roll ~ $!w.roll }
    
    # (hackishly) derives the resultant probability distribution of (f,w) die rolls, 
    # using the 2-char representation provided by the roll() method above.  
    method dist()  {
        my $p = $!f × $!w;
        my $n = $p.elems;
        hash map -> $k,$v {
            $k => ($v / $n) 
        }, crunch-keys($p.hash).kv
    }

    # in which we "crunch" the comma-separated pairs in our fake 2-dimensional hash,
    # generated using the cheap hack described in KeyBag::Cross, e.g.:
    #
    #   "r,s" => "rs"
    #
    # Note that once the core KeyBag is fixed (and we can use some kind of bona fide 
    # pair- or tuple- like container for our 2-dimensional hash keys), we'll still have 
    # to map these down to the canonical 2-char representation that we like -- so really
    # this sub isn't that far off from what we'll be using later on.
    sub crunch-keys(%h)  {
        hash map -> $k,$v {
            $k.trans(',' => '') => $v 
        }, %h.kv
    }
    # exposed for debugging 
    method f() { $!f };
    method w() { $!w };
}

=begin END

