blackjack
=========

A text based blackjack game in ruby.
Learned ruby oop doing this project.

run
---

To run blackjack, run:

    $ ruby driver.rb
        
Game rules
----------

All Game rules are based on wikipedia blackjack page. Some choices of variant:

- dealer stays on soft 17
- player can use double down and split at the same time
- only allow split when the rank are exactly the same, some game allow 
  spliting when the rank value is the same

Design
------

-   **blackjack.rb**:
    allow users to play game multiple times and keep track of a list of users

-   **game.rb**:
    the bulk of the logic for the game, a game is defined as from the bet
    to the time where all the players has won or lost

-   **deck.rb**:
    deck of cards, players and dealer draw cards from this object

-   **card.rb**:
    simple representation of cards

-   **participant.rb**:
    superclass or all participants, dealer is a participant, player is a
    subtype of participant

-   **player.rb**:
    extends participant and add money operations

-   **hand.rb**:
    collection of cards at players hand
    each player can have 2 hand because of splitting
    this object handles calculation on the cards
 
-   **string.rb**:
    add a missing function in String object

-   **util.rb**:
    provides some io helper methods

-   **driver.rb**:
    to run the game
