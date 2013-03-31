require 'util'

# Game logic, most of the game rule logic are implemented in this class
class Game

  def initialize(dealer, deck, players)
    @players = players
    @dealer, @deck = dealer, deck
    # An array of players active, active is defined by players who are neither 
    # busted nor chosen to stay.
    @active_players = players.clone()
    # An array of players who have chosen to stay with their hand. All players
    # in this array need to be compared with the dealer if the dealer is not 
    # busted.
    @stayed_players = Array.new()
    clean_up()
  end

  # clear hands so that it does not persist across games
  def clean_up()
    @players.each do |player|
      player.hands = Array.new()
      player.hands << Hand.new(0)
    end
    @dealer.hand0.clear()
  end

  # Play the game with the following steps:
  # 1. Deal all players (including the dealer) 2 cards to start with
  # 2. Ask each player what action they want to perform based on the 
  #    initial 2 cards
  # 3. Dealer choose hit or stay based on its first 2 cards
  # 4. Compare all players who survived the rounds with the dealer to determine
  #    win/lose/draw
  # In step 1 - 3, the possible outcome of blackjack and/or bust are checked and 
  # handled as well.
  def play
    ask_bets()
    initial_deal()
    interact()
    dealer_busted = dealer_act()
    compare(dealer_busted)

    # display money
    @players.each do |player|
      puts player
    end
  end

  # Ask bets from all user.
  def ask_bets
    @active_players.each do |player|
      printf "Player %s: please enter bet amount -> " % player.name
      player.hand0.bet = Util.get_i()
    end
  end

  # Deal initial 2 cards to players and dealer. Check for a blackjack, bust is 
  # not possible at this stage
  def initial_deal
    puts '----------------------- deal initial 2 cards  -----------------------'
    # This mimics the dealing order rule in a real game, but is not strictly 
    # neccessary
    @active_players.each do |player|
      player.hand0 << @deck.draw()
    end
    @dealer.hand0 << @deck.draw()
    @active_players.each do |player|
      player.hand0 << @deck.draw()
    end
    @dealer.hand0 << @deck.draw()

    # Dealer got a blackjack, any player who got a blackjack as well ties
    # with the dealer, all other players loses
    if @dealer.hand0.blackjack?()
      puts "dealer BLACKJACK!"
      while !@active_players.empty?()
        player = @active_players.shift()
        if player.hand0.blackjack?()
          puts "player %s draw with dealer (both blackjack)" %player.name
        else
          puts "player %s lose (dealer blackjack)" %player.name
          player.lose(player.hand0.bet)
        end
      end
    # Dealer did not get a blackjack, any player who got a blackjack immediately
    # wins the game
    else
      @active_players.each do |player|
        if player.hand0.blackjack?()
          puts "player %s BLACKJACK!" % player.name
          display_hands(player, player.hand0)
          player.win(player.hand0.bet)
          @active_players.delete(player)
        end
      end
    end

    display_hands(@dealer, @dealer.hand0)
    @active_players.each do |player|
      display_hands(player, player.hand0)
    end
  end

  # Interact with all players in order to get their choice, multiple times if 
  # needed.
  # After hit check for busted or blackjack. 
  # Continues until all players busted or stayed.
  def interact
    puts '----------------------- players\' turn  -----------------------'
    while !@active_players.empty?()
      player = @active_players.shift()
      loop do
        if player.hand0.size() == 2 && player.hand0[0].rank.eql?(player.hand0[1].rank)
          print "You got 2 cards of same rank. Split? (Y)es, (N)o -> " %player.name
          choice = Util.get_choice('yn')
          if choice.eql?('y')
            player.split()
          end
        end
        handle_all_hands(player)
        break
      end
    end
  end

  # for all hands ask the neccessary questions
  def handle_all_hands(player)
    player.hands.delete_if do |hand|
      # delete a hand if it's no longer needed (meaning that hand has already
      # won or lost)
      if handle_one_hand(player, hand)
        true
      end
    end
  end

  # ask questions for one hand, because the player may double down to have 
  # multiple hands
  # return true if bust, blackjack, or stayed
  def handle_one_hand(player, hand)
    display_hands(player, hand)
    loop do 
      # only allow double down if player has enough money
      if player.money >= hand.bet
        print "player %s, hand %d, (H)it, (S)tay, (D)ouble? -> " %[player.name, 
                                                                   hand.index]
        choice = Util.get_choice('hsd')
      else
        print "player %s, hand %d, (H)it, (S)tay -> " %[player.name, hand.index]
        choice = Util.get_choice('hs')
      end
      if choice.eql?('h') # hit
        if deal_and_check(player, hand)
          return true
        end
      elsif choice.eql?('s') # stay
        if !@stayed_players.include?(player)
          @stayed_players << player
        end
        return false
      elsif choice.eql?('d') # double edown
        # deal exactly one more card and finish
        hand.bet *= 2
        if deal_and_check(player, hand)
          return true
        else
          if !@stayed_players.include?(player)
            @stayed_players << player
          end
          return false
        end
      end
    end
  end

  # deal one card to a hand of a player and check for blackjack and bust
  # return true if either blackjack or bust happened
  def deal_and_check(player, hand)
    hand << @deck.draw()
    display_hands(player, hand)
    if hand.blackjack?() # blackjack immediately wins
      puts "player %s, hand %d BLACKJACK!" %[player.name, hand.index]
      player.win(hand.bet)
      return true
    elsif hand.bust?() # bust immediately loses
      puts "player %s, hand %d BUST!" %[player.name, hand.index]
      player.lose(hand.bet)
      return true
    else
      return false
    end
  end

  # Dealer hits on 16 and stays on 17.
  # Return true if dealer is busted, false otherwise
  # In this game we stay on soft 17 and up
  def dealer_act
    if !@stayed_players.empty?() # if all players busted or blackjack, stop
      puts '----------------------- dealer\'s turn  -----------------------'
      display_hands(@dealer, @dealer.hand0) 
      loop do
        if @dealer.hand0.values().max() <= 16
          puts 'dealer hit'
          @dealer.hand0 << @deck.draw()
          display_hands(@dealer, @dealer.hand0)
          if @dealer.hand0.blackjack?() 
            # dealer blackjack, all remaining players lose
            puts 'dealer BLACKJACK!'
            @stayed_players.each do |player|
              player.hands.each do |hand|
                puts "player %s, hand %d lose (dealer blackjack)" %[player.name,
                                                                    hand.index]
                player.lose(hand.bet) 
              end
            end
          elsif @dealer.hand0.bust?()
            puts 'dealer BUST!'
            return true
          end
        else
          puts 'dealer stay'
          return false
        end
      end
    end
  end

  # 
  def compare(dealer_busted)
    if !@stayed_players.empty?()
      puts '----------------------- play ended, compare  -----------------------'
      if dealer_busted
        # dealer bust, all remaining player win
        @stayed_players.each do |player|
          player.hands.each do |hand|
            puts "player %s, hand %d wins(dealer busted)!" %[player.name, 
                                                             hand.index]
            player.win(hand.bet)
          end
        end
      else
        # all players ended their move, compare values of those not won and not lost
        @stayed_players.each do |player|
          player.hands.each do |hand|
            if hand.final_value() > @dealer.hand0.final_value()
              puts "player %s, hand %d WINS!" %[player.name, hand.index]
              player.win(hand.bet)
            elsif hand.final_value() < @dealer.hand0.final_value()
              puts "player %s, hand %d LOSES!" %[player.name, hand.index]
              player.lose(hand.bet)
            else
              puts "player %s, hand %d DRAWS!" %[player.name, hand.index]
            end
          end
        end
      end
    end
  end

  # Display a participant's name, hand and value to stdout. 
  # Hide dealers second card and value if players have not finished playing.
  def display_hands(participant, hand)
    face_ups = hand.clone()
    value = hand.values().join(' or ')
    if participant.instance_of?(Participant) && !@active_players.empty?
      face_ups.pop()
      face_ups << Card.new('?', '?')
      value = '??'
    end
    puts "name: %s,\thand %d: %s,\tvalue: %s." % [participant.name, 
                                                  hand.index,
                                                  face_ups.join(', '), 
                                                  value.to_s]
  end
end
