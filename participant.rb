require 'hand'

# A representation of any Participant in the game. A dealer is a Participant,
# and players are subclasses of Participant. All Participant has a name and a
# hand of cards
class Participant
  attr_accessor :name, :hands

  def initialize(name)
    @name = name
    @hands = Array.new()
    @hands << Hand.new(0)
  end

  def hand0
    @hands[0]
  end

  def split
    @hands << Hand.new(1)
    @hands[1] << @hands[0].pop()
    @hands[1].bet = @hands[0].bet
  end

end
