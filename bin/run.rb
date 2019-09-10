require_relative '../config/environment'
require 'pry'
require 'JSON'
require 'rest-client'

game = GameRunner.new
game.welcome
game.game_options

Pry.start

