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
                play_crazy_eights(false)
            when '2'
                set_up
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
        input = STDIN.gets.chomp.strip
        input
    end

    def set_up
        @game = CrazyEightGame.create(player_id: @player.id, turn_count: 0)
        @game.new_deck
        @game.deal_start_hand(@player.id)
        @game.place_start_card
    end

    def game_over?(computer)
        @game.nil? || @game.remaining.zero? || @game.player_hand(@player.id).length.zero? || computer && @game.player_hand('computer').length.zero? 
    end

    def play_crazy_eights(computer)
        until game_over?(computer)
            if computer && @game.turn_count % 2 == 1 
                @game.computer_turn
            else
                @game.view_top_card
                @game.view_hand(@player.id)
                choice = turn_options.upcase
                puts `clear`
                case choice
                when '1'then @game.draw_card(@player.id)
                when '2'then rules
                when '3' then exit_game_and_delete_deck(@game)
                else @game.play_card(@player, choice)
                end
            end
        end
        check_for_winner(computer)
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
        computer ? @game.turn_count/2 + 1 : @game.turn_count
    end

    def check_for_winner(computer)
        if @game.nil? != true && @game.remaining.positive? && @game.player_hand(@player.id).length.zero?
            puts "Nice job, you won! It took you #{winning_turns(computer)} turns."
        elsif @game.nil? != true && @game.remaining.positive? && computer && @game.player_hand('computer').length.zero?
            puts 'Womp womp, the computer played all of its cards. YOU LOSE.'.red
            puts "😕🙁😦😧😮😢😭😭😭"
        elsif @game.nil? != true
            puts 'Good effort, better luck next time.'
        end
    end

    def rules
        puts 'The goal of the game is to get rid of all of your cards before the'
        puts 'computer plays everything in their hand. To end each turn, you '
        puts 'must play a card, and that card must be either the same suit or '
        puts "number as the card on the top of the play pile. If you don't have"
        puts "a card in your hand that you can play, or you don't want to play "
        puts 'any of the cards in your hand, you can draw from the top of the '
        puts "deck. There's one exception, though! Eights are wild. That means "
        puts "you can play an Eight at any time, and when you do, you'll have "
        puts 'the opportunity to choose a new suit for the next card laid. You '
        puts 'win if you play all of your cards first! You lose if the computer'
        puts 'plays all of their cards first, or if you get to the end of the '
        puts 'deck without anyone playing all of their cards.'
        puts
        puts 'Good luck!'
    end

end
