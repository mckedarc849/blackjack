require 'card'

# A Deck of cards holds 52 cards as in the standard deck. It can draw a random
# card 
class Deck
  @@SUITS = %w[Clubs Diamonds Hearts Spades]
  @@RANKS = %w[A 2 3 4 5 6 7 8 9 10 J Q K]

  def initialize
    @stack = Array.new()
    @@SUITS.each do |suit|
      @@RANKS.each do |rank|
        @stack << Card.new(suit, rank)
      end
    end
    @stack.shuffle!()
  end

  def draw
    @stack.pop()
  end

  def empty?
    @stack.empty?()
  end
end
