require 'participant'

# An extension to the Participant. In particular, a player should have money
# and be able to add to and reduce from that money
class Player < Participant
  attr_accessor :money

  def initialize(name, money)
    @money, @bet = money, 0
    super(name)
  end

  def lose(amount)
    @money -= amount
  end

  def win(amount)
    @money += amount
  end

  def to_s
    "#@name, $#@money"
  end
end
