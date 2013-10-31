#
# 处理战斗者的类。这个类作为 Game_Actor 类与 Game_Enemy 类的
# 超级类来使用。
#

class Game_Battler
  #
  # 定义实例变量
  #
  #
  attr_reader   :battler_name             # 战斗者 文件名
  attr_reader   :battler_hue              # 战斗者 色相
  attr_reader   :hp                       # HP
  attr_reader   :sp                       # SP
  attr_reader   :states                   # 状态
  attr_accessor :hidden                   # 隐藏标志
  attr_accessor :immortal                 # 不死身标志
  attr_accessor :damage_pop               # 显示伤害标志
  attr_accessor :damage                   # 伤害值
  attr_accessor :critical                 # 会心一击标志
  attr_accessor :animation_id             # 动画 ID
  attr_accessor :animation_hit            # 动画 击中标志
  attr_accessor :white_flash              # 白色屏幕闪烁标志
  attr_accessor :blink                    # 闪烁标志
  #
  # 初始化对像
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
  # 获取 MaxHP
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
  # 获取 MaxSP
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
  # 获取力量
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
  # 获取灵巧
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
  # 获取速度
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
  # 获取魔力
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
  # 设置 MaxHP
  #
  # maxhp : 新的 MaxHP
  #
  def maxhp=(maxhp)
    @maxhp_plus += maxhp - self.maxhp
    @maxhp_plus = [[@maxhp_plus, -9999].max, 9999].min
    @hp = [@hp, self.maxhp].min
  end
  #
  # 设置 MaxSP
  #
  # maxsp : 新的 MaxSP
  #
  def maxsp=(maxsp)
    @maxsp_plus += maxsp - self.maxsp
    @maxsp_plus = [[@maxsp_plus, -9999].max, 9999].min
    @sp = [@sp, self.maxsp].min
  end
  #
  # 设置力量
  #
  # str : 新的力量
  #
  def str=(str)
    @str_plus += str - self.str
    @str_plus = [[@str_plus, -999].max, 999].min
  end
  #
  # 设置灵巧
  #
  # dex : 新的灵巧
  #
  def dex=(dex)
    @dex_plus += dex - self.dex
    @dex_plus = [[@dex_plus, -999].max, 999].min
  end
  #
  # 设置速度
  #
  # agi : 新的速度
  #
  def agi=(agi)
    @agi_plus += agi - self.agi
    @agi_plus = [[@agi_plus, -999].max, 999].min
  end
  #
  # 设置魔力
  #
  # int : 新的魔力
  #
  def int=(int)
    @int_plus += int - self.int
    @int_plus = [[@int_plus, -999].max, 999].min
  end
  #
  # 获取命中率
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
  # 获取攻击力
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
  # 获取物理防御
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
  # 获取魔法防御
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
  # 获取回避修正
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
  # 更改 HP
  #
  # hp : 新的 HP
  #
  def hp=(hp)
    @hp = [[hp, maxhp].min, 0].max
    # 解除附加的战斗不能状态
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
  # 更改 SP
  #
  # sp : 新的 SP
  #
  def sp=(sp)
    @sp = [[sp, maxsp].min, 0].max
  end
  #
  # 全回复
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
  # 获取当前的动作
  #
  #
  def current_action
    return @current_action
  end
  #
  # 确定动作速度
  #
  #
  def make_action_speed
    @current_action.speed = agi + rand(10 + agi / 4)
  end
  #
  # 战斗不能判定
  #
  #
  def dead?
    return (@hp == 0 and not @immortal)
  end
  #
  # 存在判定
  #
  #
  def exist?
    return (not @hidden and (@hp > 0 or @immortal))
  end
  #
  # HP 0 判定
  #
  #
  def hp0?
    return (not @hidden and @hp == 0)
  end
  #
  # 可以输入命令判定
  #
  #
  def inputable?
    return (not @hidden and restriction <= 1)
  end
  #
  # 可以行动判定
  #
  #
  def movable?
    return (not @hidden and restriction < 4)
  end
  #
  # 防御中判定
  #
  #
  def guarding?
    return (@current_action.kind == 0 and @current_action.basic == 1)
  end
  #
  # 休止中判定
  #
  #
  def resting?
    return (@current_action.kind == 0 and @current_action.basic == 3)
  end
end


#
# 处理战斗者的类。这个类作为 Game_Actor 类与 Game_Enemy 类的
# 超级类来使用。
#

class Game_Battler
  #
  # 检查状态
  #
  # state_id : 状态 ID
  #
  def state?(state_id)
    # 如果符合被附加的状态的条件就返回 ture
    return @states.include?(state_id)
  end
  #
  # 判断状态是否为 full
  #
  # state_id : 状态 ID
  #
  def state_full?(state_id)
    # 如果符合被附加的状态的条件就返回 false
    unless self.state?(state_id)
      return false
    end
    # 秩序回合数 -1 (自动状态) 然后返回 true
    if @states_turn[state_id] == -1
      return true
    end
    # 当持续回合数等于自然解除的最低回合数时返回 ture
    return @states_turn[state_id] == $data_states[state_id].hold_turn
  end
  #
  # 附加状态
  #
  # state_id : 状态 ID
  # force    : 强制附加标志 (处理自动状态时使用)
  #
  def add_state(state_id, force = false)
    # 无效状态的情况下
    if $data_states[state_id] == nil
      # 过程结束
      return
    end
    # 无法强制附加的情况下
    unless force
      # 已存在的状态循环
      for i in @states
        # 新的状态和已经存在的状态 (-) 同时包含的情况下、
        # 本状态不包含变化为新状态的状态变化 (-) 
        # (ex : 战斗不能与附加中毒同时存在的场合)
        if $data_states[i].minus_state_set.include?(state_id) and
           not $data_states[state_id].minus_state_set.include?(i)
          # 过程结束
          return
        end
      end
    end
    # 无法附加本状态的情况下
    unless state?(state_id)
      # 状态 ID 追加到 `@states` 序列中
      @states.push(state_id)
      # 选项 [当作 HP 0 的状态] 有效的情况下
      if $data_states[state_id].zero_hp
        # HP 更改为 0
        @hp = 0
      end
      # 所有状态的循环
      for i in 1...$data_states.size
        # 状态变化 (+) 处理
        if $data_states[state_id].plus_state_set.include?(i)
          add_state(i)
        end
        # 状态变化 (-) 处理
        if $data_states[state_id].minus_state_set.include?(i)
          remove_state(i)
        end
      end
      # 按比例大的排序 (值相等的情况下按照强度排序)
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
    # 强制附加的场合
    if force
      # 设置为自然解除的最低回数 -1 (无效)
      @states_turn[state_id] = -1
    end
    # 不能强制附加的场合
    unless  @states_turn[state_id] == -1
      # 设置为自然解除的最低回数
      @states_turn[state_id] = $data_states[state_id].hold_turn
    end
    # 无法行动的场合
    unless movable?
      # 清除行动
      @current_action.clear
    end
    # 检查 HP 及 SP 的最大值
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
  end
  #
  # 解除状态
  #
  # state_id : 状态 ID
  # force    : 强制解除标志 (处理自动状态时使用)
  #
  def remove_state(state_id, force = false)
    # 无法附加本状态的情况下
    if state?(state_id)
      # 被强制附加的状态、并不是强制解除的情况下
      if @states_turn[state_id] == -1 and not force
        # 过程结束
        return
      end
      # 现在的 HP 为 0 当作选项 [当作 HP 0 的状态]有效的场合
      if @hp == 0 and $data_states[state_id].zero_hp
        # 判断是否有另外的 [当作 HP 0 的状态]状态
        zero_hp = false
        for i in @states
          if i != state_id and $data_states[i].zero_hp
            zero_hp = true
          end
        end
        # 如果可以解除战斗不能、将 HP 更改为 1
        if zero_hp == false
          @hp = 1
        end
      end
      # 将状态 ID 从 `@states` 队列和 `@states_turn` hash 中删除 
      @states.delete(state_id)
      @states_turn.delete(state_id)
    end
    # 检查 HP 及 SP 的最大值
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
  end
  #
  # 获取状态的动画 ID
  #
  #
  def state_animation_id
    # 一个状态也没被附加的情况下
    if @states.size == 0
      return 0
    end
    # 返回概率最大的状态动画 ID
    return $data_states[@states[0]].animation_id
  end
  #
  # 获取限制
  #
  #
  def restriction
    restriction_max = 0
    # 从当前附加的状态中获取最大的 restriction 
    for i in @states
      if $data_states[i].restriction >= restriction_max
        restriction_max = $data_states[i].restriction
      end
    end
    return restriction_max
  end
  #
  # 判断状态 [无法获得 EXP]
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
  # 判断状态 [无法回避攻击]
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
  # 判断状态 [连续伤害]
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
  # 解除战斗用状态 (战斗结束时调用)
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
  # 状态自然解除 (回合改变时调用)
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
  # 状态攻击解除 (受到物理伤害时调用)
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
  # 状态变化 (+) 的适用
  #
  # plus_state_set  : 状态变化 (+)
  #
  def states_plus(plus_state_set)
    # 清除有效标志
    effective = false
    # 循环 (附加状态)
    for i in plus_state_set
      # 无法防御本状态的情况下
      unless self.state_guard?(i)
        # 这个状态如果不是 full 的话就设置有效标志
        effective |= self.state_full?(i) == false
        # 状态为 [不能抵抗] 的情况下
        if $data_states[i].nonresistance
          # 设置状态变化标志
          @state_changed = true
          # 附加状态
          add_state(i)
        # 这个状态不是 full 的情况下
        elsif self.state_full?(i) == false
          # 将状态的有效度变换为概率、与随机数比较
          if rand(100) < [0,100,80,60,40,20,0][self.state_ranks[i]]
            # 设置状态变化标志
            @state_changed = true
            # 附加状态
            add_state(i)
          end
        end
      end
    end
    # 过程结束
    return effective
  end
  #
  # 状态变化 (-) 的使用
  #
  # minus_state_set : 状态变化 (-)
  #
  def states_minus(minus_state_set)
    # 清除有效标志
    effective = false
    # 循环 (解除状态)
    for i in minus_state_set
      # 如果这个状态被附加则设置有效标志
      effective |= self.state?(i)
      # 设置状态变化标志
      @state_changed = true
      # 解除状态
      remove_state(i)
    end
    # 过程结束
    return effective
  end
end


#
# 处理战斗者的类。这个类作为 Game_Actor 类与 Game_Enemy 类的
# 超级类来使用。
#

class Game_Battler
  #
  # 可以使用特技的判定
  #
  # skill_id : 特技 ID
  #
  def skill_can_use?(skill_id)
    # SP 不足的情况下不能使用
    if $data_skills[skill_id].sp_cost > self.sp
      return false
    end
    # 战斗不能的情况下不能使用
    if dead?
      return false
    end
    # 沉默状态的情况下、物理特技以外的特技不能使用
    if $data_skills[skill_id].atk_f == 0 and self.restriction == 1
      return false
    end
    # 获取可以使用的时机
    occasion = $data_skills[skill_id].occasion
    # 战斗中的情况下
    if $game_temp.in_battle
      # [平时] 或者是 [战斗中] 可以使用
      return (occasion == 0 or occasion == 1)
    # 不是战斗中的情况下
    else
      # [平时] 或者是 [菜单中] 可以使用
      return (occasion == 0 or occasion == 2)
    end
  end
  #
  # 应用通常攻击效果
  #
  # attacker : 攻击者 (battler)
  #
  def attack_effect(attacker)
    # 清除会心一击标志
    self.critical = false
    # 第一命中判定
    hit_result = (rand(100) < attacker.hit)
    # 命中的情况下
    if hit_result == true
      # 计算基本伤害
      atk = [attacker.atk - self.pdef / 2, 0].max
      self.damage = atk * (20 + attacker.str) / 20
      # 属性修正
      self.damage *= elements_correct(attacker.element_set)
      self.damage /= 100
      # 伤害符号正确的情况下
      if self.damage > 0
        # 会心一击修正
        if rand(100) < 4 * attacker.dex / self.agi
          self.damage *= 2
          self.critical = true
        end
        # 防御修正
        if self.guarding?
          self.damage /= 2
        end
      end
      # 分散
      if self.damage.abs > 0
        amp = [self.damage.abs * 15 / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
      end
      # 第二命中判定
      eva = 8 * self.agi / attacker.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
    end
    # 命中的情况下
    if hit_result == true
      # 状态冲击解除
      remove_states_shock
      # HP 的伤害计算
      self.hp -= self.damage
      # 状态变化
      @state_changed = false
      states_plus(attacker.plus_state_set)
      states_minus(attacker.minus_state_set)
    # Miss 的情况下
    else
      # 伤害设置为 "Miss"
      self.damage = "Miss"
      # 清除会心一击标志
      self.critical = false
    end
    # 过程结束
    return true
  end
  #
  # 应用特技效果
  #
  # user  : 特技的使用者 (battler)
  # skill : 特技
  #
  def skill_effect(user, skill)
    # 清除会心一击标志
    self.critical = false
    # 特技的效果范围是 HP 1 以上的己方、自己的 HP 为 0、
    # 或者特技的效果范围是 HP 0 的己方、自己的 HP 为 1 以上的情况下
    if ((skill.scope == 3 or skill.scope == 4) and self.hp == 0) or
       ((skill.scope == 5 or skill.scope == 6) and self.hp >= 1)
      # 过程结束
      return false
    end
    # 清除有效标志
    effective = false
    # 公共事件 ID 是有效的情况下,设置为有效标志
    effective |= skill.common_event_id > 0
    # 第一命中判定
    hit = skill.hit
    if skill.atk_f > 0
      hit *= user.hit / 100
    end
    hit_result = (rand(100) < hit)
    # 不确定的特技的情况下设置为有效标志
    effective |= hit < 100
    # 命中的情况下
    if hit_result == true
      # 计算威力
      power = skill.power + user.atk * skill.atk_f / 100
      if power > 0
        power -= self.pdef * skill.pdef_f / 200
        power -= self.mdef * skill.mdef_f / 200
        power = [power, 0].max
      end
      # 计算倍率
      rate = 20
      rate += (user.str * skill.str_f / 100)
      rate += (user.dex * skill.dex_f / 100)
      rate += (user.agi * skill.agi_f / 100)
      rate += (user.int * skill.int_f / 100)
      # 计算基本伤害
      self.damage = power * rate / 20
      # 属性修正
      self.damage *= elements_correct(skill.element_set)
      self.damage /= 100
      # 伤害符号正确的情况下
      if self.damage > 0
        # 防御修正
        if self.guarding?
          self.damage /= 2
        end
      end
      # 分散
      if skill.variance > 0 and self.damage.abs > 0
        amp = [self.damage.abs * skill.variance / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
      end
      # 第二命中判定
      eva = 8 * self.agi / user.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva * skill.eva_f / 100
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
      # 不确定的特技的情况下设置为有效标志
      effective |= hit < 100
    end
    # 命中的情况下
    if hit_result == true
      # 威力 0 以外的物理攻击的情况下
      if skill.power != 0 and skill.atk_f > 0
        # 状态冲击解除
        remove_states_shock
        # 设置有效标志
        effective = true
      end
      # HP 的伤害减法运算
      last_hp = self.hp
      self.hp -= self.damage
      effective |= self.hp != last_hp
      # 状态变化
      @state_changed = false
      effective |= states_plus(skill.plus_state_set)
      effective |= states_minus(skill.minus_state_set)
      # 威力为 0 的场合
      if skill.power == 0
        # 伤害设置为空的字串
        self.damage = ""
        # 状态没有变化的情况下
        unless @state_changed
          # 伤害设置为 "Miss"
          self.damage = "Miss"
        end
      end
    # Miss 的情况下
    else
      # 伤害设置为 "Miss"
      self.damage = "Miss"
    end
    # 不在战斗中的情况下
    unless $game_temp.in_battle
      # 伤害设置为 nil
      self.damage = nil
    end
    # 过程结束
    return effective
  end
  #
  # 应用物品效果
  #
  # item : 物品
  #
  def item_effect(item)
    # 清除会心一击标志
    self.critical = false
    # 物品的效果范围是 HP 1 以上的己方、自己的 HP 为 0、
    # 或者物品的效果范围是 HP 0 的己方、自己的 HP 为 1 以上的情况下
    if ((item.scope == 3 or item.scope == 4) and self.hp == 0) or
       ((item.scope == 5 or item.scope == 6) and self.hp >= 1)
      # 过程结束
      return false
    end
    # 清除有效标志
    effective = false
    # 公共事件 ID 是有效的情况下,设置为有效标志
    effective |= item.common_event_id > 0
    # 命中判定
    hit_result = (rand(100) < item.hit)
    # 不确定的特技的情况下设置为有效标志
    effective |= item.hit < 100
    # 命中的情况
    if hit_result == true
      # 计算回复量
      recover_hp = maxhp * item.recover_hp_rate / 100 + item.recover_hp
      recover_sp = maxsp * item.recover_sp_rate / 100 + item.recover_sp
      if recover_hp < 0
        recover_hp += self.pdef * item.pdef_f / 20
        recover_hp += self.mdef * item.mdef_f / 20
        recover_hp = [recover_hp, 0].min
      end
      # 属性修正
      recover_hp *= elements_correct(item.element_set)
      recover_hp /= 100
      recover_sp *= elements_correct(item.element_set)
      recover_sp /= 100
      # 分散
      if item.variance > 0 and recover_hp.abs > 0
        amp = [recover_hp.abs * item.variance / 100, 1].max
        recover_hp += rand(amp+1) + rand(amp+1) - amp
      end
      if item.variance > 0 and recover_sp.abs > 0
        amp = [recover_sp.abs * item.variance / 100, 1].max
        recover_sp += rand(amp+1) + rand(amp+1) - amp
      end
      # 回复量符号为负的情况下
      if recover_hp < 0
        # 防御修正
        if self.guarding?
          recover_hp /= 2
        end
      end
      # HP 回复量符号的反转、设置伤害值
      self.damage = -recover_hp
      # HP 以及 SP 的回复
      last_hp = self.hp
      last_sp = self.sp
      self.hp += recover_hp
      self.sp += recover_sp
      effective |= self.hp != last_hp
      effective |= self.sp != last_sp
      # 状态变化
      @state_changed = false
      effective |= states_plus(item.plus_state_set)
      effective |= states_minus(item.minus_state_set)
      # 能力上升值有效的情况下
      if item.parameter_type > 0 and item.parameter_points != 0
        # 能力值的分支
        case item.parameter_type
        when 1  # MaxHP
          @maxhp_plus += item.parameter_points
        when 2  # MaxSP
          @maxsp_plus += item.parameter_points
        when 3  # 力量
          @str_plus += item.parameter_points
        when 4  # 灵巧
          @dex_plus += item.parameter_points
        when 5  # 速度
          @agi_plus += item.parameter_points
        when 6  # 魔力
          @int_plus += item.parameter_points
        end
        # 设置有效标志
        effective = true
      end
      # HP 回复率与回复量为 0 的情况下
      if item.recover_hp_rate == 0 and item.recover_hp == 0
        # 设置伤害为空的字符串
        self.damage = ""
        # SP 回复率与回复量为 0、能力上升值无效的情况下
        if item.recover_sp_rate == 0 and item.recover_sp == 0 and
           (item.parameter_type == 0 or item.parameter_points == 0)
          # 状态没有变化的情况下
          unless @state_changed
            # 伤害设置为 "Miss"
            self.damage = "Miss"
          end
        end
      end
    # Miss 的情况下
    else
      # 伤害设置为 "Miss"
      self.damage = "Miss"
    end
    # 不在战斗中的情况下
    unless $game_temp.in_battle
      # 伤害设置为 nil
      self.damage = nil
    end
    # 过程结束
    return effective
  end
  #
  # 应用连续伤害效果
  #
  #
  def slip_damage_effect
    # 设置伤害
    self.damage = self.maxhp / 10
    # 分散
    if self.damage.abs > 0
      amp = [self.damage.abs * 15 / 100, 1].max
      self.damage += rand(amp+1) + rand(amp+1) - amp
    end
    # HP 的伤害减法运算
    self.hp -= self.damage
    # 过程结束
    return true
  end
  #
  # 属性修正计算
  #
  # element_set : 属性
  #
  def elements_correct(element_set)
    # 無属性的情况
    if element_set == []
      # 返回 100
      return 100
    end
    # 在被赋予的属性中返回最弱的
    # ※过程 element_rate 是、本类以及继承的 Game_Actor
    # 和 Game_Enemy 类的定义
    weakest = -100
    for i in element_set
      weakest = [weakest, self.element_rate(i)].max
    end
    return weakest
  end
end
