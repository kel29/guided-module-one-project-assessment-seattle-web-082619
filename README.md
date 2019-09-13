Crazy Eights!
========================

Welcome to Crazy Eights, a simple command line application that let's you play this tried and true card game.

---

## Game Versions

Currently there are two game versions:

- A single player game which is housed in the master branch
- A two player game, where the second player is a computer. This is housed in the multiplayer branch

_I'm definitely going to merge these later and have both options on the master. Please bare with my disorganization for now._
---

## Running the game

To run the game, enter into your terminal `ruby bin/run.rb`

## Rules

Game rules can be viewed anytime within the game as well, so don't worry if you forget.

### Baseline

Each turn ends when you play a card, and the game ends when someone successfully plays all of the cards in their hand.
You can only play a card if **either** its suit or number matches the last played card.
There is one exception - **Eights are wild!**. An Eight can be played any time, and when you play it you will be able to change the suit in play.

### For single player
 
You're playing against the deck - **to win** you need to get rid of all the cards in you hand before you run out of cards to draw from the deck.

### For playing against the computer

After you complete each turn, the computer will play a card. **You win** if you play all of your cards before the computer plays all of its cards.
**You lose** if the computer plays all of its cards first, or if you run out of cards to draw from the deck.