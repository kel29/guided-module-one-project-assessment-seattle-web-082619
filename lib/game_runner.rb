class GameRunner

    def welcome
        puts `clear`
        puts "Let's play Crazy Eights! Enter your username: "
        name = STDIN.gets.strip.downcase.capitalize
        player = Player.find_by(username: name)
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
            home_menu
            input = STDIN.gets.chomp.strip
            puts `clear`
            case input
            when '1'
                set_up_new_game
                play_crazy_eights(false)
            when '2'
                set_up_new_game
                @game.deal_start_hand('computer')
                play_crazy_eights(true)
            when '3' then rules
            when '4'
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
        puts "To start a single player game, [enter] '1'"
        puts "To play against the computer, [enter] '2'"
        puts "To view the rules, [enter] '3'"
        puts "To exit, [enter] '4'"
        puts
    end

    def set_up_new_game
        @game = CrazyEightGame.create(player_id: @player.id, turn_count: 0)
        @game.new_deck
        @game.deal_start_hand(@player.id)
        @game.place_start_card
    end

    def game_over?(computer)
        @game.nil? || @game.remaining.zero? || player_out_of_cards? || computer_out_of_cards?(computer)
    end

    def player_out_of_cards?
        @game.player_hand(@player.id).length.zero?
    end

    def computer_out_of_cards?(computer)
        computer && @game.player_hand('computer').length.zero?
    end

    def play_crazy_eights(computer)
        until game_over?(computer)
            if computer && @game.turn_count % 2 == 1 
                @game.computer_turn
            else
                @game.view_top_card
                @game.view_hand(@player.id)
                display_turn_options
                choice = STDIN.gets.strip.upcase
                puts `clear`
                case choice
                when '1' then @game.draw_card(@player.id)
                when '2' then rules
                when '3' then exit_game_and_delete_deck(@game)
                else @game.play_card(@player, choice)
                end
            end
        end
        check_for_winner(computer)
    end

    def display_turn_options
        puts
        puts 'What would you like to do?'
        puts
        puts 'To play a card, [enter] the card code:'
        puts "To draw a card, [enter] '1'"
        puts "To review the rules, [enter] '2'"
        puts "To exit and end this game, [enter] '3'"
        puts
    end

    def exit_game_and_delete_deck(game)
        puts 'Are you sure you want to exit and end this game?'
        puts "[enter] 'yes' to confirm."
        input = STDIN.gets.strip.downcase
        case input
        when 'yes'
            Hand.where(deck_api_id: game.deck_api_id).destroy_all
            game.destroy
            @game = nil
        end
    end

    def winning_turns(computer)
        computer ? @game.turn_count / 2 + 1 : @game.turn_count
    end

    def check_for_winner(computer)
        if @game.nil? != true && @game.remaining.positive? && player_out_of_cards?
            puts "Nice job, you won! It took you #{winning_turns(computer)} turns.".green
        elsif @game.nil? != true && @game.remaining.positive? && computer_out_of_cards?(computer)
            puts 'Womp womp, the computer played all of its cards. YOU LOSE.'.red
            puts "😕🙁😦😧😮😢😭😭😭"
        elsif @game.nil? != true
            puts 'Good effort, better luck next time.'
        end
    end

    def rules
        puts 'The goal of the game is to get rid of all of your cards! If you '
        puts 'are playing in the single player mode, you must do this before '
        puts 'you reach the end of the deck, while when playing the computer '
        puts 'you want to get rid of all of your cards before both the end of '
        puts 'the deck and before computer plays everything in their hand. To '
        puts 'end each turn, you must play a card, and that card must be either'
        puts 'the same suit or number as the card on the top of the play pile.'
        puts "If you don't have a card in your hand that you can play, or you "
        puts "don't want to play any of the cards in your hand, you can draw "
        puts "from the top of the deck. There's one exception, though! Eights "
        puts 'are wild. That means you can play an Eight at any time, and when '
        puts "you do, you'll have the opportunity to choose a new suit for the "
        puts 'next card laid. You win if you play all of your cards (or are the'
        puts 'first to do so when playing against the computer)!'
        puts
        puts 'Good luck!'
    end

end
