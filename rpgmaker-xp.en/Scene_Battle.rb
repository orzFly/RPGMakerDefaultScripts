#
# This class performs battle screen processing.
#

class Scene_Battle
  #
  # Main Processing
  #
  #
  def main
    # Initialize each kind of temporary battle data
    $game_temp.in_battle = true
    $game_temp.battle_turn = 0
    $game_temp.battle_event_flags.clear
    $game_temp.battle_abort = false
    $game_temp.battle_main_phase = false
    $game_temp.battleback_name = $game_map.battleback_name
    $game_temp.forcing_battler = nil
    # Initialize battle event interpreter
    $game_system.battle_interpreter.setup(nil, 0)
    # Prepare troop
    @troop_id = $game_temp.battle_troop_id
    $game_troop.setup(@troop_id)
    # Make actor command window
    s1 = $data_system.words.attack
    s2 = $data_system.words.skill
    s3 = $data_system.words.guard
    s4 = $data_system.words.item
    @actor_command_window = Window_Command.new(160, [s1, s2, s3, s4])
    @actor_command_window.y = 160
    @actor_command_window.back_opacity = 160
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Make other windows
    @party_command_window = Window_PartyCommand.new
    @help_window = Window_Help.new
    @help_window.back_opacity = 160
    @help_window.visible = false
    @status_window = Window_BattleStatus.new
    @message_window = Window_Message.new
    # Make sprite set
    @spriteset = Spriteset_Battle.new
    # Initialize wait count
    @wait_count = 0
    # Execute transition
    if $data_system.battle_transition == ""
      Graphics.transition(20)
    else
      Graphics.transition(40, "Graphics/Transitions/" +
        $data_system.battle_transition)
    end
    # Start pre-battle phase
    start_phase1
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Refresh map
    $game_map.refresh
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @actor_command_window.dispose
    @party_command_window.dispose
    @help_window.dispose
    @status_window.dispose
    @message_window.dispose
    if @skill_window != nil
      @skill_window.dispose
    end
    if @item_window != nil
      @item_window.dispose
    end
    if @result_window != nil
      @result_window.dispose
    end
    # Dispose of sprite set
    @spriteset.dispose
    # If switching to title screen
    if $scene.is_a?(Scene_Title)
      # Fade out screen
      Graphics.transition
      Graphics.freeze
    end
    # If switching from battle test to any screen other than game over screen
    if $BTEST and not $scene.is_a?(Scene_Gameover)
      $scene = nil
    end
  end
  #
  # Determine Battle Win/Loss Results
  #
  #
  def judge
    # If all dead determinant is true, or number of members in party is 0
    if $game_party.all_dead? or $game_party.actors.size == 0
      # If possible to lose
      if $game_temp.battle_can_lose
        # Return to BGM before battle starts
        $game_system.bgm_play($game_temp.map_bgm)
        # Battle ends
        battle_end(2)
        # Return true
        return true
      end
      # Set game over flag
      $game_temp.gameover = true
      # Return true
      return true
    end
    # Return false if even 1 enemy exists
    for enemy in $game_troop.enemies
      if enemy.exist?
        return false
      end
    end
    # Start after battle phase (win)
    start_phase5
    # Return true
    return true
  end
  #
  # Battle Ends
  #
  # result : results (0:win 1:lose 2:escape)
  #
  def battle_end(result)
    # Clear in battle flag
    $game_temp.in_battle = false
    # Clear entire party actions flag
    $game_party.clear_actions
    # Remove battle states
    for actor in $game_party.actors
      actor.remove_states_battle
    end
    # Clear enemies
    $game_troop.enemies.clear
    # Call battle callback
    if $game_temp.battle_proc != nil
      $game_temp.battle_proc.call(result)
      $game_temp.battle_proc = nil
    end
    # Switch to map screen
    $scene = Scene_Map.new
  end
  #
  # Battle Event Setup
  #
  #
  def setup_battle_event
    # If battle event is running
    if $game_system.battle_interpreter.running?
      return
    end
    # Search for all battle event pages
    for index in 0...$data_troops[@troop_id].pages.size
      # Get event pages
      page = $data_troops[@troop_id].pages[index]
      # Make event conditions possible for reference with c
      c = page.condition
      # Go to next page if no conditions are appointed
      unless c.turn_valid or c.enemy_valid or
             c.actor_valid or c.switch_valid
        next
      end
      # Go to next page if action has been completed
      if $game_temp.battle_event_flags[index]
        next
      end
      # Confirm turn conditions
      if c.turn_valid
        n = $game_temp.battle_turn
        a = c.turn_a
        b = c.turn_b
        if (b == 0 and n != a) or
           (b > 0 and (n < 1 or n < a or n % b != a % b))
          next
        end
      end
      # Confirm enemy conditions
      if c.enemy_valid
        enemy = $game_troop.enemies[c.enemy_index]
        if enemy == nil or enemy.hp * 100.0 / enemy.maxhp > c.enemy_hp
          next
        end
      end
      # Confirm actor conditions
      if c.actor_valid
        actor = $game_actors[c.actor_id]
        if actor == nil or actor.hp * 100.0 / actor.maxhp > c.actor_hp
          next
        end
      end
      # Confirm switch conditions
      if c.switch_valid
        if $game_switches[c.switch_id] == false
          next
        end
      end
      # Set up event
      $game_system.battle_interpreter.setup(page.list, 0)
      # If this page span is [battle] or [turn]
      if page.span <= 1
        # Set action completed flag
        $game_temp.battle_event_flags[index] = true
      end
      return
    end
  end
  #
  # Frame Update
  #
  #
  def update
    # If battle event is running
    if $game_system.battle_interpreter.running?
      # Update interpreter
      $game_system.battle_interpreter.update
      # If a battler which is forcing actions doesn't exist
      if $game_temp.forcing_battler == nil
        # If battle event has finished running
        unless $game_system.battle_interpreter.running?
          # Rerun battle event set up if battle continues
          unless judge
            setup_battle_event
          end
        end
        # If not after battle phase
        if @phase != 5
          # Refresh status window
          @status_window.refresh
        end
      end
    end
    # Update system (timer) and screen
    $game_system.update
    $game_screen.update
    # If timer has reached 0
    if $game_system.timer_working and $game_system.timer == 0
      # Abort battle
      $game_temp.battle_abort = true
    end
    # Update windows
    @help_window.update
    @party_command_window.update
    @actor_command_window.update
    @status_window.update
    @message_window.update
    # Update sprite set
    @spriteset.update
    # If transition is processing
    if $game_temp.transition_processing
      # Clear transition processing flag
      $game_temp.transition_processing = false
      # Execute transition
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
    # If message window is showing
    if $game_temp.message_window_showing
      return
    end
    # If effect is showing
    if @spriteset.effect?
      return
    end
    # If game over
    if $game_temp.gameover
      # Switch to game over screen
      $scene = Scene_Gameover.new
      return
    end
    # If returning to title screen
    if $game_temp.to_title
      # Switch to title screen
      $scene = Scene_Title.new
      return
    end
    # If battle is aborted
    if $game_temp.battle_abort
      # Return to BGM used before battle started
      $game_system.bgm_play($game_temp.map_bgm)
      # Battle ends
      battle_end(1)
      return
    end
    # If waiting
    if @wait_count > 0
      # Decrease wait count
      @wait_count -= 1
      return
    end
    # If battler forcing an action doesn't exist,
    # and battle event is running
    if $game_temp.forcing_battler == nil and
       $game_system.battle_interpreter.running?
      return
    end
    # Branch according to phase
    case @phase
    when 1  # pre-battle phase
      update_phase1
    when 2  # party command phase
      update_phase2
    when 3  # actor command phase
      update_phase3
    when 4  # main phase
      update_phase4
    when 5  # after battle phase
      update_phase5
    end
  end
end


#
# This class performs battle screen processing.
#

class Scene_Battle
  #
  # Start Pre-Battle Phase
  #
  #
  def start_phase1
    # Shift to phase 1
    @phase = 1
    # Clear all party member actions
    $game_party.clear_actions
    # Set up battle event
    setup_battle_event
  end
  #
  # Frame Update (pre-battle phase)
  #
  #
  def update_phase1
    # Determine win/loss situation
    if judge
      # If won or lost: end method
      return
    end
    # Start party command phase
    start_phase2
  end
  #
  # Start Party Command Phase
  #
  #
  def start_phase2
    # Shift to phase 2
    @phase = 2
    # Set actor to non-selecting
    @actor_index = -1
    @active_battler = nil
    # Enable party command window
    @party_command_window.active = true
    @party_command_window.visible = true
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Clear main phase flag
    $game_temp.battle_main_phase = false
    # Clear all party member actions
    $game_party.clear_actions
    # If impossible to input command
    unless $game_party.inputable?
      # Start main phase
      start_phase4
    end
  end
  #
  # Frame Update (party command phase)
  #
  #
  def update_phase2
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Branch by party command window cursor position
      case @party_command_window.index
      when 0  # fight
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Start actor command phase
        start_phase3
      when 1  # escape
        # If it's not possible to escape
        if $game_temp.battle_can_escape == false
          # Play buzzer SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Escape processing
        update_phase2_escape
      end
      return
    end
  end
  #
  # Frame Update (party command phase: escape)
  #
  #
  def update_phase2_escape
    # Calculate enemy agility average
    enemies_agi = 0
    enemies_number = 0
    for enemy in $game_troop.enemies
      if enemy.exist?
        enemies_agi += enemy.agi
        enemies_number += 1
      end
    end
    if enemies_number > 0
      enemies_agi /= enemies_number
    end
    # Calculate actor agility average
    actors_agi = 0
    actors_number = 0
    for actor in $game_party.actors
      if actor.exist?
        actors_agi += actor.agi
        actors_number += 1
      end
    end
    if actors_number > 0
      actors_agi /= actors_number
    end
    # Determine if escape is successful
    success = rand(100) < 50 * actors_agi / enemies_agi
    # If escape is successful
    if success
      # Play escape SE
      $game_system.se_play($data_system.escape_se)
      # Return to BGM before battle started
      $game_system.bgm_play($game_temp.map_bgm)
      # Battle ends
      battle_end(1)
    # If escape is failure
    else
      # Clear all party member actions
      $game_party.clear_actions
      # Start main phase
      start_phase4
    end
  end
  #
  # Start After Battle Phase
  #
  #
  def start_phase5
    # Shift to phase 5
    @phase = 5
    # Play battle end ME
    $game_system.me_play($game_system.battle_end_me)
    # Return to BGM before battle started
    $game_system.bgm_play($game_temp.map_bgm)
    # Initialize EXP, amount of gold, and treasure
    exp = 0
    gold = 0
    treasures = []
    # Loop
    for enemy in $game_troop.enemies
      # If enemy is not hidden
      unless enemy.hidden
        # Add EXP and amount of gold obtained
        exp += enemy.exp
        gold += enemy.gold
        # Determine if treasure appears
        if rand(100) < enemy.treasure_prob
          if enemy.item_id > 0
            treasures.push($data_items[enemy.item_id])
          end
          if enemy.weapon_id > 0
            treasures.push($data_weapons[enemy.weapon_id])
          end
          if enemy.armor_id > 0
            treasures.push($data_armors[enemy.armor_id])
          end
        end
      end
    end
    # Treasure is limited to a maximum of 6 items
    treasures = treasures[0..5]
    # Obtaining EXP
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      if actor.cant_get_exp? == false
        last_level = actor.level
        actor.exp += exp
        if actor.level > last_level
          @status_window.level_up(i)
        end
      end
    end
    # Obtaining gold
    $game_party.gain_gold(gold)
    # Obtaining treasure
    for item in treasures
      case item
      when RPG::Item
        $game_party.gain_item(item.id, 1)
      when RPG::Weapon
        $game_party.gain_weapon(item.id, 1)
      when RPG::Armor
        $game_party.gain_armor(item.id, 1)
      end
    end
    # Make battle result window
    @result_window = Window_BattleResult.new(exp, gold, treasures)
    # Set wait count
    @phase5_wait_count = 100
  end
  #
  # Frame Update (after battle phase)
  #
  #
  def update_phase5
    # If wait count is larger than 0
    if @phase5_wait_count > 0
      # Decrease wait count
      @phase5_wait_count -= 1
      # If wait count reaches 0
      if @phase5_wait_count == 0
        # Show result window
        @result_window.visible = true
        # Clear main phase flag
        $game_temp.battle_main_phase = false
        # Refresh status window
        @status_window.refresh
      end
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Battle ends
      battle_end(0)
    end
  end
end


#
# This class performs battle screen processing.
#

class Scene_Battle
  #
  # Start Actor Command Phase
  #
  #
  def start_phase3
    # Shift to phase 3
    @phase = 3
    # Set actor as unselectable
    @actor_index = -1
    @active_battler = nil
    # Go to command input for next actor
    phase3_next_actor
  end
  #
  # Go to Command Input for Next Actor
  #
  #
  def phase3_next_actor
    # Loop
    begin
      # Actor blink effect OFF
      if @active_battler != nil
        @active_battler.blink = false
      end
      # If last actor
      if @actor_index == $game_party.actors.size-1
        # Start main phase
        start_phase4
        return
      end
      # Advance actor index
      @actor_index += 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    # Once more if actor refuses command input
    end until @active_battler.inputable?
    # Set up actor command window
    phase3_setup_command_window
  end
  #
  # Go to Command Input of Previous Actor
  #
  #
  def phase3_prior_actor
    # Loop
    begin
      # Actor blink effect OFF
      if @active_battler != nil
        @active_battler.blink = false
      end
      # If first actor
      if @actor_index == 0
        # Start party command phase
        start_phase2
        return
      end
      # Return to actor index
      @actor_index -= 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    # Once more if actor refuses command input
    end until @active_battler.inputable?
    # Set up actor command window
    phase3_setup_command_window
  end
  #
  # Actor Command Window Setup
  #
  #
  def phase3_setup_command_window
    # Disable party command window
    @party_command_window.active = false
    @party_command_window.visible = false
    # Enable actor command window
    @actor_command_window.active = true
    @actor_command_window.visible = true
    # Set actor command window position
    @actor_command_window.x = @actor_index * 160
    # Set index to 0
    @actor_command_window.index = 0
  end
  #
  # Frame Update (actor command phase)
  #
  #
  def update_phase3
    # If enemy arrow is enabled
    if @enemy_arrow != nil
      update_phase3_enemy_select
    # If actor arrow is enabled
    elsif @actor_arrow != nil
      update_phase3_actor_select
    # If skill window is enabled
    elsif @skill_window != nil
      update_phase3_skill_select
    # If item window is enabled
    elsif @item_window != nil
      update_phase3_item_select
    # If actor command window is enabled
    elsif @actor_command_window.active
      update_phase3_basic_command
    end
  end
  #
  # Frame Update (actor command phase : basic command)
  #
  #
  def update_phase3_basic_command
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Go to command input for previous actor
      phase3_prior_actor
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Branch by actor command window cursor position
      case @actor_command_window.index
      when 0  # attack
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Set action
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
        # Start enemy selection
        start_enemy_select
      when 1  # skill
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Set action
        @active_battler.current_action.kind = 1
        # Start skill selection
        start_skill_select
      when 2  # guard
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Set action
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 1
        # Go to command input for next actor
        phase3_next_actor
      when 3  # item
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Set action
        @active_battler.current_action.kind = 2
        # Start item selection
        start_item_select
      end
      return
    end
  end
  #
  # Frame Update (actor command phase : skill selection)
  #
  #
  def update_phase3_skill_select
    # Make skill window visible
    @skill_window.visible = true
    # Update skill window
    @skill_window.update
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End skill selection
      end_skill_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Get currently selected data on the skill window
      @skill = @skill_window.skill
      # If it can't be used
      if @skill == nil or not @active_battler.skill_can_use?(@skill.id)
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.skill_id = @skill.id
      # Make skill window invisible
      @skill_window.visible = false
      # If effect scope is single enemy
      if @skill.scope == 1
        # Start enemy selection
        start_enemy_select
      # If effect scope is single ally
      elsif @skill.scope == 3 or @skill.scope == 5
        # Start actor selection
        start_actor_select
      # If effect scope is not single
      else
        # End skill selection
        end_skill_select
        # Go to command input for next actor
        phase3_next_actor
      end
      return
    end
  end
  #
  # Frame Update (actor command phase : item selection)
  #
  #
  def update_phase3_item_select
    # Make item window visible
    @item_window.visible = true
    # Update item window
    @item_window.update
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End item selection
      end_item_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Get currently selected data on the item window
      @item = @item_window.item
      # If it can't be used
      unless $game_party.item_can_use?(@item.id)
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.item_id = @item.id
      # Make item window invisible
      @item_window.visible = false
      # If effect scope is single enemy
      if @item.scope == 1
        # Start enemy selection
        start_enemy_select
      # If effect scope is single ally
      elsif @item.scope == 3 or @item.scope == 5
        # Start actor selection
        start_actor_select
      # If effect scope is not single
      else
        # End item selection
        end_item_select
        # Go to command input for next actor
        phase3_next_actor
      end
      return
    end
  end
  #
  # Frame Updat (actor command phase : enemy selection)
  #
  #
  def update_phase3_enemy_select
    # Update enemy arrow
    @enemy_arrow.update
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End enemy selection
      end_enemy_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.target_index = @enemy_arrow.index
      # End enemy selection
      end_enemy_select
      # If skill window is showing
      if @skill_window != nil
        # End skill selection
        end_skill_select
      end
      # If item window is showing
      if @item_window != nil
        # End item selection
        end_item_select
      end
      # Go to command input for next actor
      phase3_next_actor
    end
  end
  #
  # Frame Update (actor command phase : actor selection)
  #
  #
  def update_phase3_actor_select
    # Update actor arrow
    @actor_arrow.update
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End actor selection
      end_actor_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.target_index = @actor_arrow.index
      # End actor selection
      end_actor_select
      # If skill window is showing
      if @skill_window != nil
        # End skill selection
        end_skill_select
      end
      # If item window is showing
      if @item_window != nil
        # End item selection
        end_item_select
      end
      # Go to command input for next actor
      phase3_next_actor
    end
  end
  #
  # Start Enemy Selection
  #
  #
  def start_enemy_select
    # Make enemy arrow
    @enemy_arrow = Arrow_Enemy.new(@spriteset.viewport1)
    # Associate help window
    @enemy_arrow.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #
  # End Enemy Selection
  #
  #
  def end_enemy_select
    # Dispose of enemy arrow
    @enemy_arrow.dispose
    @enemy_arrow = nil
    # If command is [fight]
    if @actor_command_window.index == 0
      # Enable actor command window
      @actor_command_window.active = true
      @actor_command_window.visible = true
      # Hide help window
      @help_window.visible = false
    end
  end
  #
  # Start Actor Selection
  #
  #
  def start_actor_select
    # Make actor arrow
    @actor_arrow = Arrow_Actor.new(@spriteset.viewport2)
    @actor_arrow.index = @actor_index
    # Associate help window
    @actor_arrow.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #
  # End Actor Selection
  #
  #
  def end_actor_select
    # Dispose of actor arrow
    @actor_arrow.dispose
    @actor_arrow = nil
  end
  #
  # Start Skill Selection
  #
  #
  def start_skill_select
    # Make skill window
    @skill_window = Window_Skill.new(@active_battler)
    # Associate help window
    @skill_window.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #
  # End Skill Selection
  #
  #
  def end_skill_select
    # Dispose of skill window
    @skill_window.dispose
    @skill_window = nil
    # Hide help window
    @help_window.visible = false
    # Enable actor command window
    @actor_command_window.active = true
    @actor_command_window.visible = true
  end
  #
  # Start Item Selection
  #
  #
  def start_item_select
    # Make item window
    @item_window = Window_Item.new
    # Associate help window
    @item_window.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #
  # End Item Selection
  #
  #
  def end_item_select
    # Dispose of item window
    @item_window.dispose
    @item_window = nil
    # Hide help window
    @help_window.visible = false
    # Enable actor command window
    @actor_command_window.active = true
    @actor_command_window.visible = true
  end
end


#
# This class performs battle screen processing.
#

class Scene_Battle
  #
  # Start Main Phase
  #
  #
  def start_phase4
    # Shift to phase 4
    @phase = 4
    # Turn count
    $game_temp.battle_turn += 1
    # Search all battle event pages
    for index in 0...$data_troops[@troop_id].pages.size
      # Get event page
      page = $data_troops[@troop_id].pages[index]
      # If this page span is [turn]
      if page.span == 1
        # Clear action completed flags
        $game_temp.battle_event_flags[index] = false
      end
    end
    # Set actor as unselectable
    @actor_index = -1
    @active_battler = nil
    # Enable party command window
    @party_command_window.active = false
    @party_command_window.visible = false
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Set main phase flag
    $game_temp.battle_main_phase = true
    # Make enemy action
    for enemy in $game_troop.enemies
      enemy.make_action
    end
    # Make action orders
    make_action_orders
    # Shift to step 1
    @phase4_step = 1
  end
  #
  # Make Action Orders
  #
  #
  def make_action_orders
    # Initialize `@action_battlers` array
    @action_battlers = []
    # Add enemy to `@action_battlers` array
    for enemy in $game_troop.enemies
      @action_battlers.push(enemy)
    end
    # Add actor to `@action_battlers` array
    for actor in $game_party.actors
      @action_battlers.push(actor)
    end
    # Decide action speed for all
    for battler in @action_battlers
      battler.make_action_speed
    end
    # Line up action speed in order from greatest to least
    @action_battlers.sort! {|a,b|
      b.current_action.speed - a.current_action.speed }
  end
  #
  # Frame Update (main phase)
  #
  #
  def update_phase4
    case @phase4_step
    when 1
      update_phase4_step1
    when 2
      update_phase4_step2
    when 3
      update_phase4_step3
    when 4
      update_phase4_step4
    when 5
      update_phase4_step5
    when 6
      update_phase4_step6
    end
  end
  #
  # Frame Update (main phase step 1 : action preparation)
  #
  #
  def update_phase4_step1
    # Hide help window
    @help_window.visible = false
    # Determine win/loss
    if judge
      # If won, or if lost : end method
      return
    end
    # If an action forcing battler doesn't exist
    if $game_temp.forcing_battler == nil
      # Set up battle event
      setup_battle_event
      # If battle event is running
      if $game_system.battle_interpreter.running?
        return
      end
    end
    # If an action forcing battler exists
    if $game_temp.forcing_battler != nil
      # Add to head, or move
      @action_battlers.delete($game_temp.forcing_battler)
      @action_battlers.unshift($game_temp.forcing_battler)
    end
    # If no actionless battlers exist (all have performed an action)
    if @action_battlers.size == 0
      # Start party command phase
      start_phase2
      return
    end
    # Initialize animation ID and common event ID
    @animation1_id = 0
    @animation2_id = 0
    @common_event_id = 0
    # Shift from head of actionless battlers
    @active_battler = @action_battlers.shift
    # If already removed from battle
    if @active_battler.index == nil
      return
    end
    # Slip damage
    if @active_battler.hp > 0 and @active_battler.slip_damage?
      @active_battler.slip_damage_effect
      @active_battler.damage_pop = true
    end
    # Natural removal of states
    @active_battler.remove_states_auto
    # Refresh status window
    @status_window.refresh
    # Shift to step 2
    @phase4_step = 2
  end
  #
  # Frame Update (main phase step 2 : start action)
  #
  #
  def update_phase4_step2
    # If not a forcing action
    unless @active_battler.current_action.forcing
      # If restriction is [normal attack enemy] or [normal attack ally]
      if @active_battler.restriction == 2 or @active_battler.restriction == 3
        # Set attack as an action
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
      end
      # If restriction is [cannot perform action]
      if @active_battler.restriction == 4
        # Clear battler being forced into action
        $game_temp.forcing_battler = nil
        # Shift to step 1
        @phase4_step = 1
        return
      end
    end
    # Clear target battlers
    @target_battlers = []
    # Branch according to each action
    case @active_battler.current_action.kind
    when 0  # basic
      make_basic_action_result
    when 1  # skill
      make_skill_action_result
    when 2  # item
      make_item_action_result
    end
    # Shift to step 3
    if @phase4_step == 2
      @phase4_step = 3
    end
  end
  #
  # Make Basic Action Results
  #
  #
  def make_basic_action_result
    # If attack
    if @active_battler.current_action.basic == 0
      # Set anaimation ID
      @animation1_id = @active_battler.animation1_id
      @animation2_id = @active_battler.animation2_id
      # If action battler is enemy
      if @active_battler.is_a?(Game_Enemy)
        if @active_battler.restriction == 3
          target = $game_troop.random_target_enemy
        elsif @active_battler.restriction == 2
          target = $game_party.random_target_actor
        else
          index = @active_battler.current_action.target_index
          target = $game_party.smooth_target_actor(index)
        end
      end
      # If action battler is actor
      if @active_battler.is_a?(Game_Actor)
        if @active_battler.restriction == 3
          target = $game_party.random_target_actor
        elsif @active_battler.restriction == 2
          target = $game_troop.random_target_enemy
        else
          index = @active_battler.current_action.target_index
          target = $game_troop.smooth_target_enemy(index)
        end
      end
      # Set array of targeted battlers
      @target_battlers = [target]
      # Apply normal attack results
      for target in @target_battlers
        target.attack_effect(@active_battler)
      end
      return
    end
    # If guard
    if @active_battler.current_action.basic == 1
      # Display "Guard" in help window
      @help_window.set_text($data_system.words.guard, 1)
      return
    end
    # If escape
    if @active_battler.is_a?(Game_Enemy) and
       @active_battler.current_action.basic == 2
      # Display "Escape" in help window
      @help_window.set_text("Escape", 1)
      # Escape
      @active_battler.escape
      return
    end
    # If doing nothing
    if @active_battler.current_action.basic == 3
      # Clear battler being forced into action
      $game_temp.forcing_battler = nil
      # Shift to step 1
      @phase4_step = 1
      return
    end
  end
  #
  # Set Targeted Battler for Skill or Item
  #
  # scope : effect scope for skill or item
  #
  def set_target_battlers(scope)
    # If battler performing action is enemy
    if @active_battler.is_a?(Game_Enemy)
      # Branch by effect scope
      case scope
      when 1  # single enemy
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 2  # all enemies
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 3  # single ally
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 4  # all allies
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy)
          end
        end
      when 5  # single ally (HP 0) 
        index = @active_battler.current_action.target_index
        enemy = $game_troop.enemies[index]
        if enemy != nil and enemy.hp0?
          @target_battlers.push(enemy)
        end
      when 6  # all allies (HP 0) 
        for enemy in $game_troop.enemies
          if enemy != nil and enemy.hp0?
            @target_battlers.push(enemy)
          end
        end
      when 7  # user
        @target_battlers.push(@active_battler)
      end
    end
    # If battler performing action is actor
    if @active_battler.is_a?(Game_Actor)
      # Branch by effect scope
      case scope
      when 1  # single enemy
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 2  # all enemies
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy)
          end
        end
      when 3  # single ally
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 4  # all allies
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 5  # single ally (HP 0) 
        index = @active_battler.current_action.target_index
        actor = $game_party.actors[index]
        if actor != nil and actor.hp0?
          @target_battlers.push(actor)
        end
      when 6  # all allies (HP 0) 
        for actor in $game_party.actors
          if actor != nil and actor.hp0?
            @target_battlers.push(actor)
          end
        end
      when 7  # user
        @target_battlers.push(@active_battler)
      end
    end
  end
  #
  # Make Skill Action Results
  #
  #
  def make_skill_action_result
    # Get skill
    @skill = $data_skills[@active_battler.current_action.skill_id]
    # If not a forcing action
    unless @active_battler.current_action.forcing
      # If unable to use due to SP running out
      unless @active_battler.skill_can_use?(@skill.id)
        # Clear battler being forced into action
        $game_temp.forcing_battler = nil
        # Shift to step 1
        @phase4_step = 1
        return
      end
    end
    # Use up SP
    @active_battler.sp -= @skill.sp_cost
    # Refresh status window
    @status_window.refresh
    # Show skill name on help window
    @help_window.set_text(@skill.name, 1)
    # Set animation ID
    @animation1_id = @skill.animation1_id
    @animation2_id = @skill.animation2_id
    # Set command event ID
    @common_event_id = @skill.common_event_id
    # Set target battlers
    set_target_battlers(@skill.scope)
    # Apply skill effect
    for target in @target_battlers
      target.skill_effect(@active_battler, @skill)
    end
  end
  #
  # Make Item Action Results
  #
  #
  def make_item_action_result
    # Get item
    @item = $data_items[@active_battler.current_action.item_id]
    # If unable to use due to items running out
    unless $game_party.item_can_use?(@item.id)
      # Shift to step 1
      @phase4_step = 1
      return
    end
    # If consumable
    if @item.consumable
      # Decrease used item by 1
      $game_party.lose_item(@item.id, 1)
    end
    # Display item name on help window
    @help_window.set_text(@item.name, 1)
    # Set animation ID
    @animation1_id = @item.animation1_id
    @animation2_id = @item.animation2_id
    # Set common event ID
    @common_event_id = @item.common_event_id
    # Decide on target
    index = @active_battler.current_action.target_index
    target = $game_party.smooth_target_actor(index)
    # Set targeted battlers
    set_target_battlers(@item.scope)
    # Apply item effect
    for target in @target_battlers
      target.item_effect(@item)
    end
  end
  #
  # Frame Update (main phase step 3 : animation for action performer)
  #
  #
  def update_phase4_step3
    # Animation for action performer (if ID is 0, then white flash)
    if @animation1_id == 0
      @active_battler.white_flash = true
    else
      @active_battler.animation_id = @animation1_id
      @active_battler.animation_hit = true
    end
    # Shift to step 4
    @phase4_step = 4
  end
  #
  # Frame Update (main phase step 4 : animation for target)
  #
  #
  def update_phase4_step4
    # Animation for target
    for target in @target_battlers
      target.animation_id = @animation2_id
      target.animation_hit = (target.damage != "Miss")
    end
    # Animation has at least 8 frames, regardless of its length
    @wait_count = 8
    # Shift to step 5
    @phase4_step = 5
  end
  #
  # Frame Update (main phase step 5 : damage display)
  #
  #
  def update_phase4_step5
    # Hide help window
    @help_window.visible = false
    # Refresh status window
    @status_window.refresh
    # Display damage
    for target in @target_battlers
      if target.damage != nil
        target.damage_pop = true
      end
    end
    # Shift to step 6
    @phase4_step = 6
  end
  #
  # Frame Update (main phase step 6 : refresh)
  #
  #
  def update_phase4_step6
    # Clear battler being forced into action
    $game_temp.forcing_battler = nil
    # If common event ID is valid
    if @common_event_id > 0
      # Set up event
      common_event = $data_common_events[@common_event_id]
      $game_system.battle_interpreter.setup(common_event.list, 0)
    end
    # Shift to step 1
    @phase4_step = 1
  end
end
