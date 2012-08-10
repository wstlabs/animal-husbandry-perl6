use v6;
use Farm::Sim::Game;
use Farm::Sim::Posse;

sub look_at(Farm::Sim::Game $g)  {
    say "game    = ",  $g;
    say "stock   = ",  $g.posse('stock');
    say "players = ",  $g.players;
    say "table   = ",  $g.table;
}

{
    my $game = Farm::Sim::Game.new(
        p => {
            'mary' => posse({}),
            'jake' => posse({})
        }
    );
    look_at $game;
}

{
    my $game = Farm::Sim::Game.simple(3);
    look_at $game;
}



    

=begin END

