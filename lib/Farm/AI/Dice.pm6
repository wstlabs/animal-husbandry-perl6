use v6;
use KeyBag::Deco; 
use Farm::AI::Util;

class Farm::AI::Dice  {
    has $!f; 
    has $!w; 
    my $inst = Farm::AI::Dice.bless(*);
    method new  {!!!}
    method inst { $inst }
    submethod BUILD  {
        $!f = keybag({r => 6, s => 2, p => 2, h => 1, f => 1});
        $!w = keybag({r => 6, s => 3, p => 1, c => 1, w => 1});
    }
    # debug 
    method f() { $!f };
    method w() { $!w };
}

=begin END

        $!f = keybag(hashify("r6s2p2hf"));
        $!w = keybag(hashify("r6s3pcw"));

1;
