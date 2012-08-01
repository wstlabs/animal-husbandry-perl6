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
}

1;
