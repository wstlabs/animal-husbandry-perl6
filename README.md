Simulation tools for the dice game  _Animal Husbandry_ (Polish: _Hodowla zwierzątek_) invented by the mathematician [Karol Borsuk](https://en.wikipedia.org/wiki/Karol_Borsuk) and published at his own expense during the Warsaw Uprising in 1943.  

The game has a curious history; a brief synopsis is provided on the Wikipedia entry:

  https://en.wikipedia.org/wiki/Animal_Husbandry_(game)

For a technical description of the game, please see Carl's original announcement of the Perl 6 programming challenge: 
  
  https://github.com/masak/farm

## TL;DR / Conclusion ##

We can show that the game does have at least one reasonably optimal strategy -- which doesn't guarantee victory, but which performs much better than a "blind" greedy algorithm -- which we'll call the "Naive Strategy", as described below.  But not only does it take many rounds (100+) to get to a winning state on average, it seems (though has not been proven) that *any* strategy would probably take a similarly high number of rounds, simply to the probabilities and payout proportions in Borsuk's original game.  This may be why most commercially successful versions -- like *Superfarmer* -- have made key alterations to make the expected resolution happen much sooner (in 20-40 rounds); but at the cost of making the game rather more boring, unfortunately. 

## Contents ##
What's provided in this repo are the following:
* A framework for simulation tools (under the namespace ```Farm::Sim```), including a front-end game harness script ```demos\play.pl``` that's largely compatible with Carl's original ```farm.pl``` script, except for slightly different command-line usage, and the option (actually enabled by default; but silencable via ```--loud=1```) to provide fixed-width, "ASCII-art" status tracing (or perhaps not so fixed-width or artistic looking, depending on what terminal you're using -- but in mine it looks fine).
* A set of utility classes providing functionality for simple combinatorial searching of what we'll call "admissible" trades (described below).  Thes are under the namespaces ```Farm::AI::Search```, supported by additional helper modules under the namespace ```Farm::AI::Util```.
* Finally, under ```Farm::AI```, a couple of mock (test) strategies, as well as one primitive (but viable) strategy, ```Farm::AI::Naive```, which we'll describe below.

## The Naive Strategy ##
As a submission to the contest itself, this repro provides a class implementing what we'll call the Naive strategy: 
```
    lib/Farm/AI/Naive.pm6 
```
As the name implies, it's basically just a simple hill-climbing strategy, and pretty much emulates the common-sense intution of a human player after having been exposed to a few sets of the game, and having learned from a few mistakes.  It doesn't aim to do anything besides make incremental moves to improve its position at each step, while avoiding obvious missteps -- albeit aided by fast combinatorial searching. 

In that sense, it's really just a "minimum viable strategy" which is simple enough so that we can convince ourself that it works, and which we can use as a benchmark against more viable strategies in the future.

So here's how it works:
* At the beginning of each trading round, if there's an admissible game-ending trade with the Stock, then (obviously) execute it.
* "Always buy insurance".  Given the high frequency of fox and wolf die rolls, it basically always seems advisable to buy whatever dogs are available for sale by the Stock.  Not only do surplus dogs hedge against potential runs of bad die rolls, they also deprive other players of protection.  So in our next step, we try to "loot" the Stock of as many dogs (first big dogs, then small dogs) as possible. 
* Otherwise, we attempt to incrementally improve the diversity of our position.  To do this, we enumerate a list of remaining animals we need to increase our diversity (provided by the ```.gimme()``` method on the ```Posse``` object), and simply search for trades which provide these animals (from the Stock) -- and, importantly, without sacrificing any "insurance" (_i.e._ big or small dogs).  The selection from here is far from perfect -- there's a whole combinatorial class of trades (called "upward trades") which we haven't bothered to code up yet, and so aren't executing.  But the point is that it's pretty much guaranteed to (almost always) bump us up towards the winning state at each move, if at all possible.
* Finally, we oppose all incoming trades (and initiate no trades with outside players).  The cases where cross-player trades seem to make sense are comparatively few and rare -- for the simple reason that in a perfect information game, the other players aren't likely to grant us any trades with us that will noticeably improve our own position.

One exception to the general prohibition against cross-player trades would seem to be "mercy trades", whereby we sell small dogs to other players in order to purchase animals we need to increase our diversity, but which aren't available from the Stock (assuming we have a large enough surplus of small dogs ourselves).  These might be worth exploring at some point; however for right now, I just wanted to come up with a strategy that seems generally stable, while being simple to understand, and to code concisely such that the main loop fits in 10 or 15 lines of code, at the most. 
That's about it.  Again, there are still quite a few gaps in the strategy, and many optimizations are possible.  

### Performance ###
Not so hot!  In the 2-player case (playing against itself) it's rather poor in fact -- I don't know what the median termination time T is, but it seems to be perhaps above 150 rounds.  Things are a bit better in the 3-player case, with a median T around 70 rounds; I haven't yet done any metrics on contests with 4 or more players.

Oh, and the simulation is also quite slow, but mostly because Rakudo is still quite slow.  Even so, most of the latency apparently happens at startup.  And inasmuch as the search algorithms sometimes involve rather expensive operations (e.g. inflating lists of KeyBags from lists of strings), this doesn't seem to add much to the overall running time.  But expect something like 2-5 minutes for each contest, depending on the number of players, how hungry the wolves and foxes are, etc.

### Implementation ###
Most of how the working details of the strategy, and of the combinatorial search algorithms behind it should be straightforward enough from grepping for where subs are defined and rewinding the steps back through the framework.  But a few parts of the main block of the Naive strategy class are perhaps worth explaining up front. 

For example, in each of the three main branches of the ```find-stock-trades()``` method there are calls to this function, defined over in ```Farm::AI::Search```:

```
    sub find-admissible-trades(Farm::Sim::Posse $P, Str $x) is export {
        my $t = downward-equiv-to($x);
        grep { $P ⊇ $_ }, @$t
    }
```
The ```downward-equiv-to()``` sub, in term, is basically a primitive which says, "Given a canonical search term ```$x```, find me all tuples (_i.e._ potential trades) of equivalent or lower rank."  The function is memoized, so it returns a ```Capture``` rather than a freshly-generated ```Array``` instance, which is then passed throught the ```grep``` to restrict that list to trades which are in fact contained in the player's ```Posse``` (_i.e._ a KeyBag representing the set of its animals).

The next step after that involves the curious '⊲' operator:
```
    .grep { $_ ⊲ $P }
```
This is a boolean relation which basically translates to mean "fits diversely under" (from left to right), or more strictly speaking, "the animal set on the left (LHS) would subtract from the animal set on the right (RHS) in such away that the RHS maintains diversity."  This ends up being a crucial step that prevetns us from engaging in counterproductive trades -- e.g. where we would sacrifice pigs or cows to obtain a horse.

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
The strategy has some weird corner cases where it can behave sub-optimally if you aren't very careful about how you do your selections of equivalent trades.  One of these concerns the phenomenon of inadvertent cyclical trades:  e.g. ```{ s => r6 }``` on one round, and then ```{ r6 => s }``` on the very next round.  I first tried enabling the latter step an optimization, only to discover that it quite often would cycle between those two trades, and avoid lookng for higher-ranking animals for several rounds... sometimes until all of the player's animals get eaten.  So for the time being, the fix is simply to disable the latter half of the loop, and the performance seems to revert back to it's normal, barely-efficient state. 

Another odd thing that emerged from initial runs of the strategy was its poor performance in 2-player contest.  It's suspected that in this configuration, the strategy is actually too conservative, _i.e._ hoarding too many dogs and forgoing breeding, which (paradoxically) leads to a dearth in bidding resources once the dogs it has are inevitably eaten, so it can't resupply with new ones.

## Usage ##

The strategy is of course designed do be fully compatible with the original ```farm.pl``` script from the programming challenge, so it will run under that script in the usual way:
```
    perl6 farm.pl ai Naive Naive Naive 
```
As to running the native game harness:  Once you've cloned the dist, sample usage (from the top dir of the dist) goes like this -- in this example, for a 2-player game of the Naive strategy against itself:
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

### Bugs ###
This is my first attempt at coding in Perl 6, so it's more than likely that I'm doing things in ways that are un-idiomatic, if not plainly wrong.  So any and all feedback is welcomed.  In any case, it should be noted that this code has been run under the 2012.05 version of Rakudo only, and has not yet been run under any version of Niecza.  

## License ##

This code is distributed under the Artistic License, and may be used or modified under the same terms as the Perl language itself.

## Acknowledgements ##

Significant portions of the ```Game``` harness include refactored code from Carl's original script, ```farm.pl```.  The correspondences and modifications should be fairly obvious.




