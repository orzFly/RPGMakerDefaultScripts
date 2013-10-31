#
# This interpreter runs event commands. This class is used within the
# Game_System class and the Game_Event class.
#

class Interpreter
  #
  # Object Initialization
  #
  # depth : nest depth
  # main  : main flag
  #
  def initialize(depth = 0, main = false)
    @depth = depth
    @main = main
    # Depth goes up to level 100
    if depth > 100
      print("Common event call has exceeded maximum limit.")
      exit
    end
    # Clear inner situation of interpreter
    clear
  end
  #
  # Clear
  #
  #
  def clear
    @map_id = 0                       # map ID when starting up
    @event_id = 0                     # event ID
    @message_waiting = false          # waiting for message to end
    @move_route_waiting = false       # waiting for move completion
    @button_input_variable_id = 0     # button input variable ID
    @wait_count = 0                   # wait count
    @child_interpreter = nil          # child interpreter
    @branch = {}                      # branch data
  end
  #
  # Event Setup
  #
  # list     : list of event commands
  # event_id : event ID
  #
  def setup(list, event_id)
    # Clear inner situation of interpreter
    clear
    # Remember map ID
    @map_id = $game_map.map_id
    # Remember event ID
    @event_id = event_id
    # Remember list of event commands
    @list = list
    # Initialize index
    @index = 0
    # Clear branch data hash
    @branch.clear
  end
  #
  # Determine if Running
  #
  #
  def running?
    return @list != nil
  end
  #
  # Starting Event Setup
  #
  #
  def setup_starting_event
    # Refresh map if necessary
    if $game_map.need_refresh
      $game_map.refresh
    end
    # If common event call is reserved
    if $game_temp.common_event_id > 0
      # Set up event
      setup($data_common_events[$game_temp.common_event_id].list, 0)
      # Release reservation
      $game_temp.common_event_id = 0
      return
    end
    # Loop (map events)
    for event in $game_map.events.values
      # If running event is found
      if event.starting
        # If not auto run
        if event.trigger < 3
          # Clear starting flag
          event.clear_starting
          # Lock
          event.lock
        end
        # Set up event
        setup(event.list, event.id)
        return
      end
    end
    # Loop (common events)
    for common_event in $data_common_events.compact
      # If trigger is auto run, and condition switch is ON
      if common_event.trigger == 1 and
         $game_switches[common_event.switch_id] == true
        # Set up event
        setup(common_event.list, 0)
        return
      end
    end
  end
  #
  # Frame Update
  #
  #
  def update
    # Initialize loop count
    @loop_count = 0
    # Loop
    loop do
      # Add 1 to loop count
      @loop_count += 1
      # If 100 event commands ran
      if @loop_count > 100
        # Call Graphics.update for freeze prevention
        Graphics.update
        @loop_count = 0
      end
      # If map is different than event startup time
      if $game_map.map_id != @map_id
        # Change event ID to 0
        @event_id = 0
      end
      # If a child interpreter exists
      if @child_interpreter != nil
        # Update child interpreter
        @child_interpreter.update
        # If child interpreter is finished running
        unless @child_interpreter.running?
          # Delete child interpreter
          @child_interpreter = nil
        end
        # If child interpreter still exists
        if @child_interpreter != nil
          return
        end
      end
      # If waiting for message to end
      if @message_waiting
        return
      end
      # If waiting for move to end
      if @move_route_waiting
        # If player is forcing move route
        if $game_player.move_route_forcing
          return
        end
        # Loop (map events)
        for event in $game_map.events.values
          # If this event is forcing move route
          if event.move_route_forcing
            return
          end
        end
        # Clear move end waiting flag
        @move_route_waiting = false
      end
      # If waiting for button input
      if @button_input_variable_id > 0
        # Run button input processing
        input_button
        return
      end
      # If waiting
      if @wait_count > 0
        # Decrease wait count
        @wait_count -= 1
        return
      end
      # If an action forcing battler exists
      if $game_temp.forcing_battler != nil
        return
      end
      # If a call flag is set for each type of screen
      if $game_temp.battle_calling or
         $game_temp.shop_calling or
         $game_temp.name_calling or
         $game_temp.menu_calling or
         $game_temp.save_calling or
         $game_temp.gameover
        return
      end
      # If list of event commands is empty
      if @list == nil
        # If main map event
        if @main
          # Set up starting event
          setup_starting_event
        end
        # If nothing was set up
        if @list == nil
          return
        end
      end
      # If return value is false when trying to execute event command
      if execute_command == false
        return
      end
      # Advance index
      @index += 1
    end
  end
  #
  # Button Input
  #
  #
  def input_button
    # Determine pressed button
    n = 0
    for i in 1..18
      if Input.trigger?(i)
        n = i
      end
    end
    # If button was pressed
    if n > 0
      # Change value of variables
      $game_variables[@button_input_variable_id] = n
      $game_map.need_refresh = true
      # End button input
      @button_input_variable_id = 0
    end
  end
  #
  # Setup Choices
  #
  #
  def setup_choices(parameters)
    # Set choice item count to choice_max
    $game_temp.choice_max = parameters[0].size
    # Set choice to message_text
    for text in parameters[0]
      $game_temp.message_text += text + "\n"
    end
    # Set cancel processing
    $game_temp.choice_cancel_type = parameters[1]
    # Set callback
    current_indent = @list[@index].indent
    $game_temp.choice_proc = Proc.new { |n| @branch[current_indent] = n }
  end
  #
  # Actor Iterator (consider all party members)
  #
  # parameter : if 1 or more, ID; if 0, all
  #
  def iterate_actor(parameter)
    # If entire party
    if parameter == 0
      # Loop for entire party
      for actor in $game_party.actors
        # Evaluate block
        yield actor
      end
    # If single actor
    else
      # Get actor
      actor = $game_actors[parameter]
      # Evaluate block
      yield actor if actor != nil
    end
  end
  #
  # Enemy Iterator (consider all troop members)
  #
  # parameter : If 0 or above, index; if -1, all
  #
  def iterate_enemy(parameter)
    # If entire troop
    if parameter == -1
      # Loop for entire troop
      for enemy in $game_troop.enemies
        # Evaluate block
        yield enemy
      end
    # If single enemy
    else
      # Get enemy
      enemy = $game_troop.enemies[parameter]
      # Evaluate block
      yield enemy if enemy != nil
    end
  end
  #
  # Battler Iterator (consider entire troop and entire party)
  #
  # parameter1 : If 0, enemy; if 1, actor
  # parameter2 : If 0 or above, index; if -1, all
  #
  def iterate_battler(parameter1, parameter2)
    # If enemy
    if parameter1 == 0
      # Call enemy iterator
      iterate_enemy(parameter2) do |enemy|
        yield enemy
      end
    # If actor
    else
      # If entire party
      if parameter2 == -1
        # Loop for entire party
        for actor in $game_party.actors
          # Evaluate block
          yield actor
        end
      # If single actor (N exposed)
      else
        # Get actor
        actor = $game_party.actors[parameter2]
        # Evaluate block
        yield actor if actor != nil
      end
    end
  end
end


#
# This interpreter runs event commands. This class is used within the
# Game_System class and the Game_Event class.
#

class Interpreter
  #
  # Event Command Execution
  #
  #
  def execute_command
    # If last to arrive for list of event commands
    if @index >= @list.size - 1
      # End event
      command_end
      # Continue
      return true
    end
    # Make event command parameters available for reference via @parameters
    @parameters = @list[@index].parameters
    # Branch by command code
    case @list[@index].code
    when 101  # Show Text
      return command_101
    when 102  # Show Choices
      return command_102
    when 402  # When [**]
      return command_402
    when 403  # When Cancel
      return command_403
    when 103  # Input Number
      return command_103
    when 104  # Change Text Options
      return command_104
    when 105  # Button Input Processing
      return command_105
    when 106  # Wait
      return command_106
    when 111  # Conditional Branch
      return command_111
    when 411  # Else
      return command_411
    when 112  # Loop
      return command_112
    when 413  # Repeat Above
      return command_413
    when 113  # Break Loop
      return command_113
    when 115  # Exit Event Processing
      return command_115
    when 116  # Erase Event
      return command_116
    when 117  # Call Common Event
      return command_117
    when 118  # Label
      return command_118
    when 119  # Jump to Label
      return command_119
    when 121  # Control Switches
      return command_121
    when 122  # Control Variables
      return command_122
    when 123  # Control Self Switch
      return command_123
    when 124  # Control Timer
      return command_124
    when 125  # Change Gold
      return command_125
    when 126  # Change Items
      return command_126
    when 127  # Change Weapons
      return command_127
    when 128  # Change Armor
      return command_128
    when 129  # Change Party Member
      return command_129
    when 131  # Change Windowskin
      return command_131
    when 132  # Change Battle BGM
      return command_132
    when 133  # Change Battle End ME
      return command_133
    when 134  # Change Save Access
      return command_134
    when 135  # Change Menu Access
      return command_135
    when 136  # Change Encounter
      return command_136
    when 201  # Transfer Player
      return command_201
    when 202  # Set Event Location
      return command_202
    when 203  # Scroll Map
      return command_203
    when 204  # Change Map Settings
      return command_204
    when 205  # Change Fog Color Tone
      return command_205
    when 206  # Change Fog Opacity
      return command_206
    when 207  # Show Animation
      return command_207
    when 208  # Change Transparent Flag
      return command_208
    when 209  # Set Move Route
      return command_209
    when 210  # Wait for Move's Completion
      return command_210
    when 221  # Prepare for Transition
      return command_221
    when 222  # Execute Transition
      return command_222
    when 223  # Change Screen Color Tone
      return command_223
    when 224  # Screen Flash
      return command_224
    when 225  # Screen Shake
      return command_225
    when 231  # Show Picture
      return command_231
    when 232  # Move Picture
      return command_232
    when 233  # Rotate Picture
      return command_233
    when 234  # Change Picture Color Tone
      return command_234
    when 235  # Erase Picture
      return command_235
    when 236  # Set Weather Effects
      return command_236
    when 241  # Play BGM
      return command_241
    when 242  # Fade Out BGM
      return command_242
    when 245  # Play BGS
      return command_245
    when 246  # Fade Out BGS
      return command_246
    when 247  # Memorize BGM/BGS
      return command_247
    when 248  # Restore BGM/BGS
      return command_248
    when 249  # Play ME
      return command_249
    when 250  # Play SE
      return command_250
    when 251  # Stop SE
      return command_251
    when 301  # Battle Processing
      return command_301
    when 601  # If Win
      return command_601
    when 602  # If Escape
      return command_602
    when 603  # If Lose
      return command_603
    when 302  # Shop Processing
      return command_302
    when 303  # Name Input Processing
      return command_303
    when 311  # Change HP
      return command_311
    when 312  # Change SP
      return command_312
    when 313  # Change State
      return command_313
    when 314  # Recover All
      return command_314
    when 315  # Change EXP
      return command_315
    when 316  # Change Level
      return command_316
    when 317  # Change Parameters
      return command_317
    when 318  # Change Skills
      return command_318
    when 319  # Change Equipment
      return command_319
    when 320  # Change Actor Name
      return command_320
    when 321  # Change Actor Class
      return command_321
    when 322  # Change Actor Graphic
      return command_322
    when 331  # Change Enemy HP
      return command_331
    when 332  # Change Enemy SP
      return command_332
    when 333  # Change Enemy State
      return command_333
    when 334  # Enemy Recover All
      return command_334
    when 335  # Enemy Appearance
      return command_335
    when 336  # Enemy Transform
      return command_336
    when 337  # Show Battle Animation
      return command_337
    when 338  # Deal Damage
      return command_338
    when 339  # Force Action
      return command_339
    when 340  # Abort Battle
      return command_340
    when 351  # Call Menu Screen
      return command_351
    when 352  # Call Save Screen
      return command_352
    when 353  # Game Over
      return command_353
    when 354  # Return to Title Screen
      return command_354
    when 355  # Script
      return command_355
    else      # Other
      return true
    end
  end
  #
  # End Event
  #
  #
  def command_end
    # Clear list of event commands
    @list = nil
    # If main map event and event ID are valid
    if @main and @event_id > 0
      # Unlock event
      $game_map.events[@event_id].unlock
    end
  end
  #
  # Command Skip
  #
  #
  def command_skip
    # Get indent
    indent = @list[@index].indent
    # Loop
    loop do
      # If next event command is at the same level as indent
      if @list[@index+1].indent == indent
        # Continue
        return true
      end
      # Advance index
      @index += 1
    end
  end
  #
  # Get Character
  #
  # parameter : parameter
  #
  def get_character(parameter)
    # Branch by parameter
    case parameter
    when -1  # player
      return $game_player
    when 0  # this event
      events = $game_map.events
      return events == nil ? nil : events[@event_id]
    else  # specific event
      events = $game_map.events
      return events == nil ? nil : events[parameter]
    end
  end
  #
  # Calculate Operated Value
  #
  # operation    : operation
  # operand_type : operand type (0: invariable 1: variable)
  # operand      : operand (number or variable ID)
  #
  def operate_value(operation, operand_type, operand)
    # Get operand
    if operand_type == 0
      value = operand
    else
      value = $game_variables[operand]
    end
    # Reverse sign of integer if operation is [decrease]
    if operation == 1
      value = -value
    end
    # Return value
    return value
  end
end


#
# This interpreter runs event commands. This class is used within the
# Game_System class and the Game_Event class.
#

class Interpreter
  #
  # Show Text
  #
  #
  def command_101
    # If other text has been set to message_text
    if $game_temp.message_text != nil
      # End
      return false
    end
    # Set message end waiting flag and callback
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # Set message text on first line
    $game_temp.message_text = @list[@index].parameters[0] + "\n"
    line_count = 1
    # Loop
    loop do
      # If next event command text is on the second line or after
      if @list[@index+1].code == 401
        # Add the second line or after to message_text
        $game_temp.message_text += @list[@index+1].parameters[0] + "\n"
        line_count += 1
      # If event command is not on the second line or after
      else
        # If next event command is show choices
        if @list[@index+1].code == 102
          # If choices fit on screen
          if @list[@index+1].parameters[0].size <= 4 - line_count
            # Advance index
            @index += 1
            # Choices setup
            $game_temp.choice_start = line_count
            setup_choices(@list[@index].parameters)
          end
        # If next event command is input number
        elsif @list[@index+1].code == 103
          # If number input window fits on screen
          if line_count < 4
            # Advance index
            @index += 1
            # Number input setup
            $game_temp.num_input_start = line_count
            $game_temp.num_input_variable_id = @list[@index].parameters[0]
            $game_temp.num_input_digits_max = @list[@index].parameters[1]
          end
        end
        # Continue
        return true
      end
      # Advance index
      @index += 1
    end
  end
  #
  # Show Choices
  #
  #
  def command_102
    # If text has been set to message_text
    if $game_temp.message_text != nil
      # End
      return false
    end
    # Set message end waiting flag and callback
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # Choices setup
    $game_temp.message_text = ""
    $game_temp.choice_start = 0
    setup_choices(@parameters)
    # Continue
    return true
  end
  #
  # When [**]
  #
  #
  def command_402
    # If fitting choices are selected
    if @branch[@list[@index].indent] == @parameters[0]
      # Delete branch data
      @branch.delete(@list[@index].indent)
      # Continue
      return true
    end
    # If it doesn't meet the condition: command skip
    return command_skip
  end
  #
  # When Cancel
  #
  #
  def command_403
    # If choices are cancelled
    if @branch[@list[@index].indent] == 4
      # Delete branch data
      @branch.delete(@list[@index].indent)
      # Continue
      return true
    end
    # If it doen't meet the condition: command skip
    return command_skip
  end
  #
  # Input Number
  #
  #
  def command_103
    # If text has been set to message_text
    if $game_temp.message_text != nil
      # End
      return false
    end
    # Set message end waiting flag and callback
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # Number input setup
    $game_temp.message_text = ""
    $game_temp.num_input_start = 0
    $game_temp.num_input_variable_id = @parameters[0]
    $game_temp.num_input_digits_max = @parameters[1]
    # Continue
    return true
  end
  #
  # Change Text Options
  #
  #
  def command_104
    # If message is showing
    if $game_temp.message_window_showing
      # End
      return false
    end
    # Change each option
    $game_system.message_position = @parameters[0]
    $game_system.message_frame = @parameters[1]
    # Continue
    return true
  end
  #
  # Button Input Processing
  #
  #
  def command_105
    # Set variable ID for button input
    @button_input_variable_id = @parameters[0]
    # Advance index
    @index += 1
    # End
    return false
  end
  #
  # Wait
  #
  #
  def command_106
    # Set wait count
    @wait_count = @parameters[0] * 2
    # Continue
    return true
  end
  #
  # Conditional Branch
  #
  #
  def command_111
    # Initialize local variable: result
    result = false
    case @parameters[0]
    when 0  # switch
      result = ($game_switches[@parameters[1]] == (@parameters[2] == 0))
    when 1  # variable
      value1 = $game_variables[@parameters[1]]
      if @parameters[2] == 0
        value2 = @parameters[3]
      else
        value2 = $game_variables[@parameters[3]]
      end
      case @parameters[4]
      when 0  # value1 is equal to value2
        result = (value1 == value2)
      when 1  # value1 is greater than or equal to value2
        result = (value1 >= value2)
      when 2  # value1 is less than or equal to value2
        result = (value1 <= value2)
      when 3  # value1 is greater than value2
        result = (value1 > value2)
      when 4  # value1 is less than value2
        result = (value1 < value2)
      when 5  # value1 is not equal to value2
        result = (value1 != value2)
      end
    when 2  # self switch
      if @event_id > 0
        key = [$game_map.map_id, @event_id, @parameters[1]]
        if @parameters[2] == 0
          result = ($game_self_switches[key] == true)
        else
          result = ($game_self_switches[key] != true)
        end
      end
    when 3  # timer
      if $game_system.timer_working
        sec = $game_system.timer / Graphics.frame_rate
        if @parameters[2] == 0
          result = (sec >= @parameters[1])
        else
          result = (sec <= @parameters[1])
        end
      end
    when 4  # actor
      actor = $game_actors[@parameters[1]]
      if actor != nil
        case @parameters[2]
        when 0  # in party
          result = ($game_party.actors.include?(actor))
        when 1  # name
          result = (actor.name == @parameters[3])
        when 2  # skill
          result = (actor.skill_learn?(@parameters[3]))
        when 3  # weapon
          result = (actor.weapon_id == @parameters[3])
        when 4  # armor
          result = (actor.armor1_id == @parameters[3] or
                    actor.armor2_id == @parameters[3] or
                    actor.armor3_id == @parameters[3] or
                    actor.armor4_id == @parameters[3])
        when 5  # state
          result = (actor.state?(@parameters[3]))
        end
      end
    when 5  # enemy
      enemy = $game_troop.enemies[@parameters[1]]
      if enemy != nil
        case @parameters[2]
        when 0  # appear
          result = (enemy.exist?)
        when 1  # state
          result = (enemy.state?(@parameters[3]))
        end
      end
    when 6  # character
      character = get_character(@parameters[1])
      if character != nil
        result = (character.direction == @parameters[2])
      end
    when 7  # gold
      if @parameters[2] == 0
        result = ($game_party.gold >= @parameters[1])
      else
        result = ($game_party.gold <= @parameters[1])
      end
    when 8  # item
      result = ($game_party.item_number(@parameters[1]) > 0)
    when 9  # weapon
      result = ($game_party.weapon_number(@parameters[1]) > 0)
    when 10  # armor
      result = ($game_party.armor_number(@parameters[1]) > 0)
    when 11  # button
      result = (Input.press?(@parameters[1]))
    when 12  # script
      result = eval(@parameters[1])
    end
    # Store determinant results in hash
    @branch[@list[@index].indent] = result
    # If determinant results are true
    if @branch[@list[@index].indent] == true
      # Delete branch data
      @branch.delete(@list[@index].indent)
      # Continue
      return true
    end
    # If it doesn't meet the conditions: command skip
    return command_skip
  end
  #
  # Else
  #
  #
  def command_411
    # If determinant results are false
    if @branch[@list[@index].indent] == false
      # Delete branch data
      @branch.delete(@list[@index].indent)
      # Continue
      return true
    end
    # If it doesn't meet the conditions: command skip
    return command_skip
  end
  #
  # Loop
  #
  #
  def command_112
    # Continue
    return true
  end
  #
  # Repeat Above
  #
  #
  def command_413
    # Get indent
    indent = @list[@index].indent
    # Loop
    loop do
      # Return index
      @index -= 1
      # If this event command is the same level as indent
      if @list[@index].indent == indent
        # Continue
        return true
      end
    end
  end
  #
  # Break Loop
  #
  #
  def command_113
    # Get indent
    indent = @list[@index].indent
    # Copy index to temporary variables
    temp_index = @index
    # Loop
    loop do
      # Advance index
      temp_index += 1
      # If a fitting loop was not found
      if temp_index >= @list.size-1
        # Continue
        return true
      end
      # If this event command is [repeat above] and indent is shallow
      if @list[temp_index].code == 413 and @list[temp_index].indent < indent
        # Update index
        @index = temp_index
        # Continue
        return true
      end
    end
  end
  #
  # Exit Event Processing
  #
  #
  def command_115
    # End event
    command_end
    # Continue
    return true
  end
  #
  # Erase Event
  #
  #
  def command_116
    # If event ID is valid
    if @event_id > 0
      # Erase event
      $game_map.events[@event_id].erase
    end
    # Advance index
    @index += 1
    # End
    return false
  end
  #
  # Call Common Event
  #
  #
  def command_117
    # Get common event
    common_event = $data_common_events[@parameters[0]]
    # If common event is valid
    if common_event != nil
      # Make child interpreter
      @child_interpreter = Interpreter.new(@depth + 1)
      @child_interpreter.setup(common_event.list, @event_id)
    end
    # Continue
    return true
  end
  #
  # Label
  #
  #
  def command_118
    # Continue
    return true
  end
  #
  # Jump to Label
  #
  #
  def command_119
    # Get label name
    label_name = @parameters[0]
    # Initialize temporary variables
    temp_index = 0
    # Loop
    loop do
      # If a fitting label was not found
      if temp_index >= @list.size-1
        # Continue
        return true
      end
      # If this event command is a designated label name
      if @list[temp_index].code == 118 and
         @list[temp_index].parameters[0] == label_name
        # Update index
        @index = temp_index
        # Continue
        return true
      end
      # Advance index
      temp_index += 1
    end
  end
end


#
# This interpreter runs event commands. This class is used within the
# Game_System class and the Game_Event class.
#

class Interpreter
  #
  # Control Switches
  #
  #
  def command_121
    # Loop for group control
    for i in @parameters[0] .. @parameters[1]
      # Change switch
      $game_switches[i] = (@parameters[2] == 0)
    end
    # Refresh map
    $game_map.need_refresh = true
    # Continue
    return true
  end
  #
  # Control Variables
  #
  #
  def command_122
    # Initialize value
    value = 0
    # Branch with operand
    case @parameters[3]
    when 0  # invariable
      value = @parameters[4]
    when 1  # variable
      value = $game_variables[@parameters[4]]
    when 2  # random number
      value = @parameters[4] + rand(@parameters[5] - @parameters[4] + 1)
    when 3  # item
      value = $game_party.item_number(@parameters[4])
    when 4  # actor
      actor = $game_actors[@parameters[4]]
      if actor != nil
        case @parameters[5]
        when 0  # level
          value = actor.level
        when 1  # EXP
          value = actor.exp
        when 2  # HP
          value = actor.hp
        when 3  # SP
          value = actor.sp
        when 4  # MaxHP
          value = actor.maxhp
        when 5  # MaxSP
          value = actor.maxsp
        when 6  # strength
          value = actor.str
        when 7  # dexterity
          value = actor.dex
        when 8  # agility
          value = actor.agi
        when 9  # intelligence
          value = actor.int
        when 10  # attack power
          value = actor.atk
        when 11  # physical defense
          value = actor.pdef
        when 12  # magic defense
          value = actor.mdef
        when 13  # evasion
          value = actor.eva
        end
      end
    when 5  # enemy
      enemy = $game_troop.enemies[@parameters[4]]
      if enemy != nil
        case @parameters[5]
        when 0  # HP
          value = enemy.hp
        when 1  # SP
          value = enemy.sp
        when 2  # MaxHP
          value = enemy.maxhp
        when 3  # MaxSP
          value = enemy.maxsp
        when 4  # strength
          value = enemy.str
        when 5  # dexterity
          value = enemy.dex
        when 6  # agility
          value = enemy.agi
        when 7  # intelligence
          value = enemy.int
        when 8  # attack power
          value = enemy.atk
        when 9  # physical defense
          value = enemy.pdef
        when 10  # magic defense
          value = enemy.mdef
        when 11  # evasion correction
          value = enemy.eva
        end
      end
    when 6  # character
      character = get_character(@parameters[4])
      if character != nil
        case @parameters[5]
        when 0  # x-coordinate
          value = character.x
        when 1  # y-coordinate
          value = character.y
        when 2  # direction
          value = character.direction
        when 3  # screen x-coordinate
          value = character.screen_x
        when 4  # screen y-coordinate
          value = character.screen_y
        when 5  # terrain tag
          value = character.terrain_tag
        end
      end
    when 7  # other
      case @parameters[4]
      when 0  # map ID
        value = $game_map.map_id
      when 1  # number of party members
        value = $game_party.actors.size
      when 2  # gold
        value = $game_party.gold
      when 3  # steps
        value = $game_party.steps
      when 4  # play time
        value = Graphics.frame_count / Graphics.frame_rate
      when 5  # timer
        value = $game_system.timer / Graphics.frame_rate
      when 6  # save count
        value = $game_system.save_count
      end
    end
    # Loop for group control
    for i in @parameters[0] .. @parameters[1]
      # Branch with control
      case @parameters[2]
      when 0  # substitute
        $game_variables[i] = value
      when 1  # add
        $game_variables[i] += value
      when 2  # subtract
        $game_variables[i] -= value
      when 3  # multiply
        $game_variables[i] *= value
      when 4  # divide
        if value != 0
          $game_variables[i] /= value
        end
      when 5  # remainder
        if value != 0
          $game_variables[i] %= value
        end
      end
      # Maximum limit check
      if $game_variables[i] > 99999999
        $game_variables[i] = 99999999
      end
      # Minimum limit check
      if $game_variables[i] < -99999999
        $game_variables[i] = -99999999
      end
    end
    # Refresh map
    $game_map.need_refresh = true
    # Continue
    return true
  end
  #
  # Control Self Switch
  #
  #
  def command_123
    # If event ID is valid
    if @event_id > 0
      # Make a self switch key
      key = [$game_map.map_id, @event_id, @parameters[0]]
      # Change self switches
      $game_self_switches[key] = (@parameters[1] == 0)
    end
    # Refresh map
    $game_map.need_refresh = true
    # Continue
    return true
  end
  #
  # Control Timer
  #
  #
  def command_124
    # If started
    if @parameters[0] == 0
      $game_system.timer = @parameters[1] * Graphics.frame_rate
      $game_system.timer_working = true
    end
    # If stopped
    if @parameters[0] == 1
      $game_system.timer_working = false
    end
    # Continue
    return true
  end
  #
  # Change Gold
  #
  #
  def command_125
    # Get value to operate
    value = operate_value(@parameters[0], @parameters[1], @parameters[2])
    # Increase / decrease amount of gold
    $game_party.gain_gold(value)
    # Continue
    return true
  end
  #
  # Change Items
  #
  #
  def command_126
    # Get value to operate
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Increase / decrease items
    $game_party.gain_item(@parameters[0], value)
    # Continue
    return true
  end
  #
  # Change Weapons
  #
  #
  def command_127
    # Get value to operate
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Increase / decrease weapons
    $game_party.gain_weapon(@parameters[0], value)
    # Continue
    return true
  end
  #
  # Change Armor
  #
  #
  def command_128
    # Get value to operate
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Increase / decrease armor
    $game_party.gain_armor(@parameters[0], value)
    # Continue
    return true
  end
  #
  # Change Party Member
  #
  #
  def command_129
    # Get actor
    actor = $game_actors[@parameters[0]]
    # If actor is valid
    if actor != nil
      # Branch with control
      if @parameters[1] == 0
        if @parameters[2] == 1
          $game_actors[@parameters[0]].setup(@parameters[0])
        end
        $game_party.add_actor(@parameters[0])
      else
        $game_party.remove_actor(@parameters[0])
      end
    end
    # Continue
    return true
  end
  #
  # Change Windowskin
  #
  #
  def command_131
    # Change windowskin file name
    $game_system.windowskin_name = @parameters[0]
    # Continue
    return true
  end
  #
  # Change Battle BGM
  #
  #
  def command_132
    # Change battle BGM
    $game_system.battle_bgm = @parameters[0]
    # Continue
    return true
  end
  #
  # Change Battle End ME
  #
  #
  def command_133
    # Change battle end ME
    $game_system.battle_end_me = @parameters[0]
    # Continue
    return true
  end
  #
  # Change Save Access
  #
  #
  def command_134
    # Change save access flag
    $game_system.save_disabled = (@parameters[0] == 0)
    # Continue
    return true
  end
  #
  # Change Menu Access
  #
  #
  def command_135
    # Change menu access flag
    $game_system.menu_disabled = (@parameters[0] == 0)
    # Continue
    return true
  end
  #
  # Change Encounter
  #
  #
  def command_136
    # Change encounter flag
    $game_system.encounter_disabled = (@parameters[0] == 0)
    # Make encounter count
    $game_player.make_encounter_count
    # Continue
    return true
  end
end


#
# This interpreter runs event commands. This class is used within the
# Game_System class and the Game_Event class.
#

class Interpreter
  #
  # Transfer Player
  #
  #
  def command_201
    # If in battle
    if $game_temp.in_battle
      # Continue
      return true
    end
    # If transferring player, showing message, or processing transition
    if $game_temp.player_transferring or
       $game_temp.message_window_showing or
       $game_temp.transition_processing
      # End
      return false
    end
    # Set transferring player flag
    $game_temp.player_transferring = true
    # If appointment method is [direct appointment]
    if @parameters[0] == 0
      # Set player move destination
      $game_temp.player_new_map_id = @parameters[1]
      $game_temp.player_new_x = @parameters[2]
      $game_temp.player_new_y = @parameters[3]
      $game_temp.player_new_direction = @parameters[4]
    # If appointment method is [appoint with variables]
    else
      # Set player move destination
      $game_temp.player_new_map_id = $game_variables[@parameters[1]]
      $game_temp.player_new_x = $game_variables[@parameters[2]]
      $game_temp.player_new_y = $game_variables[@parameters[3]]
      $game_temp.player_new_direction = @parameters[4]
    end
    # Advance index
    @index += 1
    # If fade is set
    if @parameters[5] == 0
      # Prepare for transition
      Graphics.freeze
      # Set transition processing flag
      $game_temp.transition_processing = true
      $game_temp.transition_name = ""
    end
    # End
    return false
  end
  #
  # Set Event Location
  #
  #
  def command_202
    # If in battle
    if $game_temp.in_battle
      # Continue
      return true
    end
    # Get character
    character = get_character(@parameters[0])
    # If no character exists
    if character == nil
      # Continue
      return true
    end
    # If appointment method is [direct appointment]
    if @parameters[1] == 0
      # Set character position
      character.moveto(@parameters[2], @parameters[3])
    # If appointment method is [appoint with variables]
    elsif @parameters[1] == 1
      # Set character position
      character.moveto($game_variables[@parameters[2]],
        $game_variables[@parameters[3]])
    # If appointment method is [exchange with another event]
    else
      old_x = character.x
      old_y = character.y
      character2 = get_character(@parameters[2])
      if character2 != nil
        character.moveto(character2.x, character2.y)
        character2.moveto(old_x, old_y)
      end
    end
    # Set character direction
    case @parameters[4]
    when 8  # up
      character.turn_up
    when 6  # right
      character.turn_right
    when 2  # down
      character.turn_down
    when 4  # left
      character.turn_left
    end
    # Continue
    return true
  end
  #
  # Scroll Map
  #
  #
  def command_203
    # If in battle
    if $game_temp.in_battle
      # Continue
      return true
    end
    # If already scrolling
    if $game_map.scrolling?
      # End
      return false
    end
    # Start scroll
    $game_map.start_scroll(@parameters[0], @parameters[1], @parameters[2])
    # Continue
    return true
  end
  #
  # Change Map Settings
  #
  #
  def command_204
    case @parameters[0]
    when 0  # panorama
      $game_map.panorama_name = @parameters[1]
      $game_map.panorama_hue = @parameters[2]
    when 1  # fog
      $game_map.fog_name = @parameters[1]
      $game_map.fog_hue = @parameters[2]
      $game_map.fog_opacity = @parameters[3]
      $game_map.fog_blend_type = @parameters[4]
      $game_map.fog_zoom = @parameters[5]
      $game_map.fog_sx = @parameters[6]
      $game_map.fog_sy = @parameters[7]
    when 2  # battleback
      $game_map.battleback_name = @parameters[1]
      $game_temp.battleback_name = @parameters[1]
    end
    # Continue
    return true
  end
  #
  # Change Fog Color Tone
  #
  #
  def command_205
    # Start color tone change
    $game_map.start_fog_tone_change(@parameters[0], @parameters[1] * 2)
    # Continue
    return true
  end
  #
  # Change Fog Opacity
  #
  #
  def command_206
    # Start opacity level change
    $game_map.start_fog_opacity_change(@parameters[0], @parameters[1] * 2)
    # Continue
    return true
  end
  #
  # Show Animation
  #
  #
  def command_207
    # Get character
    character = get_character(@parameters[0])
    # If no character exists
    if character == nil
      # Continue
      return true
    end
    # Set animation ID
    character.animation_id = @parameters[1]
    # Continue
    return true
  end
  #
  # Change Transparent Flag
  #
  #
  def command_208
    # Change player transparent flag
    $game_player.transparent = (@parameters[0] == 0)
    # Continue
    return true
  end
  #
  # Set Move Route
  #
  #
  def command_209
    # Get character
    character = get_character(@parameters[0])
    # If no character exists
    if character == nil
      # Continue
      return true
    end
    # Force move route
    character.force_move_route(@parameters[1])
    # Continue
    return true
  end
  #
  # Wait for Move's Completion
  #
  #
  def command_210
    # If not in battle
    unless $game_temp.in_battle
      # Set move route completion waiting flag
      @move_route_waiting = true
    end
    # Continue
    return true
  end
  #
  # Prepare for Transition
  #
  #
  def command_221
    # If showing message window
    if $game_temp.message_window_showing
      # End
      return false
    end
    # Prepare for transition
    Graphics.freeze
    # Continue
    return true
  end
  #
  # Execute Transition
  #
  #
  def command_222
    # If transition processing flag is already set
    if $game_temp.transition_processing
      # End
      return false
    end
    # Set transition processing flag
    $game_temp.transition_processing = true
    $game_temp.transition_name = @parameters[0]
    # Advance index
    @index += 1
    # End
    return false
  end
  #
  # Change Screen Color Tone
  #
  #
  def command_223
    # Start changing color tone
    $game_screen.start_tone_change(@parameters[0], @parameters[1] * 2)
    # Continue
    return true
  end
  #
  # Screen Flash
  #
  #
  def command_224
    # Start flash
    $game_screen.start_flash(@parameters[0], @parameters[1] * 2)
    # Continue
    return true
  end
  #
  # Screen Shake
  #
  #
  def command_225
    # Start shake
    $game_screen.start_shake(@parameters[0], @parameters[1],
      @parameters[2] * 2)
    # Continue
    return true
  end
  #
  # Show Picture
  #
  #
  def command_231
    # Get picture number
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # If appointment method is [direct appointment]
    if @parameters[3] == 0
      x = @parameters[4]
      y = @parameters[5]
    # If appointment method is [appoint with variables]
    else
      x = $game_variables[@parameters[4]]
      y = $game_variables[@parameters[5]]
    end
    # Show picture
    $game_screen.pictures[number].show(@parameters[1], @parameters[2],
      x, y, @parameters[6], @parameters[7], @parameters[8], @parameters[9])
    # Continue
    return true
  end
  #
  # Move Picture
  #
  #
  def command_232
    # Get picture number
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # If appointment method is [direct appointment]
    if @parameters[3] == 0
      x = @parameters[4]
      y = @parameters[5]
    # If appointment method is [appoint with variables]
    else
      x = $game_variables[@parameters[4]]
      y = $game_variables[@parameters[5]]
    end
    # Move picture
    $game_screen.pictures[number].move(@parameters[1] * 2, @parameters[2],
      x, y, @parameters[6], @parameters[7], @parameters[8], @parameters[9])
    # Continue
    return true
  end
  #
  # Rotate Picture
  #
  #
  def command_233
    # Get picture number
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # Set rotation speed
    $game_screen.pictures[number].rotate(@parameters[1])
    # Continue
    return true
  end
  #
  # Change Picture Color Tone
  #
  #
  def command_234
    # Get picture number
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # Start changing color tone
    $game_screen.pictures[number].start_tone_change(@parameters[1],
      @parameters[2] * 2)
    # Continue
    return true
  end
  #
  # Erase Picture
  #
  #
  def command_235
    # Get picture number
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # Erase picture
    $game_screen.pictures[number].erase
    # Continue
    return true
  end
  #
  # Set Weather Effects
  #
  #
  def command_236
    # Set Weather Effects
    $game_screen.weather(@parameters[0], @parameters[1], @parameters[2])
    # Continue
    return true
  end
  #
  # Play BGM
  #
  #
  def command_241
    # Play BGM
    $game_system.bgm_play(@parameters[0])
    # Continue
    return true
  end
  #
  # Fade Out BGM
  #
  #
  def command_242
    # Fade out BGM
    $game_system.bgm_fade(@parameters[0])
    # Continue
    return true
  end
  #
  # Play BGS
  #
  #
  def command_245
    # Play BGS
    $game_system.bgs_play(@parameters[0])
    # Continue
    return true
  end
  #
  # Fade Out BGS
  #
  #
  def command_246
    # Fade out BGS
    $game_system.bgs_fade(@parameters[0])
    # Continue
    return true
  end
  #
  # Memorize BGM/BGS
  #
  #
  def command_247
    # Memorize BGM/BGS
    $game_system.bgm_memorize
    $game_system.bgs_memorize
    # Continue
    return true
  end
  #
  # Restore BGM/BGS
  #
  #
  def command_248
    # Restore BGM/BGS
    $game_system.bgm_restore
    $game_system.bgs_restore
    # Continue
    return true
  end
  #
  # Play ME
  #
  #
  def command_249
    # Play ME
    $game_system.me_play(@parameters[0])
    # Continue
    return true
  end
  #
  # Play SE
  #
  #
  def command_250
    # Play SE
    $game_system.se_play(@parameters[0])
    # Continue
    return true
  end
  #
  # Stop SE
  #
  #
  def command_251
    # Stop SE
    Audio.se_stop
    # Continue
    return true
  end
end


#
# This interpreter runs event commands. This class is used within the
# Game_System class and the Game_Event class.
#

class Interpreter
  #
  # Battle Processing
  #
  #
  def command_301
    # If not invalid troops
    if $data_troops[@parameters[0]] != nil
      # Set battle abort flag
      $game_temp.battle_abort = true
      # Set battle calling flag
      $game_temp.battle_calling = true
      $game_temp.battle_troop_id = @parameters[0]
      $game_temp.battle_can_escape = @parameters[1]
      $game_temp.battle_can_lose = @parameters[2]
      # Set callback
      current_indent = @list[@index].indent
      $game_temp.battle_proc = Proc.new { |n| @branch[current_indent] = n }
    end
    # Advance index
    @index += 1
    # End
    return false
  end
  #
  # If Win
  #
  #
  def command_601
    # When battle results = win
    if @branch[@list[@index].indent] == 0
      # Delete branch data
      @branch.delete(@list[@index].indent)
      # Continue
      return true
    end
    # If it doesn't meet conditions: command skip
    return command_skip
  end
  #
  # If Escape
  #
  #
  def command_602
    # If battle results = escape
    if @branch[@list[@index].indent] == 1
      # Delete branch data
      @branch.delete(@list[@index].indent)
      # Continue
      return true
    end
    # If it doesn't meet conditions: command skip
    return command_skip
  end
  #
  # If Lose
  #
  #
  def command_603
    # If battle results = lose
    if @branch[@list[@index].indent] == 2
      # Delete branch data
      @branch.delete(@list[@index].indent)
      # Continue
      return true
    end
    # If it doesn't meet conditions: command skip
    return command_skip
  end
  #
  # Shop Processing
  #
  #
  def command_302
    # Set battle abort flag
    $game_temp.battle_abort = true
    # Set shop calling flag
    $game_temp.shop_calling = true
    # Set goods list on new item
    $game_temp.shop_goods = [@parameters]
    # Loop
    loop do
      # Advance index
      @index += 1
      # If next event command has shop on second line or after
      if @list[@index].code == 605
        # Add goods list to new item
        $game_temp.shop_goods.push(@list[@index].parameters)
      # If event command does not have shop on second line or after
      else
        # End
        return false
      end
    end
  end
  #
  # Name Input Processing
  #
  #
  def command_303
    # If not invalid actors
    if $data_actors[@parameters[0]] != nil
      # Set battle abort flag
      $game_temp.battle_abort = true
      # Set name input calling flag
      $game_temp.name_calling = true
      $game_temp.name_actor_id = @parameters[0]
      $game_temp.name_max_char = @parameters[1]
    end
    # Advance index
    @index += 1
    # End
    return false
  end
  #
  # Change HP
  #
  #
  def command_311
    # Get operate value
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Process with iterator
    iterate_actor(@parameters[0]) do |actor|
      # If HP are not 0
      if actor.hp > 0
        # Change HP (if death is not permitted, make HP 1)
        if @parameters[4] == false and actor.hp + value <= 0
          actor.hp = 1
        else
          actor.hp += value
        end
      end
    end
    # Determine game over
    $game_temp.gameover = $game_party.all_dead?
    # Continue
    return true
  end
  #
  # Change SP
  #
  #
  def command_312
    # Get operate value
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Process with iterator
    iterate_actor(@parameters[0]) do |actor|
      # Change actor SP
      actor.sp += value
    end
    # Continue
    return true
  end
  #
  # Change State
  #
  #
  def command_313
    # Process with iterator
    iterate_actor(@parameters[0]) do |actor|
      # Change state
      if @parameters[1] == 0
        actor.add_state(@parameters[2])
      else
        actor.remove_state(@parameters[2])
      end
    end
    # Continue
    return true
  end
  #
  # Recover All
  #
  #
  def command_314
    # Process with iterator
    iterate_actor(@parameters[0]) do |actor|
      # Recover all for actor
      actor.recover_all
    end
    # Continue
    return true
  end
  #
  # Change EXP
  #
  #
  def command_315
    # Get operate value
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Process with iterator
    iterate_actor(@parameters[0]) do |actor|
      # Change actor EXP
      actor.exp += value
    end
    # Continue
    return true
  end
  #
  # Change Level
  #
  #
  def command_316
    # Get operate value
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Process with iterator
    iterate_actor(@parameters[0]) do |actor|
      # Change actor level
      actor.level += value
    end
    # Continue
    return true
  end
  #
  # Change Parameters
  #
  #
  def command_317
    # Get operate value
    value = operate_value(@parameters[2], @parameters[3], @parameters[4])
    # Get actor
    actor = $game_actors[@parameters[0]]
    # Change parameters
    if actor != nil
      case @parameters[1]
      when 0  # MaxHP
        actor.maxhp += value
      when 1  # MaxSP
        actor.maxsp += value
      when 2  # strength
        actor.str += value
      when 3  # dexterity
        actor.dex += value
      when 4  # agility
        actor.agi += value
      when 5  # intelligence
        actor.int += value
      end
    end
    # Continue
    return true
  end
  #
  # Change Skills
  #
  #
  def command_318
    # Get actor
    actor = $game_actors[@parameters[0]]
    # Change skill
    if actor != nil
      if @parameters[1] == 0
        actor.learn_skill(@parameters[2])
      else
        actor.forget_skill(@parameters[2])
      end
    end
    # Continue
    return true
  end
  #
  # Change Equipment
  #
  #
  def command_319
    # Get actor
    actor = $game_actors[@parameters[0]]
    # Change Equipment
    if actor != nil
      actor.equip(@parameters[1], @parameters[2])
    end
    # Continue
    return true
  end
  #
  # Change Actor Name
  #
  #
  def command_320
    # Get actor
    actor = $game_actors[@parameters[0]]
    # Change name
    if actor != nil
      actor.name = @parameters[1]
    end
    # Continue
    return true
  end
  #
  # Change Actor Class
  #
  #
  def command_321
    # Get actor
    actor = $game_actors[@parameters[0]]
    # Change class
    if actor != nil
      actor.class_id = @parameters[1]
    end
    # Continue
    return true
  end
  #
  # Change Actor Graphic
  #
  #
  def command_322
    # Get actor
    actor = $game_actors[@parameters[0]]
    # Change graphic
    if actor != nil
      actor.set_graphic(@parameters[1], @parameters[2],
        @parameters[3], @parameters[4])
    end
    # Refresh player
    $game_player.refresh
    # Continue
    return true
  end
end


#
# This interpreter runs event commands. This class is used within the
# Game_System class and the Game_Event class.
#

class Interpreter
  #
  # Change Enemy HP
  #
  #
  def command_331
    # Get operate value
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Process with iterator
    iterate_enemy(@parameters[0]) do |enemy|
      # If HP is not 0
      if enemy.hp > 0
        # Change HP (if death is not permitted then change HP to 1)
        if @parameters[4] == false and enemy.hp + value <= 0
          enemy.hp = 1
        else
          enemy.hp += value
        end
      end
    end
    # Continue
    return true
  end
  #
  # Change Enemy SP
  #
  #
  def command_332
    # Get operate value
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Process with iterator
    iterate_enemy(@parameters[0]) do |enemy|
      # Change SP
      enemy.sp += value
    end
    # Continue
    return true
  end
  #
  # Change Enemy State
  #
  #
  def command_333
    # Process with iterator
    iterate_enemy(@parameters[0]) do |enemy|
      # If [regard HP 0] state option is valid
      if $data_states[@parameters[2]].zero_hp
        # Clear immortal flag
        enemy.immortal = false
      end
      # Change
      if @parameters[1] == 0
        enemy.add_state(@parameters[2])
      else
        enemy.remove_state(@parameters[2])
      end
    end
    # Continue
    return true
  end
  #
  # Enemy Recover All
  #
  #
  def command_334
    # Process with iterator
    iterate_enemy(@parameters[0]) do |enemy|
      # Recover all
      enemy.recover_all
    end
    # Continue
    return true
  end
  #
  # Enemy Appearance
  #
  #
  def command_335
    # Get enemy
    enemy = $game_troop.enemies[@parameters[0]]
    # Clear hidden flag
    if enemy != nil
      enemy.hidden = false
    end
    # Continue
    return true
  end
  #
  # Enemy Transform
  #
  #
  def command_336
    # Get enemy
    enemy = $game_troop.enemies[@parameters[0]]
    # Transform processing
    if enemy != nil
      enemy.transform(@parameters[1])
    end
    # Continue
    return true
  end
  #
  # Show Battle Animation
  #
  #
  def command_337
    # Process with iterator
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # If battler exists
      if battler.exist?
        # Set animation ID
        battler.animation_id = @parameters[2]
      end
    end
    # Continue
    return true
  end
  #
  # Deal Damage
  #
  #
  def command_338
    # Get operate value
    value = operate_value(0, @parameters[2], @parameters[3])
    # Process with iterator
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # If battler exists
      if battler.exist?
        # Change HP
        battler.hp -= value
        # If in battle
        if $game_temp.in_battle
          # Set damage
          battler.damage = value
          battler.damage_pop = true
        end
      end
    end
    # Continue
    return true
  end
  #
  # Force Action
  #
  #
  def command_339
    # Ignore if not in battle
    unless $game_temp.in_battle
      return true
    end
    # Ignore if number of turns = 0
    if $game_temp.battle_turn == 0
      return true
    end
    # Process with iterator (For convenience, this process won't be repeated)
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # If battler exists
      if battler.exist?
        # Set action
        battler.current_action.kind = @parameters[2]
        if battler.current_action.kind == 0
          battler.current_action.basic = @parameters[3]
        else
          battler.current_action.skill_id = @parameters[3]
        end
        # Set action target
        if @parameters[4] == -2
          if battler.is_a?(Game_Enemy)
            battler.current_action.decide_last_target_for_enemy
          else
            battler.current_action.decide_last_target_for_actor
          end
        elsif @parameters[4] == -1
          if battler.is_a?(Game_Enemy)
            battler.current_action.decide_random_target_for_enemy
          else
            battler.current_action.decide_random_target_for_actor
          end
        elsif @parameters[4] >= 0
          battler.current_action.target_index = @parameters[4]
        end
        # Set force flag
        battler.current_action.forcing = true
        # If action is valid and [run now]
        if battler.current_action.valid? and @parameters[5] == 1
          # Set battler being forced into action
          $game_temp.forcing_battler = battler
          # Advance index
          @index += 1
          # End
          return false
        end
      end
    end
    # Continue
    return true
  end
  #
  # Abort Battle
  #
  #
  def command_340
    # Set battle abort flag
    $game_temp.battle_abort = true
    # Advance index
    @index += 1
    # End
    return false
  end
  #
  # Call Menu Screen
  #
  #
  def command_351
    # Set battle abort flag
    $game_temp.battle_abort = true
    # Set menu calling flag
    $game_temp.menu_calling = true
    # Advance index
    @index += 1
    # End
    return false
  end
  #
  # Call Save Screen
  #
  #
  def command_352
    # Set battle abort flag
    $game_temp.battle_abort = true
    # Set save calling flag
    $game_temp.save_calling = true
    # Advance index
    @index += 1
    # End
    return false
  end
  #
  # Game Over
  #
  #
  def command_353
    # Set game over flag
    $game_temp.gameover = true
    # End
    return false
  end
  #
  # Return to Title Screen
  #
  #
  def command_354
    # Set return to title screen flag
    $game_temp.to_title = true
    # End
    return false
  end
  #
  # Script
  #
  #
  def command_355
    # Set first line to script
    script = @list[@index].parameters[0] + "\n"
    # Loop
    loop do
      # If next event command is second line of script or after
      if @list[@index+1].code == 655
        # Add second line or after to script
        script += @list[@index+1].parameters[0] + "\n"
      # If event command is not second line or after
      else
        # Abort loop
        break
      end
      # Advance index
      @index += 1
    end
    # Evaluation
    result = eval(script)
    # If return value is false
    if result == false
      # End
      return false
    end
    # Continue
    return true
  end
end
