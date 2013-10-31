#
# This class deals with battlers. It's used as a superclass for the Game_Actor
# and Game_Enemy classes.
#

class Game_Battler
  #
  # Public Instance Variables
  #
  #
  attr_reader   :battler_name             # battler file name
  attr_reader   :battler_hue              # battler hue
  attr_reader   :hp                       # HP
  attr_reader   :sp                       # SP
  attr_reader   :states                   # states
  attr_accessor :hidden                   # hidden flag
  attr_accessor :immortal                 # immortal flag
  attr_accessor :damage_pop               # damage display flag
  attr_accessor :damage                   # damage value
  attr_accessor :critical                 # critical flag
  attr_accessor :animation_id             # animation ID
  attr_accessor :animation_hit            # animation hit flag
  attr_accessor :white_flash              # white flash flag
  attr_accessor :blink                    # blink flag
  #
  # Object Initialization
  #
  #
  def initialize
    @battler_name = ""
    @battler_hue = 0
    @hp = 0
    @sp = 0
    @states = []
    @states_turn = {}
    @maxhp_plus = 0
    @maxsp_plus = 0
    @str_plus = 0
    @dex_plus = 0
    @agi_plus = 0
    @int_plus = 0
    @hidden = false
    @immortal = false
    @damage_pop = false
    @damage = nil
    @critical = false
    @animation_id = 0
    @animation_hit = false
    @white_flash = false
    @blink = false
    @current_action = Game_BattleAction.new
  end
  #
  # Get Maximum HP
  #
  #
  def maxhp
    n = [[base_maxhp + @maxhp_plus, 1].max, 999999].min
    for i in @states
      n *= $data_states[i].maxhp_rate / 100.0
    end
    n = [[Integer(n), 1].max, 999999].min
    return n
  end
  #
  # Get Maximum SP
  #
  #
  def maxsp
    n = [[base_maxsp + @maxsp_plus, 0].max, 9999].min
    for i in @states
      n *= $data_states[i].maxsp_rate / 100.0
    end
    n = [[Integer(n), 0].max, 9999].min
    return n
  end
  #
  # Get Strength (STR)
  #
  #
  def str
    n = [[base_str + @str_plus, 1].max, 999].min
    for i in @states
      n *= $data_states[i].str_rate / 100.0
    end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #
  # Get Dexterity (DEX)
  #
  #
  def dex
    n = [[base_dex + @dex_plus, 1].max, 999].min
    for i in @states
      n *= $data_states[i].dex_rate / 100.0
    end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #
  # Get Agility (AGI)
  #
  #
  def agi
    n = [[base_agi + @agi_plus, 1].max, 999].min
    for i in @states
      n *= $data_states[i].agi_rate / 100.0
    end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #
  # Get Intelligence (INT)
  #
  #
  def int
    n = [[base_int + @int_plus, 1].max, 999].min
    for i in @states
      n *= $data_states[i].int_rate / 100.0
    end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #
  # Set Maximum HP
  #
  # maxhp : new maximum HP
  #
  def maxhp=(maxhp)
    @maxhp_plus += maxhp - self.maxhp
    @maxhp_plus = [[@maxhp_plus, -9999].max, 9999].min
    @hp = [@hp, self.maxhp].min
  end
  #
  # Set Maximum SP
  #
  # maxsp : new maximum SP
  #
  def maxsp=(maxsp)
    @maxsp_plus += maxsp - self.maxsp
    @maxsp_plus = [[@maxsp_plus, -9999].max, 9999].min
    @sp = [@sp, self.maxsp].min
  end
  #
  # Set Strength (STR)
  #
  # str : new Strength (STR)
  #
  def str=(str)
    @str_plus += str - self.str
    @str_plus = [[@str_plus, -999].max, 999].min
  end
  #
  # Set Dexterity (DEX)
  #
  # dex : new Dexterity (DEX)
  #
  def dex=(dex)
    @dex_plus += dex - self.dex
    @dex_plus = [[@dex_plus, -999].max, 999].min
  end
  #
  # Set Agility (AGI)
  #
  # agi : new Agility (AGI)
  #
  def agi=(agi)
    @agi_plus += agi - self.agi
    @agi_plus = [[@agi_plus, -999].max, 999].min
  end
  #
  # Set Intelligence (INT)
  #
  # int : new Intelligence (INT)
  #
  def int=(int)
    @int_plus += int - self.int
    @int_plus = [[@int_plus, -999].max, 999].min
  end
  #
  # Get Hit Rate
  #
  #
  def hit
    n = 100
    for i in @states
      n *= $data_states[i].hit_rate / 100.0
    end
    return Integer(n)
  end
  #
  # Get Attack Power
  #
  #
  def atk
    n = base_atk
    for i in @states
      n *= $data_states[i].atk_rate / 100.0
    end
    return Integer(n)
  end
  #
  # Get Physical Defense Power
  #
  #
  def pdef
    n = base_pdef
    for i in @states
      n *= $data_states[i].pdef_rate / 100.0
    end
    return Integer(n)
  end
  #
  # Get Magic Defense Power
  #
  #
  def mdef
    n = base_mdef
    for i in @states
      n *= $data_states[i].mdef_rate / 100.0
    end
    return Integer(n)
  end
  #
  # Get Evasion Correction
  #
  #
  def eva
    n = base_eva
    for i in @states
      n += $data_states[i].eva
    end
    return n
  end
  #
  # Change HP
  #
  # hp : new HP
  #
  def hp=(hp)
    @hp = [[hp, maxhp].min, 0].max
    # add or exclude incapacitation
    for i in 1...$data_states.size
      if $data_states[i].zero_hp
        if self.dead?
          add_state(i)
        else
          remove_state(i)
        end
      end
    end
  end
  #
  # Change SP
  #
  # sp : new SP
  #
  def sp=(sp)
    @sp = [[sp, maxsp].min, 0].max
  end
  #
  # Recover All
  #
  #
  def recover_all
    @hp = maxhp
    @sp = maxsp
    for i in @states.clone
      remove_state(i)
    end
  end
  #
  # Get Current Action
  #
  #
  def current_action
    return @current_action
  end
  #
  # Determine Action Speed
  #
  #
  def make_action_speed
    @current_action.speed = agi + rand(10 + agi / 4)
  end
  #
  # Decide Incapacitation
  #
  #
  def dead?
    return (@hp == 0 and not @immortal)
  end
  #
  # Decide Existance
  #
  #
  def exist?
    return (not @hidden and (@hp > 0 or @immortal))
  end
  #
  # Decide HP 0
  #
  #
  def hp0?
    return (not @hidden and @hp == 0)
  end
  #
  # Decide if Command is Inputable
  #
  #
  def inputable?
    return (not @hidden and restriction <= 1)
  end
  #
  # Decide if Action is Possible
  #
  #
  def movable?
    return (not @hidden and restriction < 4)
  end
  #
  # Decide if Guarding
  #
  #
  def guarding?
    return (@current_action.kind == 0 and @current_action.basic == 1)
  end
  #
  # Decide if Resting
  #
  #
  def resting?
    return (@current_action.kind == 0 and @current_action.basic == 3)
  end
end


#
# This class deals with battlers. It's used as a superclass for the Game_Actor
# and Game_Enemy classes.
#

class Game_Battler
  #
  # Check State
  #
  # state_id : state ID
  #
  def state?(state_id)
    # Return true if the applicable state is added.
    return @states.include?(state_id)
  end
  #
  # Determine if a state is full or not.
  #
  # state_id : state ID
  #
  def state_full?(state_id)
    # Return false if the applicable state is not added.
    unless self.state?(state_id)
      return false
    end
    # Return true if the number of maintenance turns is -1 (auto state).
    if @states_turn[state_id] == -1
      return true
    end
    # Return true if the number of maintenance turns is equal to the
    # lowest number of natural removal turns.
    return @states_turn[state_id] == $data_states[state_id].hold_turn
  end
  #
  # Add State
  #
  # state_id : state ID
  # force    : forcefully added flag (used to deal with auto state)
  #
  def add_state(state_id, force = false)
    # For an ineffective state
    if $data_states[state_id] == nil
      # End Method
      return
    end
    # If not forcefully added
    unless force
      # A state loop already in existance
      for i in @states
        # If a new state is included in the state change (-) of an existing
        # state, and that state is not included in the state change (-) of
        # a new state (example: an attempt to add poison during dead)
        if $data_states[i].minus_state_set.include?(state_id) and
           not $data_states[state_id].minus_state_set.include?(i)
          # End Method
          return
        end
      end
    end
    # If this state is not added
    unless state?(state_id)
      # Add state ID to `@states` array
      @states.push(state_id)
      # If option [regarded as HP 0]is effective
      if $data_states[state_id].zero_hp
        # Change HP to 0
        @hp = 0
      end
      # All state loops
      for i in 1...$data_states.size
        # Dealing with a state change (+)
        if $data_states[state_id].plus_state_set.include?(i)
          add_state(i)
        end
        # Dealing with a state change (-)
        if $data_states[state_id].minus_state_set.include?(i)
          remove_state(i)
        end
      end
      # line change to a large rating order (if value is the same, then a
      # strong restriction order)
      @states.sort! do |a, b|
        state_a = $data_states[a]
        state_b = $data_states[b]
        if state_a.rating > state_b.rating
          -1
        elsif state_a.rating < state_b.rating
          +1
        elsif state_a.restriction > state_b.restriction
          -1
        elsif state_a.restriction < state_b.restriction
          +1
        else
          a <=> b
        end
      end
    end
    # If added forcefully
    if force
      # Set the natural removal's lowest number of turns to -1
      @states_turn[state_id] = -1
    end
    # If not added forcefully
    unless  @states_turn[state_id] == -1
      # Set the natural removal's lowest number of turns
      @states_turn[state_id] = $data_states[state_id].hold_turn
    end
    # If unable to move
    unless movable?
      # Clear action
      @current_action.clear
    end
    # Check the maximum value of HP and SP
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
  end
  #
  # Remove State
  #
  # state_id : state ID
  # force    : forcefully removed flag (used to deal with auto state)
  #
  def remove_state(state_id, force = false)
    # If this state is added
    if state?(state_id)
      # If a forcefully added state is not forcefully removed
      if @states_turn[state_id] == -1 and not force
        # End Method
        return
      end
      # If current HP is at 0 and options are effective [regarded as HP 0]
      if @hp == 0 and $data_states[state_id].zero_hp
        # Determine if there's another state [regarded as HP 0] or not
        zero_hp = false
        for i in @states
          if i != state_id and $data_states[i].zero_hp
            zero_hp = true
          end
        end
        # Change HP to 1 if OK to remove incapacitation.
        if zero_hp == false
          @hp = 1
        end
      end
      # Delete state ID from `@states` and `@states_turn` hash array
      @states.delete(state_id)
      @states_turn.delete(state_id)
    end
    # Check maximum value for HP and SP
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
  end
  #
  # Get State Animation ID
  #
  #
  def state_animation_id
    # If no states are added
    if @states.size == 0
      return 0
    end
    # Return state animation ID with maximum rating
    return $data_states[@states[0]].animation_id
  end
  #
  # Get Restriction
  #
  #
  def restriction
    restriction_max = 0
    # Get maximum restriction from currently added states
    for i in @states
      if $data_states[i].restriction >= restriction_max
        restriction_max = $data_states[i].restriction
      end
    end
    return restriction_max
  end
  #
  # Determine [Can't Get EXP] States
  #
  #
  def cant_get_exp?
    for i in @states
      if $data_states[i].cant_get_exp
        return true
      end
    end
    return false
  end
  #
  # Determine [Can't Evade] States
  #
  #
  def cant_evade?
    for i in @states
      if $data_states[i].cant_evade
        return true
      end
    end
    return false
  end
  #
  # Determine [Slip Damage] States
  #
  #
  def slip_damage?
    for i in @states
      if $data_states[i].slip_damage
        return true
      end
    end
    return false
  end
  #
  # Remove Battle States (called up during end of battle)
  #
  #
  def remove_states_battle
    for i in @states.clone
      if $data_states[i].battle_only
        remove_state(i)
      end
    end
  end
  #
  # Natural Removal of States (called up each turn)
  #
  #
  def remove_states_auto
    for i in @states_turn.keys.clone
      if @states_turn[i] > 0
        @states_turn[i] -= 1
      elsif rand(100) < $data_states[i].auto_release_prob
        remove_state(i)
      end
    end
  end
  #
  # State Removed by Shock (called up each time physical damage occurs)
  #
  #
  def remove_states_shock
    for i in @states.clone
      if rand(100) < $data_states[i].shock_release_prob
        remove_state(i)
      end
    end
  end
  #
  # State Change (+) Application
  #
  # plus_state_set  : State Change (+)
  #
  def states_plus(plus_state_set)
    # Clear effective flag
    effective = false
    # Loop (added state)
    for i in plus_state_set
      # If this state is not guarded
      unless self.state_guard?(i)
        # Set effective flag if this state is not full
        effective |= self.state_full?(i) == false
        # If states offer [no resistance]
        if $data_states[i].nonresistance
          # Set state change flag
          @state_changed = true
          # Add a state
          add_state(i)
        # If this state is not full
        elsif self.state_full?(i) == false
          # Convert state effectiveness to probability,
          # compare to random numbers
          if rand(100) < [0,100,80,60,40,20,0][self.state_ranks[i]]
            # Set state change flag
            @state_changed = true
            # Add a state
            add_state(i)
          end
        end
      end
    end
    # End Method
    return effective
  end
  #
  # Apply State Change (-)
  #
  # minus_state_set : state change (-)
  #
  def states_minus(minus_state_set)
    # Clear effective flag
    effective = false
    # Loop (state to be removed)
    for i in minus_state_set
      # Set effective flag if this state is added
      effective |= self.state?(i)
      # Set a state change flag
      @state_changed = true
      # Remove state
      remove_state(i)
    end
    # End Method
    return effective
  end
end


#
# This class deals with battlers. It's used as a superclass for the Game_Actor
# and Game_Enemy classes.
#

class Game_Battler
  #
  # Determine Usable Skills
  #
  # skill_id : skill ID
  #
  def skill_can_use?(skill_id)
    # If there's not enough SP, the skill cannot be used.
    if $data_skills[skill_id].sp_cost > self.sp
      return false
    end
    # Unusable if incapacitated
    if dead?
      return false
    end
    # If silent, only physical skills can be used
    if $data_skills[skill_id].atk_f == 0 and self.restriction == 1
      return false
    end
    # Get usable time
    occasion = $data_skills[skill_id].occasion
    # If in battle
    if $game_temp.in_battle
      # Usable with [Normal] and [Only Battle]
      return (occasion == 0 or occasion == 1)
    # If not in battle
    else
      # Usable with [Normal] and [Only Menu]
      return (occasion == 0 or occasion == 2)
    end
  end
  #
  # Applying Normal Attack Effects
  #
  # attacker : battler
  #
  def attack_effect(attacker)
    # Clear critical flag
    self.critical = false
    # First hit detection
    hit_result = (rand(100) < attacker.hit)
    # If hit occurs
    if hit_result == true
      # Calculate basic damage
      atk = [attacker.atk - self.pdef / 2, 0].max
      self.damage = atk * (20 + attacker.str) / 20
      # Element correction
      self.damage *= elements_correct(attacker.element_set)
      self.damage /= 100
      # If damage value is strictly positive
      if self.damage > 0
        # Critical correction
        if rand(100) < 4 * attacker.dex / self.agi
          self.damage *= 2
          self.critical = true
        end
        # Guard correction
        if self.guarding?
          self.damage /= 2
        end
      end
      # Dispersion
      if self.damage.abs > 0
        amp = [self.damage.abs * 15 / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
      end
      # Second hit detection
      eva = 8 * self.agi / attacker.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
    end
    # If hit occurs
    if hit_result == true
      # State Removed by Shock
      remove_states_shock
      # Substract damage from HP
      self.hp -= self.damage
      # State change
      @state_changed = false
      states_plus(attacker.plus_state_set)
      states_minus(attacker.minus_state_set)
    # When missing
    else
      # Set damage to "Miss"
      self.damage = "Miss"
      # Clear critical flag
      self.critical = false
    end
    # End Method
    return true
  end
  #
  # Apply Skill Effects
  #
  # user  : the one using skills (battler)
  # skill : skill
  #
  def skill_effect(user, skill)
    # Clear critical flag
    self.critical = false
    # If skill scope is for ally with 1 or more HP, and your own HP = 0,
    # or skill scope is for ally with 0, and your own HP = 1 or more
    if ((skill.scope == 3 or skill.scope == 4) and self.hp == 0) or
       ((skill.scope == 5 or skill.scope == 6) and self.hp >= 1)
      # End Method
      return false
    end
    # Clear effective flag
    effective = false
    # Set effective flag if common ID is effective
    effective |= skill.common_event_id > 0
    # First hit detection
    hit = skill.hit
    if skill.atk_f > 0
      hit *= user.hit / 100
    end
    hit_result = (rand(100) < hit)
    # Set effective flag if skill is uncertain
    effective |= hit < 100
    # If hit occurs
    if hit_result == true
      # Calculate power
      power = skill.power + user.atk * skill.atk_f / 100
      if power > 0
        power -= self.pdef * skill.pdef_f / 200
        power -= self.mdef * skill.mdef_f / 200
        power = [power, 0].max
      end
      # Calculate rate
      rate = 20
      rate += (user.str * skill.str_f / 100)
      rate += (user.dex * skill.dex_f / 100)
      rate += (user.agi * skill.agi_f / 100)
      rate += (user.int * skill.int_f / 100)
      # Calculate basic damage
      self.damage = power * rate / 20
      # Element correction
      self.damage *= elements_correct(skill.element_set)
      self.damage /= 100
      # If damage value is strictly positive
      if self.damage > 0
        # Guard correction
        if self.guarding?
          self.damage /= 2
        end
      end
      # Dispersion
      if skill.variance > 0 and self.damage.abs > 0
        amp = [self.damage.abs * skill.variance / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
      end
      # Second hit detection
      eva = 8 * self.agi / user.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva * skill.eva_f / 100
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
      # Set effective flag if skill is uncertain
      effective |= hit < 100
    end
    # If hit occurs
    if hit_result == true
      # If physical attack has power other than 0
      if skill.power != 0 and skill.atk_f > 0
        # State Removed by Shock
        remove_states_shock
        # Set to effective flag
        effective = true
      end
      # Substract damage from HP
      last_hp = self.hp
      self.hp -= self.damage
      effective |= self.hp != last_hp
      # State change
      @state_changed = false
      effective |= states_plus(skill.plus_state_set)
      effective |= states_minus(skill.minus_state_set)
      # If power is 0
      if skill.power == 0
        # Set damage to an empty string
        self.damage = ""
        # If state is unchanged
        unless @state_changed
          # Set damage to "Miss"
          self.damage = "Miss"
        end
      end
    # If miss occurs
    else
      # Set damage to "Miss"
      self.damage = "Miss"
    end
    # If not in battle
    unless $game_temp.in_battle
      # Set damage to nil
      self.damage = nil
    end
    # End Method
    return effective
  end
  #
  # Application of Item Effects
  #
  # item : item
  #
  def item_effect(item)
    # Clear critical flag
    self.critical = false
    # If item scope is for ally with 1 or more HP, and your own HP = 0,
    # or item scope is for ally with 0 HP, and your own HP = 1 or more
    if ((item.scope == 3 or item.scope == 4) and self.hp == 0) or
       ((item.scope == 5 or item.scope == 6) and self.hp >= 1)
      # End Method
      return false
    end
    # Clear effective flag
    effective = false
    # Set effective flag if common ID is effective
    effective |= item.common_event_id > 0
    # Determine hit
    hit_result = (rand(100) < item.hit)
    # Set effective flag is skill is uncertain
    effective |= item.hit < 100
    # If hit occurs
    if hit_result == true
      # Calculate amount of recovery
      recover_hp = maxhp * item.recover_hp_rate / 100 + item.recover_hp
      recover_sp = maxsp * item.recover_sp_rate / 100 + item.recover_sp
      if recover_hp < 0
        recover_hp += self.pdef * item.pdef_f / 20
        recover_hp += self.mdef * item.mdef_f / 20
        recover_hp = [recover_hp, 0].min
      end
      # Element correction
      recover_hp *= elements_correct(item.element_set)
      recover_hp /= 100
      recover_sp *= elements_correct(item.element_set)
      recover_sp /= 100
      # Dispersion
      if item.variance > 0 and recover_hp.abs > 0
        amp = [recover_hp.abs * item.variance / 100, 1].max
        recover_hp += rand(amp+1) + rand(amp+1) - amp
      end
      if item.variance > 0 and recover_sp.abs > 0
        amp = [recover_sp.abs * item.variance / 100, 1].max
        recover_sp += rand(amp+1) + rand(amp+1) - amp
      end
      # If recovery code is negative
      if recover_hp < 0
        # Guard correction
        if self.guarding?
          recover_hp /= 2
        end
      end
      # Set damage value and reverse HP recovery amount
      self.damage = -recover_hp
      # HP and SP recovery
      last_hp = self.hp
      last_sp = self.sp
      self.hp += recover_hp
      self.sp += recover_sp
      effective |= self.hp != last_hp
      effective |= self.sp != last_sp
      # State change
      @state_changed = false
      effective |= states_plus(item.plus_state_set)
      effective |= states_minus(item.minus_state_set)
      # If parameter value increase is effective
      if item.parameter_type > 0 and item.parameter_points != 0
        # Branch by parameter
        case item.parameter_type
        when 1  # Max HP
          @maxhp_plus += item.parameter_points
        when 2  # Max SP
          @maxsp_plus += item.parameter_points
        when 3  # Strength
          @str_plus += item.parameter_points
        when 4  # Dexterity
          @dex_plus += item.parameter_points
        when 5  # Agility
          @agi_plus += item.parameter_points
        when 6  # Intelligence
          @int_plus += item.parameter_points
        end
        # Set to effective flag
        effective = true
      end
      # If HP recovery rate and recovery amount are 0
      if item.recover_hp_rate == 0 and item.recover_hp == 0
        # Set damage to empty string
        self.damage = ""
        # If SP recovery rate / recovery amount are 0, and parameter increase
        # value is ineffective.
        if item.recover_sp_rate == 0 and item.recover_sp == 0 and
           (item.parameter_type == 0 or item.parameter_points == 0)
          # If state is unchanged
          unless @state_changed
            # Set damage to "Miss"
            self.damage = "Miss"
          end
        end
      end
    # If miss occurs
    else
      # Set damage to "Miss"
      self.damage = "Miss"
    end
    # If not in battle
    unless $game_temp.in_battle
      # Set damage to nil
      self.damage = nil
    end
    # End Method
    return effective
  end
  #
  # Application of Slip Damage Effects
  #
  #
  def slip_damage_effect
    # Set damage
    self.damage = self.maxhp / 10
    # Dispersion
    if self.damage.abs > 0
      amp = [self.damage.abs * 15 / 100, 1].max
      self.damage += rand(amp+1) + rand(amp+1) - amp
    end
    # Subtract damage from HP
    self.hp -= self.damage
    # End Method
    return true
  end
  #
  # Calculating Element Correction
  #
  # element_set : element
  #
  def elements_correct(element_set)
    # If not an element
    if element_set == []
      # Return 100
      return 100
    end
    # Return the weakest object among the elements given
    # "element_rate" method is defined by Game_Actor and Game_Enemy classes,
    #
    # which inherit from this class.
    weakest = -100
    for i in element_set
      weakest = [weakest, self.element_rate(i)].max
    end
    return weakest
  end
end
