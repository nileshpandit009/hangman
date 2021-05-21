# frozen_string_literal: true

require './hangman'

puts 'Please choose a difficulty: '
puts '1. Easy'
puts '2. Medium'
puts '3. Hard'
puts ''
choice = gets.chomp

difficulty = case choice
             when '1'
               300
             when '3'
               60
             else
               120
             end

hangman = Hangman.new(difficulty)

hangman.start
