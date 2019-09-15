require_relative '../config/environment'
require 'pry'
require 'JSON'
require 'rest-client'
require 'colorize'

game = GameRunner.new
game.welcome
game.game_options
