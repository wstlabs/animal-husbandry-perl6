use v6;
use KeyBag::Deco; 

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



For clarification, the hash eventually returned from the dist() method above ends up
looking like this:

    { 
        rr => 1/4,  rs => 1/8,  rp => 1/24,  rc => 1/24,  rw => 1/24, 
        sr => 1/12, ss => 1/24, sp => 1/72,  sc => 1/72,  sw => 1/72, 
        pr => 1/12, ps => 1/24, pp => 1/72,  pc => 1/72,  pw => 1/72, 
        hr => 1/24, hs => 1/48, hp => 1/144, hc => 1/144, hw => 1/144, 
        fr => 1/24, fs => 1/48, fp => 1/144, fc => 1/144, fw => 1/144
    } 

Which we could have cranked out and typed in by hand, but given the likeliehood
of making some kind of a mistake, it seems prudent to generate this dist explicitly.

Note that there are some (functional) redundancies in the above table;
e.g. the pairs 'rs' and 'sr' have the same effect on the player rolling them, 
but for the sake of simplicity we make no attempt (at this step) to merge 
them into canonical entries. 



