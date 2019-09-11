class GameRunner

    def initialize
        @player = nil
        @game = nil
    end

    def welcome
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
            if input == '1'
                set_up
                play_crazy_eights
                check_for_winner
            elsif input == "2"
                rules
            elsif input == "3"
                puts "Goodbye!"
                user_is_active = false
            else
                puts "Mmm, I'm getting mixed signals. Can you try making a "
                puts "selection again? Just enter 1, 2, or 3 please."
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
        @game = CrazyEightGame.create(player_id: @player.id)
        @game.new_deck
        @game.deal_start_hand(player_id: @player.id, deck_id: @game.deck_id)
        @game.place_start_card
    end

    def game_over?
        @player.player_hand(@game.deck_id).length.zero?
    end

    def play_crazy_eights
        until game_over?
            choice = turn_options
            if choice == '1'
                @player.view_hand(@game.deck_id)
            elsif choice == '2'
                @player.view_top_card(@game.deck_id)
            elsif choice == '3'
                @game.draw_card(player_id: @player.id, deck_id: @game.deck_id)
            elsif choice == '4'
                @player.play_card(@game.deck_id)
            elsif choice == '5'
                rules
            elsif choice == '6'
                @player.exit_game_and_delete_deck(@game)
            else
                puts "Hmm, I'm getting mixed signals. Can you try making a "
                puts "selection again? Just enter 1, 2, 3, 4, 5 or 6 please."
            end
        end
    end

    def turn_options
        puts "What would you like to do?"
        puts
        puts "To view your hand, [enter] '1'"
        puts "To view the top play card, [enter] '2'"
        puts "To draw a card, [enter] '3'"
        puts "To play a card, [enter] '4'"
        puts "To review the rules, [enter] '5'"
        puts "To exit and end this game, [enter] '6'"
        puts
        choice = STDIN.gets.strip
        choice
    end

    def check_for_winner
        puts "Nice job, you won!" if @game.nil? && @game.remaining > 0
    end

    def rules
        puts "The goal of the game is to get rid of all of your cards. "
        puts "Each turn you must play a card, and that card must be either " 
        puts "the same suit or number as the card on the top of the play pile."
        puts "If you don't have a card in your hand that you can play, or you "
        puts "don't want to play any of the cards in your hand, you can draw "
        puts "from the top of the deck. There's one exception, though! Eights "
        puts "are wild. That means you can play an Eight at any time, and when "
        puts "you do, you'll have the opportunity to choose a new suit for the "
        puts "next card laid. You win when you run out of cards, and you lose if "
        puts "you get to the end of the deck without playing all of your cards. "
        puts "Good luck!"
    end

end