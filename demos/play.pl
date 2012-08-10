use v6;
use Farm::Sim::Game;
use Farm::Sim::Posse;

my $game = Farm::Sim::Game.new(
    p => {
        'mary' => posse({}),
        'jake' => posse({})
    }
)
;
say "game    = ",  $game;
say "stock   = ",  $game.posse('stock');
say "players = ",  $game.players;
say "table   = ",  $game.table;

=begin END

