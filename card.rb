# representation of a card with suit and rank
class Card
  attr_accessor :suit, :rank

  def initialize(suit, rank)
    @suit, @rank = suit, rank
  end

  def to_s
    "#@suit-#@rank"
  end
end
