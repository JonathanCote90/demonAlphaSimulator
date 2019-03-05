# demonAlphaSimulator
Custom 5e rules simulator to measure balance

A friend of mine wanted to add the Dark Souls tabletop game mechanics of blocking and dodging in Dungeon and Dragon 5th edition.
In the board game, the block dice have 6 faces. There are three "grades" of dice: black, blue and orange, from worse to best. The black goes from 0 to 2 (With repeats, of course), blue from 1 to 3 and orange from 1 to 4. When receiving an attack, a character gets to choose whether they want to attempt a dodge (And avoid all damage on a success) or attempt a block, reducing the damage taken by the value rolled on the dice.
Another thing he wanted to replace, is that instead of a d20, players roll 3d6 for a normal-er distrubution.
Lastly, the dodge mechanic. Instead of having the static D&D Armor Class, a character attempting to dodge had to roll a d20 (replacing the static +10).

All theses elements being very difficult to balance, I decided to help him by creating a simulator that would take two melee fighter that would engage in iterative combat to remove luck from the results.
