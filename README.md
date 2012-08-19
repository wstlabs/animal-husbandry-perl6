Simulation tools for the dice game  _Animal Husbandry_ (Polish: _Hodowla zwierzątek_) invented by the mathematician [Karol Borsuk](https://en.wikipedia.org/wiki/Karol_Borsuk) and published at his own expense during the Warsaw Uprising in 1943.  

For a description of the game (and the Perl 6 programming challenge), please see Carl's original writeup:

The game has a curious history; a brief synopsis is provided on the [Wikipedia entry](https://en.wikipedia.org/wiki/Animal_Husbandry_(game)).  For a description of the game (and the Perl 6 programming challenge), please see Carl's original writeup:
  
  https://github.com/masak/farm

What's provided in this repo are the following:
* A framework for simulation tools (under the namespace ```Farm::Sim```), including a front-end game harness script ```demos\play.pl``` that's largely compatible with Carl's original ```farm.pl``` script, except for slightly different command-line usage, and the option (actually enabled by default; but silencable via ```--loud=1```) to provide "ASCII-art" status tracing.
* A set of utility classes providing functionality for simple combinatorial searching of what we'll call "admissible" trades (described below).  Thes are under the namespaces ```Farm::AI::Search```, supported by additional helper modules under the namespace ```Farm::AI::Util```.
* Finally, under ```Farm::AI```, a couple of mock (test) strategies, as well as one primitive (but viable) strategy, ```Farm::AI::Naive```, which we'll describe below.

## The Naive Strategy ##

As the name implies, a simple naive hill climbing strategy.  It doesn't do anything that a human player wouldn't think of after playing the game a few times -- i.e. make incremental moves to improve its position, without making any obvious mistakes -- albeit aided by fast combinatorial searching. 

Basically what the strategy amounts to is:
* At the beginning of each trading round, if there's an admissible game-ending trade with the Stock, then (obviously) execute it.
* "Always buy insurance".  Given the high frequence of F and W rolls, it basically seems always advisable to buy whatever dogs are available for sale by the stock.  Not only do surplus dogs hedge against potential runs of bad die rolls, they also deprive other players or protection.
* Otherwise, attempt to incrementally improve the diversity of our position.  To do this, we enumerate a list of small animals we need to increase
 our diversity (provided by the ```.gimme()``` method on the ```Posse``` object), and simply search for trades which provide these animals (from the Stock) -- and, importantly, also don't sacrifice any "insurance" (i.e. big or small dogs).  The selection from here is far from ideal, but the point is that it's pretty much guaranteed to always bump us up towards the winning state eventually.
* Finally, oppose all incoming trades (and initiate no trades with outside players).  The cases where cross-player trades seem to make sense are comparatively few and rare -- for the simple reason that in a perfect information game, the other players aren't likely to grant any trades with us that will (drastically) improve our own position.  
The sole obvious exception to the general prohibition against cross-player trades would to be "mercy trades", whereby we sell small dogs to other players in order to purchase animals we need to increase our diversity, but which aren't available from the stock (assuming we have a large enough surplus of small dogs ourselves).  These might be worth exploring at some point; however for right now, I just wanted to come up with a strategy that seems generally stable, while being simple to understand, and to code concisely such that the main loop fits in 10 or 15 lines of code, at the most. 




