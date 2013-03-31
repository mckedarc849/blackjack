require 'string'

# A collection of cards at the players hand. This class handles calculation on
# hand and some simple manipulation of the collection.
# It makes sense to let hand keep the bet attribute since a player might have
# different bet for his different hands when spliting
class Hand
  attr_accessor :index, :bet

  def initialize(index)
    @index = index
    @cards = Array.new()
    @bet = 0
  end

  def add(card)
    @cards << card
  end

  def pop
    @cards.pop()
  end

  def size
    @cards.size()
  end

  def clone
    @cards.clone()
  end

  def clear
    @cards.clear()
  end

  def [](i)
    @cards[i]
  end

  def <<(card)
    @cards << card
  end

  def to_s
    @cards.to_s
  end

  # Return an array of all possible values of the current hand
  def values
    values = Array.new()
    values << 0
    @cards.each do |card|
      if card.rank.is_i?()
        values = values.map {|v| v+card.rank.to_i()}
      elsif card.rank.eql?('A')
        values = values * 2
        original_size = values.size/2
        original_size.times do |i|
          values[i] += 1
          values[i+original_size] += 11
        end
      else
        values = values.map {|v| v+10}
      end
    end
    values
  end

  # check if the hand contains a blackjack
  def blackjack?
    values().include?(21)
  end

  # check if the hand is busted
  def bust?
    values().min() > 21
  end

  # Get the value that's closest to 21
  def final_value
    all_values = values()
    min_diff = 21
    value = all_values.first()
    all_values.each do |v|
      if v <= 21 && (21-v).abs() < min_diff
        min_diff = (21-v).abs()
        value = v
      end
    end
    value
  end

end
