class GameRunner

    def initialize
        @player = nil
        @game = nil
    end

    def welcome
        puts `clear`
        puts "Let's play Crazy Eights! Enter your username: "
        name = STDIN.gets.strip.downcase.capitalize
        player = Player.find_by username: name
        if player.nil?
            @player = Player.create(username: name)
            puts "Welcome, new player #{name}!"
        else
            @player = player
            puts "Welcome back #{name}!"
        end
    end

    def game_options
        user_is_active = true
        while user_is_active
            input = home_menu
            puts `clear`
            case input
            when '1'
                set_up
                play_crazy_eights
                puts `clear`
                check_for_winner
            when '2' then rules
            when '3'
                puts 'Goodbye!'
                user_is_active = false
            else
                puts "Mmm, I'm getting mixed signals. Can you try making a "
                puts 'selection again? Just enter 1, 2, or 3 please.'
            end
        end
    end

    def home_menu
        puts
        puts "To start a new game, [enter] '1'"
        puts "To view the rules, [enter] '2'"
        puts "To exit, [enter] '3'"
        puts
        input = STDIN.gets.chomp.strip
        input
    end

    def set_up
        @game = CrazyEightGame.create(player_id: @player.id, turn_count: 0)
        @game.new_deck
        @game.deal_start_hand(@player.id)
        @game.deal_start_hand('computer')
        @game.place_start_card
    end

    def game_over?
        @game.nil? || @game.player_hand(@player.id).length.zero?
    end

    def play_crazy_eights
        until game_over?
            if @game.turn_count % 2 == 1
                @game.computer_turn
            else
                @game.view_top_card
                @game.view_hand(@player.id)
                choice = turn_options.upcase
                puts `clear`
                case choice
                when '1'then @game.draw_card(@player.id)
                when '2'then rules
                when '3'
                    @game.exit_game_and_delete_deck
                    @game = nil
                else @game.play_card(@player, choice)
                end
            end
        end
    end

    def turn_options
        puts
        puts 'What would you like to do?'
        puts
        puts 'To play a card, [enter] the card code:'
        puts "To draw a card, [enter] '1'"
        puts "To review the rules, [enter] '2'"
        puts "To exit and end this game, [enter] '3'"
        puts
        choice = STDIN.gets.strip
        choice
    end

    def check_for_winner
        if @game.nil? != true && @game.turn_count < 44
            puts "Nice job, you won! It took you #{@game.turn_count/2.ceil} turns."
        elsif @game.nil? != true
            puts 'Good effort, better luck next time.'
        end
    end

    def rules
        puts 'The goal of the game is to get rid of all of your cards. Each'
        puts 'turn you must play a card, and that card must be either the same '
        puts 'suit or number as the card on the top of the play pile. If you '
        puts "don't have a card in your hand that you can play, or you don't "
        puts 'want to play any of the cards in your hand, you can draw from '
        puts "the top of the deck. There's one exception, though! Eights are "
        puts 'wild. That means you can play an Eight at any time, and when you '
        puts "do, you'll have the opportunity to choose a new suit for the next"
        puts 'card laid. You win when you run out of cards, and you lose if '
        puts 'you get to the end of the deck without playing all of your cards.'
        puts
        puts 'Good luck!'
    end

end