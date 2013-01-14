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
  attr_accessor :secret_length, :wrong_letters

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

  def validate_guess
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
    count = 0
    freq_letter = ""
    letters = []
    @dictionary.each {|word| letters += word.split('')}
    letters.each do |letter|
      next if @guessed_letters.include?(letter)
      if letters.count > count
        count = letters.count
        freq_letter = letter
      end
    end
  end

  def register_guess(guess = {:response => :wrong, :letter => nil, :location => []})
    if guess[:response] == :wrong
      prune_dictionary(guess[:letter])
    else
      narrow_options(guess[:letter], guess[:location])
    end
  end

  def validate_guess(letter)
    locations = []
    @secret_guess.each_with_index do |l, i|
      locations << i if l==letter
    end
    locations
  end

  def choose_secret
    @dictionary.sample
  end

  def prune_dictionary(letter)
    @dictionary.select! { |word| !word.include?(letter) }
  end

  def narrow_options(letter, indices)
    @guessed_letters << letter
    indices.each do |index|
      @dictionary.select! { |word| word[index] == letter }
    end
  end

  def exclude_words
    @dictionary.select! { |word| word.length == @secret_length }
  end
end
