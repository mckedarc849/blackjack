# Add a is_i? method in the String class to test if a string is a integer
class String

  # test if the string is a representation of a integer
  # return true if is integer, false otherwise
  def is_i?
    !!(self =~ /^[-+]?[0-9]+$/)
  end
end
