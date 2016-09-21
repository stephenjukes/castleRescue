# BUGS
# Items dropped in jail are not showing up
# Entering jail after going in the wrong direction in the clinic throws an error
# Jail seems to have lost normal functionality from options

    #$in_jail = false
    $win = false
    $invisibility = false
    $guard_asleep = false

    $possessions = []
    $wearing = []
    $location = "hallway"

    $furniture = {
        "hallway" => "drawer",
        "bedroom" => "closet",
        "clinic" => "cabinet"
    }

    $items = {
        "hallway" => ["rope"],
        "clinic" => [],
        "bedroom" => ["bottle of perfume", "hand mirror"],
        "jail" => [],
        "drawer" => ["knife", "key"],
        "closet" => ["pair of seven league boots", "invisibility cloak", "helmet"],
        "cabinet" =>["bottle of sleeping pills", "box of painkillers", "roll of bandages"],
        "bed" => ["pillow", "sheets"]
        }

    $item_syn = {
        "boots" => "pair of seven league boots",
        "cloak" => "invisibility cloak",
        "perfume" => "bottle of perfume",
        "mirror" => "hand mirror",
        "sleeping" => "bottle of sleeping pills",
        "painkillers" => "box of painkillers",
        "bandages" => "roll of bandages"
    }

    def introduction1
        puts """
   Greetings to you. You find yourself at the castle entrance,
   where your friend is being held prisoner.
   You had originally embarked upon this rescue adventure
   filled with courage and determination,
   but on seeing the skulls of previous adventurers
   still adorning the spikes of the castle walls
   you suddenly wonder if this was really such a good idea.

   Last chance to turn back and live to see another day.
   Are you sure you want to continue? (yes / no)
            """
        print "> "
        input = gets.chomp

        if input.downcase().include? "y"
            introduction2
        else
            puts "   Not so bold after all. Maybe see you another day.", ""
            exit(0)
        end
    end

    def introduction2
        puts """
   That's the spirit!
   Here is some advice which will help you along your way:

   1) In order to move between rooms,
      .. use any of the 4 directions: [North, East, South and West].
   2) You may check your possessions at any time,
      .. simply by uttering the words: \"Check possessions\".
   3) Many of the portable items are large,
      .. therefore you can only pick up one item at a time.

   Beyond this, you are one your own.
   By the way, what is the name of your prisoner friend?
            """
        print "> "
        $friend = gets.chomp

        puts "", "   Godspeed to you my friend,"
        puts "   and I hope you and #{$friend} live to see another day."
        puts "   Hit [Enter] to .. well .. enter."
        gets.chomp
        hallway1
    end

    def hallway1
        $location = "hallway"
        puts ".. You enter a large hallway."
        puts "   On your right, there is a desk with a drawer."
        puts "   There is a door to the NORTH and a door to the WEST."
        puts "   Further ahead is a coat rack."
        print "   Hanging from one of the hooks" if $items["hallway"].include? "rope"

        dropped_items
        choice
    end

    def drawer
        $location = "drawer"
        visible_items
    end

    def clinic1
        $location = "clinic"
        puts ".. You enter a clinic."
        puts "   There is a blood stained bed and a medicine cabinet"
        puts "   There is a door to the NORTH and a door to the EAST"
        dropped_items
        choice
    end

    def cabinet
        $location = "cabinet"
        visible_items
    end

    def bedroom1
        $location = "bedroom"
        puts ".. You enter a bedroom."
        puts "   Ahead is a dressing table."
        puts "   On your left there is a closet."
        puts "   There is a door to the SOUTH"
        dropped_items
        choice
    end

    def closet
        $location = "closet"
        visible_items
    end

    def jail1
        $location = "jail"
        puts ".. You enter the jail room."
        puts "   You see #{$friend} behind the cell door."
        puts "   A guard sits drinking nearby."
        puts "   There is a door to the SOUTH"
        puts "   The guard glares at you, rises and strides quickly towards you." if $invisibility == false
        dropped_items
        choice
    end

    def jail(input)

        input_arr = input.split(' ')

        option1 = {
            "withdraw" => [["exit", "leave", "return", "go back", "escape", "evacuate", "away", "out", "withdraw", "south"]],
            "spike" => [["spike", "add", "put", "pour", "drug", "drop"], ["sleeping"], ["drink", "cup", "glass"]],
            "unlock" => [["open", "unlock"], ["door", "jail", "cell", "gate"], ["key"]],
            "wear" => [["wear", "on"], ["cloak"]]
        }

        option2 = []
        matches = 0
        decision = ""

        option2 = option1.each do |key, arr|
                    matched = arr.map! {|sub_arr| sub_arr & input_arr}  #matches sub arrays with input words
                    combined = matched.join(' ').split(' ')
                    if combined.length > matches  #selects key with most matches
                        decision = key
                        matches = combined.length
                    end
                end
        if !$invisibility && !$guard_asleep
            # if unsafe
            if decision == "withdraw"
                clinic1
                #choice

            elsif decision == "wear"
                if ($invisibility == false) && ($possessions.include? "invisibility cloak")
                    puts ".. You instantly turn invisible."
                    $invisibility = true
                elsif $invisibility == true
                    puts ".. You are already wearing the invisibility cloak"
                else
                    puts ".. You do not possess the invisibility cloak."
                    game_over(input)
                end
                #choice
            else
                game_over(input)
            end
        else # if $safe

            # drug guard
            if decision == "spike" && $invisibility == true
                if matches < 3
                    puts ".. Please be more specific."
                elsif !$possessions.include? "bottle of sleeping pills"
                    puts ".. You don't have possess any sleeping pills."
                else
                    puts ".. You #{input}.\n   The guard sips his drink, yawns\n   and falls asleep."
                    $guard_asleep = true
                end
                #choice

            # open door
            elsif decision == "unlock"
                if ($invisibility || $guard_asleep) == true && matches < 3
                        puts ".. Please be more specific."
                elsif !$possessions.include? "key"
                        puts ".. You don't possess a key."
                elsif $guard_asleep == false && $invisibility == true
                        puts ".. The guard sees the door open and closes it."

                elsif $guard_asleep == true

                        $win = true
                        game_over
                end
                #choice

            else
                puts ".. You try to #{input} but it has no effect."

            end
        end
        choice
    end

    def choice
        puts ""
        puts "What would you like to do?"
        print "> "
        input = gets.chomp
        puts ""
        options(input)
    end

    def options(input)
        input_arr = input.split(' ')

        take = ["take", "catch", "collect", "get", "grab", "pick"]
        drop = ["drop", "leave", "down", "discard", "ditch", "dump", "let go", "rid", "lose"]
        wear = ["wear", "on"]
        items = ["rope", "knife", "key", "boots", "cloak", "helmet", "perfume", "mirror",
                "sleeping", "painkillers", "bandages", "pillow", "sheets"]

        open = ["open", "pull", "check"]
        furniture_arr = []
        $furniture.each_value {|article| furniture_arr << article}

        direction = ["north", "south", "east", "west"]
        check = ["check", "possessions"]


        take_inp = (input_arr & take) + (input_arr & items)
        drop_inp = (input_arr & drop) + (input_arr & items)
        wear_inp = (input_arr & wear) + (input_arr & items)
        open_inp = (input_arr & open) + (input_arr & furniture_arr)
        check_inp = (input_arr & check)
        dir_inp = direction & input_arr


        if dir_inp.any?
            direction(dir_inp[0])
        elsif take.include? take_inp[0]
            take(take_inp)
        elsif drop.include? drop_inp[0]
        #    if drop_inp.include?
            drop(drop_inp)
        elsif wear.include? wear_inp[0]
            wear(wear_inp)
        elsif check_inp.size == 2
            if $possessions.empty?
                puts ".. You have no possessions."
            else
                puts ".. You are carrying a:"
                puts $possessions
            end
        elsif open.include? open_inp[0]
            if $location == "jail"
                jail(input)
            else
                open(open_inp)
            end
        elsif $location == "jail"
                jail(input)
        else
            puts ".. You #{input}."
            puts "   Nothing happens."
            choice
        end
    end

    def visible_items
        visible = $items[$location]
        q = visible.length
        # Structuring sentence regarding contents
        if q < 1
            puts ".. The drawer is empty."
        elsif q == 1
            puts " .. There is a #{visible[0]}"
        else
        puts "   .. There is:"
            (0...q-1).each do |i|
                puts "\t- a #{visible[i]}, " # listing
            end
            puts "\t- and a #{visible[-1]}." # prefixing final item with 'and'
        end
        choice
    end

    # ensures that abreviated items are returned to their standard names
    # (for search and presentation purposes)
    def to_standard_text(input)
        input.map! do |word|
            if $item_syn.include? word
                $item_syn[word]
            else
                word
            end
        end
    end

    def take(input)

        to_standard_text(input)

        item = input[1]
        room_item = $items[$location]

        capacity = 6
        if $possessions.length == capacity
            puts ".. You are only able to carry #{capacity} items."
            puts "   You will need to drop something in order to take the #{item}"
        elsif room_item.include? item
            $possessions << item
            q = $possessions.length
            room_item.delete(item)
            puts ".. You took the #{item}. "
            puts q == 1? "  You are now carrying #{q} item": "You are now carrying #{q} items"
        elsif $possessions.include? item
            puts ".. You already have this item."
        else
            puts ".. You cannot do that."
        end
        choice
    end

    def drop(input)

        to_standard_text(input)

        item = input.last
        room_item = $items[$location]

        if $possessions.include? item
            $possessions.delete(item)
            room_item << item
            q = $possessions.length
            puts ".. You dropped the #{item}. "
            puts q == 1? "You are now carrying #{q} item": "You are now carrying #{q} items"
        else
            puts ".. You do not posses this item."
        end
        choice
    end

    def dropped_items
        if $items[$location].any?
            visible_items
        end
    end

    def open(input)
        article = input[-1]

        if $location == "jail"
            jail(input)
        elsif article == $furniture[$location]
            puts ".. You opened the #{article}"
            send(article) #second match - presumably the opened object
        else
            puts ".. You cannot do that."
            choice
        end
    end

    def direction(input)
        go = {
            "hallway" => {"north" => "bedroom1", "east" => "", "south" => "", "west" => "clinic1"},
            "clinic" => {"north" => "jail1", "east" => "hallway1", "south" => "", "west" => ""},
            "bedroom" => {"north" => "", "east" => "", "south" => "hallway1", "west" => ""},
            "jail" => {"north" => "", "east" => "", "south" => "clinic1", "west" => ""}
            }
        go["drawer"] = go["hallway"]
        go["cabinet"] = go["clinic"]
        go["closet"] = go["bedroom"]

        dest = go[$location][input]

        if dest == ""
            puts ".. You cannot go in that direction"
            choice; #options
        else
            send(dest)
        end
    end

    def wear(input)

        to_standard_text(input)

        item = input.last
        room_item = $items[$location]

        if (room_item.include? item) || ($possessions.include? item)
            puts ".. You put on the #{item}"
            if item == "pair of seven league boots"
                puts "   You instantly feel fleet of foot!"
            elsif item == "invisibility cloak"
                puts "   You instantly become invisible!"
                $invisibility = true
            elsif item == "helmet"
                puts "   It's pretty heavy!"
            end
        else
            puts ".. There is no #{item} here."
        end

        #incomplete, item still needs to be subtracted from possession number !
        $wearing << item
        room_item.delete(item) if room_item.include? item
        $possessions.delete(item) if $possessions.include? item
        choice
    end

    def game_over(input = nil)

        if $win == true
            puts ".. You unlock the door and release #{$friend}"
            puts "   CONGRATULATIONS ! You have won the game ! :D"
        else
            puts ".. You try to #{input} but the guard catches hold of you,"
            puts "   overpowers you and knocks you unconscious."
            puts "   When you awake, you find yourself in a cell"
            puts "   without any of your possessions.",""
            puts "   GAME OVER :( Better luck next time!"
        end

        puts "", ".. Would you like to play again?"
        print "> "
        input = gets.chomp
        puts ""

        if input.downcase().include? "y"
            $win = false
            $invisibility = false
            $guard_asleep = false

            $possessions = []
            $wearing = []
            $location = "hallway"

            $furniture = {
                "hallway" => "drawer",
                "bedroom" => "closet",
                "clinic" => "cabinet"
            }

            $items = {
                "hallway" => ["rope"],
                "clinic" => [],
                "bedroom" => ["bottle of perfume", "hand mirror"],
                "jail" => [],
                "drawer" => ["knife", "key"],
                "closet" => ["pair of seven league boots", "invisibility cloak", "helmet"],
                "cabinet" =>["bottle of sleeping pills", "box of painkillers", "roll of bandages"],
                "bed" => ["pillow", "sheets"]
                }

            $item_syn = {
                "boots" => "pair of seven league boots",
                "cloak" => "invisibility cloak",
                "perfume" => "bottle of perfume",
                "mirror" => "hand mirror",
                "sleeping" => "bottle of sleeping pills",
                "painkillers" => "box of painkillers",
                "bandages" => "roll of bandages"
            }

            hallway1
        else
            puts "", ".. Goodbye, play again soon.", ""
            exit(0)
        end
    end

    puts ""
    puts "    *********************************************"
    puts "    * A STEPHEN JUKES EXTRAORDINAIRE PRODUCTION *"
    puts "    *********************************************"

    introduction1
