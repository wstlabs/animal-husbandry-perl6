Simulation tools for the dice game  _Animal Husbandry_ (Polish: _Hodowla zwierzątek_) invented by the mathematician [Karol Borsuk](https://en.wikipedia.org/wiki/Karol_Borsuk) and published at his own expense during the Warsaw Uprising in 1943.  

The game has a curious history; a brief synopsis is provided on the [Wikipedia entry](https://en.wikipedia.org/wiki/Animal_Husbandry_(game).  For a technical description of the game, please see Carl's original announcement of the Perl 6 programming challenge: 
  
https://github.com/masak/farm

What's provided in this repo are the following:
* A framework for simulation tools (under the namespace ```Farm::Sim```), including a front-end game harness script ```demos\play.pl``` that's largely compatible with Carl's original ```farm.pl``` script, except for slightly different command-line usage, and the option (actually enabled by default; but silencable via ```--loud=1```) to provide "ASCII-art" status tracing.
* A set of utility classes providing functionality for simple combinatorial searching of what we'll call "admissible" trades (described below).  Thes are under the namespaces ```Farm::AI::Search```, supported by additional helper modules under the namespace ```Farm::AI::Util```.
* Finally, under ```Farm::AI```, a couple of mock (test) strategies, as well as one primitive (but viable) strategy, ```Farm::AI::Naive```, which we'll describe below.

## The Naive Strategy ##

As the name implies, a simple naive hill climbing strategy.  It doesn't do anything that a human player wouldn't think of after playing the game a few times -- i.e. make incremental moves to improve its position, without making any obvious mistakes -- albeit aided by fast combinatorial searching. 

In that sense, it's really just a "minimum viable strategy" which is simple enough so that we can convince ourself that it works, and which we can use as a benchmark against more viable strategies in the future.

So here's how it works:
* At the beginning of each trading round, if there's an admissible game-ending trade with the Stock, then (obviously) execute it.
* "Always buy insurance".  Given the high frequency of fox and wolf die rolls, it basically seems always advisable to buy whatever dogs are available for sale by the stock.  Not only do surplus dogs hedge against potential runs of bad die rolls, they also deprive other players or protection.  So in our next step, we try to "loot" the Stock of as many dogs (first big dogs, then small dogs) as possible. 
* Otherwise, we attempt to incrementally improve the diversity of our position.  To do this, we enumerate a list of small animals we need to increase
 our diversity (provided by the ```.gimme()``` method on the ```Posse``` object), and simply search for trades which provide these animals (from the Stock) -- and, importantly, also don't sacrifice any "insurance" (i.e. big or small dogs).  The selection from here is far from perfect -- there's a whole combinatorial class of trades (called "upward trades") which we haven't bothered to code up yet, and so aren't executing.  But the point is that it's pretty much guaranteed to (almost always) bump us up towards the winning state at each move, if at all possible.
* Finally, we oppose all incoming trades (and initiate no trades with outside players).  The cases where cross-player trades seem to make sense are comparatively few and rare -- for the simple reason that in a perfect information game, the other players aren't likely to grant any trades with us that will (drastically) improve our own position.  

The sole obvious exception to the general prohibition against cross-player trades would seem to be "mercy trades", whereby we sell small dogs to other players in order to purchase animals we need to increase our diversity, but which aren't available from the stock (assuming we have a large enough surplus of small dogs ourselves).  These might be worth exploring at some point; however for right now, I just wanted to come up with a strategy that seems generally stable, while being simple to understand, and to code concisely such that the main loop fits in 10 or 15 lines of code, at the most. 
That's about it.  Again, there are still quite a few gaps in the strategy, and many optimizations are possible.  

### Performance ###

Not so hot!  In the 2-player case (playing against itself) it's rather poor in fact -- I don't know what the median termination time T is, but it seems to be perhaps above 150 rounds.  Things are a bit better in the 3-player case, with a median T around 90 rounds; I haven't yet done any metrics on contests with 4 or more players.

Oh, and the simulation is also quite slow, but mostly because Rakudo is still quite slow.  Even so, most of the latency apparently happens at startup.  And inasmuch as the search algorithms sometimes involve rather expensive operations (e.g. inflating lists of KeyBags from lists of strings), this doesn't seem to add much to the overall running time. 

### Details ###

Most of how the algorithm work should be straightforward enough from grepping for where subs are definied and rewinding the steps back through the framework, but a few parts of the main block of the Naive strategy class are perhaps worth explaining up front. 

For example, in each of the three main branches of the ```find-stock-trades()``` method there are calls to this function, defined over in ```Farm::AI::Search```:

```
    sub find-admissible-trades(Farm::Sim::Posse $P, Str $x) is export {
        my $t = downward-equiv-to($x);
        grep { $P ⊇ $_ }, @$t
    }
```
The ```downward-equiv-to()``` sub, in term, is basically a primitive which says, "Given a canonical search term ```$x```, find me all tuples (i.e. potential trades) of equivalent or lower rank.  The function is memoized, so it returns a ```Capture``` rather than a freshly-generated ```List``` instance, which is then passed throught the ```grep``` to restrict that list to trades which are in fact contained in the player's ```Posse``` (i.e. a KeyBag representing the set of its animals).

The next step after that involves the curious '⊲' operator:
```
        .grep { $_ ⊲ $P }
```
This is a boolean relation which basically translates to mean "fits diversely under" (from left to right), or more strictly speaking, "the animal set on the left (LHS) would subtract from the animal set on the right (RHS) in such away that the RHS maintains diveristy."  This ends up being a crucial step that prevetns us from engaging in counterproductive trades -- e.g. where we would sacrifice pigs or cows to obtain a horse.

The second main branch in the loop is the "looting" step, where we basically attempt to grab as many dogs from the Stock that it has available.  There's just one caveat -- while we'd gladly trade small dogs for larger ones (if strictly necessary), we'd prefer to sacrifice as few as possible.  So we need to sort the set of admissible trades for "dogfulness", via the magical '‹d›' operator:
```
        .sort: { $^a ‹d› $^b };
```
As with the '⊲' operator, filtering with this criterion ends up (in some cases) de-prioritizing many trades where we'd be throwing out two or three small dogs to get a larger one, when we really should be throwing out rabbits and sheep. 

Finally, in our generic "hill-climbing step", in which we ask our Posse (via the ```.gimme()``` method) what animals it needs to increase diversity (that we haven't yet queried for via the "wish" step up at the top), we also need to make sure we aren't releasing any dogs at all back to the Stock (big or small).  This is accomplished by a straightforward, string-based grep on the returned list.
```
        .grep: { !m/<[dD]>/ };
```

### Anomolies ###

The strategy has some weird corner cases where it can behave sub-optimally if you aren't very careful about how you do your selections of equivalent trades.  One of these concerns the phenomenon of inadvertent cyclical trades:  e.g. ```{ s => r6 }``` on one round, and then ```{ r6 => s }``` on the very next round.  I first tried enabling the latter step an optimization, only to discover that it quite often would cycle between those two trades, and never look for higher-ranking animals.  So for the time being, the fix is simply to disable the latter half of the loop, and the performance seems to revert back to it's normal, lackadaisical / barely-efficient state. 

## Usage ##

Once you've cloned the dist, sample usage (from the top dir of the dist) goes like this -- in this example, for a 2-player game of the Naive strategy against itself:

```
    perl6 -Ilib demos/play.pl ai 1 Naive Naive 
```

The ```1``` is simply to specify that you want one and only one contest to be run.  It's also possible to specify an upper limit on the number of rounds to be played, via the ```--n``` flag; and to suppress output, you can set loudness to zero:

```
    perl6 -Ilib demos/play.pl --loud=0 --n=100 ai 1 Naive Naive Naive 
```

There are also some unit tests under the ```t/``` dir which are fairly well maintained.

### Prerequisites ###

This distribution has one external dependency; the class ```KeyBag::Deco```, which is a patched, or "decorated" extension of the core ```KeyBag``` class providing certain functionality which seems not quite finished in both Rakudo and Niecza at the moment -- including, most importantly, working Unicode operators.  ```KeyBag::Deco``` can be found over here: 

https://github.com/wstlabs/keybag-extras-p6




