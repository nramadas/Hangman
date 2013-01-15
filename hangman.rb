class Hangman

  def initialize
    @secret_guess = @referee.choose_secret
    @guesser.secret_length = @secret_guess.length
  end

  def game_board
    p ['_ '] * @secret_guess.length
  end
end

class Player
  attr_accessor :secret_length, :wrong_letters, :dictionary

  def initialize
    @dictionary = load_dictionary
    @secret_length = nil
    @wrong_letters = []
  end

  def load_dictionary(filename = 'dictionary.txt')
    File.readlines(filename).map { |word| word.chomp.downcase }
  end
end

class HumanPlayer < Player
  def initialize
    super
  end

  def guess
    puts "What letter do you want to guess?"
    gets.chomp.downcase[0]
  end

  def validate_guess(letter)
    puts "Is #{letter} in your word? (y/n)"
    answer = gets.chomp.downcase
    if answer == "y"
      puts "Where does the letter appear? (seperate locations with comma)"
      answer = gets.chomp.split(',').map { |location| location.to_i }
      {:response => :correct, :letter => letter, :location => answer }
    else
      {:response => :wrong, :letter => letter, :location => []}
    end
  end

  def choose_secret
    puts "What word do you want the computer to guess?"
    guess = gets.chomp.downcase
    unless @dictionary.include?(guess)
      puts "Not found in dictionary, try again."
      return choose_secret
    end
    guess
  end
end

class ComputerPlayer < Player
  def initialize
    super
    @guessed_letters = []
  end

  def guess
    highest_frequency = 0
    most_common_letter = ""
    ('a'..'z').each do |letter|
      next if @guessed_letters.include?(letter)
      letter_frequency = @dictionary.join.count(letter)
      if letter_frequency > highest_frequency
        most_common_letter = letter 
        highest_frequency = letter_frequency
      end
    end
    @guessed_letters << most_common_letter
    most_common_letter
  end

  def register_guess(guess = {:response => :wrong, :letter => nil, :location => []})
    if guess[:response] == :wrong
      prune_dict_if_wrong(guess[:letter])
    else
      prune_dict_if_right(guess[:letter], guess[:location])
    end
  end

  def validate_guess(letter)
    locations = []
    @secret_guess.each_with_index do |l, i|
      locations << i if l==letter
    end
    if locations.empty?
      {:response => :wrong, :letter => letter, :location => []}
    else
      {:response => :correct, :letter => letter, :location => locations}
    end
  end

  def choose_secret
    @dictionary.sample
  end

  def prune_dict_if_wrong(letter)
    @dictionary.select! { |word| !word.include?(letter) }
  end

  def prune_dict_if_right(letter, indices)
    @guessed_letters << letter
    indices.each do |index|
      @dictionary.select! { |word| word[index] == letter }
    end
  end

  def prune_dict_by_length
    @dictionary.select! { |word| word.length == @secret_length }
  end
end

# test script
c = ComputerPlayer.new
c.secret_length = 5
c.prune_dict_by_length
puts c.guess
puts c.guess
puts c.guess
puts c.guess