# frozen_string_literal: true

# This is a simple hangman console game
class Hangman
  require 'net/http'    # Used for making api calls
  require 'json'        # Used to parse JSON response from api
  require 'io/console'  # Used for console operations

  # Time limit can be set while creating the instance.
  # This functionality is kept in case
  # we want to implement difficulty modes later.
  # Easy -    300 seconds = 5 minutes.
  # Medium -  120 seconds = 2 minutes (Default).
  # Hard -    60 seconds = 1 minute.
  def initialize(timeout = 120)
    @timeout = timeout
  end

  def start
    greet
    start_game
    # puts @word
    print_line
    take_guess while @guess_left.positive? && @places.include?('-')
    end_game
  end

  private

  def greet
    puts 'Hello and welcome to Hangman'
  end

  # Hitting random-word-api and getting exactly one random word
  # parsing the body to JSON and accessing the word if response code is 200
  def choose_word
    uri = URI('https://random-word-api.herokuapp.com/word?number=1')
    res = Net::HTTP.get_response(uri)
    JSON.parse(res.body)[0] if res.is_a?(Net::HTTPSuccess)
  end

  def start_game
    puts 'Choosing a word please wait...'
    @word = choose_word

    # As we are removing correctly guessed letters from @word
    # We connot use this to show the complete word if user fails.
    # We make a copy of @word instance var using Marshaling / Unmarshaling
    @word_backup = Marshal.load(Marshal.dump(@word))
    @guess_left = @word.length
    @places = Array.new(@word.length) { '-' }
    # timer method runs a thread that sleeps for a specific time
    # i.e. time given to the user for guessing the word.
    # after sleep, the program calls exit(0)
    # after printing a game over message.
    timer
    puts "Here's your word."
  end

  # Checks if the input char is present in the word
  # by calling String#index method.
  # if return val is nil then @guess_left is decremented by 1
  # else @places array is updated and printed again.
  def take_guess
    guess = read_char
    idx = @word.index(guess)
    if idx.nil?
      @guess_left -= 1
    else
      update_places(guess, idx)
    end
    print_line
  end

  # Read a char from STDIN
  # exits the program on Ctrl+C
  def read_char
    input = $stdin.getch
    control_c_char = "\u0003"
    exit(1) if input == control_c_char
    input
  end

  # Prints the @places array in a user understandable fashion.
  # Also, prints the number of guesses left
  def print_line
    $stdout.flush
    print_places
    print_guesses_left
  end

  def print_places
    # $stdout.flush
    print "\r[ #{@places.join(' ')} ]"
  end

  def print_guesses_left
    print "\t\tGuesses left: #{@guess_left}    "
  end

  # Replaces char at index in @word string with a '-' (assumed blank char)
  # Also, replaces '-' at index in @places array with char from @word
  def update_places(char, idx)
    @word[idx] = '-'
    @places[idx] = char
  end

  # When the loop is broken, either because,
  #     user was out of guesses
  #       or
  #     user guessed all chars correctly
  # this end_game method prints appropriate message
  # according the cases mentioned above and exits.
  def end_game
    puts ''
    if @places.include?('-')
      puts 'Out of guesses.'
      puts "The word was: '#{@word_backup}'"
    else
      puts 'Congratulations. You Won!'
    end
    exit
  end

  # Starts the timer which, when expired, exits the program.
  # Also, let's the user know about the same.
  def timer
    puts "Timer has started. You have #{@timeout / 60} minute(s)."
    Thread.new do
      sleep(@timeout)
      puts "\n\r"
      puts 'Time out. Better luck next time.'
      puts "\n\r"
      exit(0)
    end
  end
end
