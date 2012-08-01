use v6;
use KeyBag::Deco; 

class Farm::AI::Dice  {
    has $!f; 
    has $!w; 
    my $inst = Farm::AI::Dice.bless(*);
    method new  {!!!}
    method inst { $inst }
    submethod BUILD  {
        $!f = 'foo';
        $!w = 'bar';
    }
    # debug 
    method f() { $!f };
    method w() { $!w };
}

1;
