require 'util'
require 'game'
require 'deck'
require 'player'

# A blackjack object allows players to play multiple games continuesly
class Blackjack

  @@INIT_DOLLAR = 1000

  def initialize
    @deck = Deck.new()
    @players = Array.new()
    @dealer = Participant.new('dealer')
  end

  # We limit the number of possible players here because we only have 1 deck.
  # It does not make sense to allow infinite number of players
  def setup
    print 'Enter the number of players for this game -> '
    t = Util.get_i()
    if t >= 6
      abort('can only have less than 6 players, program aborting')
    end
    t.times do |index|
      @players << Player.new(index, @@INIT_DOLLAR)
    end
  end

  def start
    setup()
    while (true)
      puts '####################### Playing a new game #######################'
      Game.new(@dealer, @deck, @players).play()

      # after each game remove players that have used up all their money
      @players.each do |player|
        if player.money == 0
          @players.delete(player)
        end
      end
      if @players.empty?()
        puts "All players lost all their money, game over!"
        break
      end
    end
  end
end
