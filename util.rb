# provides some utility for reading from the stdin
class Util

  # Get an integer from user input, retry on bad input
  # return the integer
  def self.get_i
    input = gets.chomp()
    while !input.is_i?()
      print "\tInput must be an integer, try again -> "
      input = gets.chomp()
    end
    input.to_i()
  end

  # helper method: get a single letter input that must be contained by an 
  # expected string, retry on bad inputc
  # return the input string
  def self.get_choice(expected)
    input = gets.chomp()
    choices = expected.split('').map {|c| '\'' + c + '\''}
    while input.size() != 1 || !expected.include?(input.downcase)
      print "\tPlease enter one of %s. Try again -> " %choices.join(', ')
      input = gets.chomp()
    end
    input.downcase
  end
end
