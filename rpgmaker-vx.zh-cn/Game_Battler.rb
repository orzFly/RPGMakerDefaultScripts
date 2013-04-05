#
# 处理战斗角色的类。
# 这个类是作为Game_Actor类和Game_Enemy类的超级类而使用。
#

class Game_Battler
  #
  # 定义实例变量
  #
  #
  attr_reader   :battler_name             # 战斗图像 文件名
  attr_reader   :battler_hue              # 战斗图像 色相
  attr_reader   :hp                       # HP
  attr_reader   :mp                       # MP
  attr_reader   :action                   # 战斗行动
  attr_accessor :hidden                   # 隐藏标记
  attr_accessor :immortal                 # 不死身标记
  attr_accessor :animation_id             # 动画 ID
  attr_accessor :animation_mirror         # 动画 左右翻转标记
  attr_accessor :white_flash              # 白色闪烁标记
  attr_accessor :blink                    # 闪烁标记
  attr_accessor :collapse                 # 崩坏标记
  attr_reader   :skipped                  # 行动結果: 跳过标记
  attr_reader   :missed                   # 行动結果: 命中失败标记
  attr_reader   :evaded                   # 行动結果: 回避成功标记
  attr_reader   :critical                 # 行动結果: 会心一击标记
  attr_reader   :absorbed                 # 行动結果: 吸收标记
  attr_reader   :hp_damage                # 行动結果: HP 伤害
  attr_reader   :mp_damage                # 行动結果: MP 伤害
  #
  # 初始化对象
  #
  #
  def initialize
    @battler_name = ""
    @battler_hue = 0
    @hp = 0
    @mp = 0
    @action = Game_BattleAction.new(self)
    @states = []                    # 状态 (ID 的排列)
    @state_turns = {}               # 状态持续回合数 (哈希)
    @hidden = false   
    @immortal = false
    clear_extra_values
    clear_sprite_effects
    clear_action_results
  end
  #
  # 清除能力值的加算值
  #
  #
  def clear_extra_values
    @maxhp_plus = 0
    @maxmp_plus = 0
    @atk_plus = 0
    @def_plus = 0
    @spi_plus = 0
    @agi_plus = 0
  end
  #
  # 清除精灵特效变量
  #
  #
  def clear_sprite_effects
    @animation_id = 0
    @animation_mirror = false
    @white_flash = false
    @blink = false
    @collapse = false
  end
  #
  # 清除保持行动效果用变量
  #
  #
  def clear_action_results
    @skipped = false
    @missed = false
    @evaded = false
    @critical = false
    @absorbed = false
    @hp_damage = 0
    @mp_damage = 0
    @added_states = []              # 附加状态 (ID 的序列)
    @removed_states = []            # 解除状态 (ID 的序列)
    @remained_states = []           # 叠加状态 (ID 的序列)
  end
  #
  # 取得现在状态的对象序列
  #
  #
  def states
    result = []
    for i in @states
      result.push($data_states[i])
    end
    return result
  end
  #
  # 取得紧接着行动的对象附加状态排列
  #
  #
  def added_states
    result = []
    for i in @added_states
      result.push($data_states[i])
    end
    return result
  end
  #
  # 取得之前行动被附加的状态的对象序列
  #
  #
  def removed_states
    result = []
    for i in @removed_states
      result.push($data_states[i])
    end
    return result
  end
  #
  # 取得之前行动叠加状态的对象排列
  #
  # 比如在已经睡眠的角色上再附加睡眠状态的情况等判断用。
  #
  def remained_states
    result = []
    for i in @remained_states
      result.push($data_states[i])
    end
    return result
  end
  #
  # 状态之前行动的影响判断
  #
  #
  def states_active?
    return true unless @added_states.empty?
    return true unless @removed_states.empty?
    return true unless @remained_states.empty?
    return false
  end
  #
  # 取得 MaxHP 的上限
  #
  #
  def maxhp_limit
    return 999999
  end
  #
  # 取得 MaxHP
  #
  #
  def maxhp
    return [[base_maxhp + @maxhp_plus, 1].max, maxhp_limit].min
  end
  #
  # 取得 MaxMP
  #
  #
  def maxmp
    return [[base_maxmp + @maxmp_plus, 0].max, 9999].min
  end
  #
  # 取得攻击力
  #
  #
  def atk
    n = [[base_atk + @atk_plus, 1].max, 999].min
    for state in states do n *= state.atk_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #
  # 取得防御力
  #
  #
  def def
    n = [[base_def + @def_plus, 1].max, 999].min
    for state in states do n *= state.def_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #
  # 取得精神力
  #
  #
  def spi
    n = [[base_spi + @spi_plus, 1].max, 999].min
    for state in states do n *= state.spi_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #
  # 取得敏捷性
  #
  #
  def agi
    n = [[base_agi + @agi_plus, 1].max, 999].min
    for state in states do n *= state.agi_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #
  # 取得选项 [强力防御]
  #
  #
  def super_guard
    return false
  end
  #
  # 取得武器选项 [回合内先制攻击]
  #
  #
  def fast_attack
    return false
  end
  #
  # 取得武器选项 [连续攻击]
  #
  #
  def dual_attack
    return false
  end
  #
  # 取得防具选项 [防止会心一击] 
  #
  #
  def prevent_critical
    return false
  end
  #
  # 取得防具选项 [减半消费 MP] 
  #
  #
  def half_mp_cost
    return false
  end
  #
  # 设定 MaxHP
  #
  # new_maxhp : 新的 MaxHP
  #
  def maxhp=(new_maxhp)
    @maxhp_plus += new_maxhp - self.maxhp
    @maxhp_plus = [[@maxhp_plus, -9999].max, 9999].min
    @hp = [@hp, self.maxhp].min
  end
  #
  # 设定 MaxMP
  #
  # new_maxmp : 新的 MaxMP
  #
  def maxmp=(new_maxmp)
    @maxmp_plus += new_maxmp - self.maxmp
    @maxmp_plus = [[@maxmp_plus, -9999].max, 9999].min
    @mp = [@mp, self.maxmp].min
  end
  #
  # 设定攻击力
  #
  # new_atk : 新的攻击力
  #
  def atk=(new_atk)
    @atk_plus += new_atk - self.atk
    @atk_plus = [[@atk_plus, -999].max, 999].min
  end
  #
  # 设定防御力
  #
  # new_def : 新的防御力
  #
  def def=(new_def)
    @def_plus += new_def - self.def
    @def_plus = [[@def_plus, -999].max, 999].min
  end
  #
  # 设定精神力
  #
  # new_spi : 新的精神力
  #
  def spi=(new_spi)
    @spi_plus += new_spi - self.spi
    @spi_plus = [[@spi_plus, -999].max, 999].min
  end
  #
  # 设定敏捷性
  #
  # agi : 新的敏捷性
  #
  def agi=(new_agi)
    @agi_plus += new_agi - self.agi
    @agi_plus = [[@agi_plus, -999].max, 999].min
  end
  #
  # 变更 HP
  #
  # hp : 新的 HP
  #
  def hp=(hp)
    @hp = [[hp, maxhp].min, 0].max
    if @hp == 0 and not state?(1) and not @immortal
      add_state(1)                # 附加 战斗不能 (状态 1 号) 
      @added_states.push(1)
    elsif @hp > 0 and state?(1)
      remove_state(1)             # 解除 战斗不能 (状态 1 号) 
      @removed_states.push(1)
    end
  end
  #
  # 变更 MP
  #
  # mp : 新的 MP
  #
  def mp=(mp)
    @mp = [[mp, maxmp].min, 0].max
  end
  #
  # 完全恢复
  #
  #
  def recover_all
    @hp = maxhp
    @mp = maxmp
    for i in @states.clone do remove_state(i) end
  end
  #
  # 战斗不能判断
  #
  #
  def dead?
    return (not @hidden and @hp == 0 and not @immortal)
  end
  #
  # 存在判断
  #
  #
  def exist?
    return (not @hidden and not dead?)
  end
  #
  # 可以输入命令判断
  #
  #
  def inputable?
    return (not @hidden and restriction <= 1)
  end
  #
  # 可以行动判断
  #
  #
  def movable?
    return (not @hidden and restriction < 4)
  end
  #
  # 可以回避判断
  #
  #
  def parriable?
    return (not @hidden and restriction < 5)
  end
  #
  # 沉默状态判断
  #
  #
  def silent?
    return (not @hidden and restriction == 1)
  end
  #
  # 暴走状态判断
  #
  #
  def berserker?
    return (not @hidden and restriction == 2)
  end
  #
  # 混乱状态判断
  #
  #
  def confusion?
    return (not @hidden and restriction == 3)
  end
  #
  # 防御中判断
  #
  #
  def guarding?
    return @action.guard?
  end
  #
  # 取得属性修正值
  #
  # element_id : 属性 ID
  #
  def element_rate(element_id)
    return 100
  end
  #
  # 取得状态附加成功率
  #
  #
  def state_probability(state_id)
    return 0
  end
  #
  # 状态无效化判断
  #
  # state_id : 状态 ID
  #
  def state_resist?(state_id)
    return false
  end
  #
  # 取得一般攻击的属性
  #
  #
  def element_set
    return []
  end
  #
  # 取得一般攻击的状态变化（＋）
  #
  #
  def plus_state_set
    return []
  end
  #
  # 取得一般攻击的状态变化（－）
  #
  #
  def minus_state_set
    return []
  end
  #
  # 检查状态
  #
  # state_id : 状态 ID
  # 如果附加符合的状态的话返回true
  #
  def state?(state_id)
    return @states.include?(state_id)
  end
  #
  # 判断状态是否为 full
  #
  # state_id : 状态 ID
  # 如果持续回合数的自然解除与最低回合数相同的话返回true。
  #
  def state_full?(state_id)
    return false unless state?(state_id)
    return @state_turns[state_id] == $data_states[state_id].hold_turn
  end
  #
  # 判断是否无视状态
  #
  # state_id : 状态 ID
  # 满足一下条件的话返回 true
  # ＊现在被附加的状态B的列表中包含打算加入的[解除状态]的新状态A
  # ＊状态B不在那个新的状态A的[解除状态]列表中
  # 这些条件，是符合战斗不能的情况下再附加毒效果的情况。
  # 不过在攻击力下降的时候附加攻击力上升的情况不符合。
  #
  def state_ignore?(state_id)
    for state in states
      if state.state_set.include?(state_id) and
         not $data_states[state_id].state_set.include?(state.id)
        return true
      end
    end
    return false
  end
  #
  # 判断是否抵触状态
  #
  # state_id : 状态 ID
  # 满足一下条件的话返回 true。
  # ＊新的状态的选项[相反效果抵触]为有效
  # ＊现在打算附加的状态，在新状态的[解除状态]名单中含有一个以上。
  # 在攻击力下降的时候附加攻击力上升的情况符合。
  #
  def state_offset?(state_id)
    return false unless $data_states[state_id].offset_by_opposite
    for i in @states
      return true if $data_states[state_id].state_set.include?(i)
    end
    return false
  end
  #
  # 状态的并列
  #
  # 按比例大的排序 (值相等的情况下按照强度排序)
  #
  def sort_states
    @states.sort! do |a, b|
      state_a = $data_states[a]
      state_b = $data_states[b]
      if state_a.priority != state_b.priority
        state_b.priority <=> state_a.priority
      else
        a <=> b
      end
    end
  end
  #
  # 附加状态
  #
  # state_id : 状态 ID
  #
  def add_state(state_id)
    state = $data_states[state_id]        # 取得状态数据
    return if state == nil                # 状态为无效？
    return if state_ignore?(state_id)     # 是否无视状态？
    unless state?(state_id)               # 这个状态没被附加？
      unless state_offset?(state_id)      # 不抵触状态？
        @states.push(state_id)            # 追加@states排列的ID
      end
      if state_id == 1                    # 战斗不能 (状态 1 号) 的话
        @hp = 0                           # HP 变更为 0 
      end
      unless inputable?                   # 无法自由行动的情况
        @action.clear                     # 清除战斗行动
      end
      for i in state.state_set            # 指定[解除状态]
        remove_state(i)                   # 解除实际存在的状态
        @removed_states.delete(i)         # 自动解除部分不显示
      end
      sort_states                         # 按比例大的排序。
    end
    @state_turns[state_id] = state.hold_turn    # 设定自然解除的回合数
  end
  #
  # 解除状态
  #
  # state_id : 状态 ID
  #
  def remove_state(state_id)
    return unless state?(state_id)        # 这个状态没被附加？
    if state_id == 1 and @hp == 0         # 战斗不能 (状态 1 号) 的话
      @hp = 1                             # HP 变更为 0 
    end
    @states.delete(state_id)              # 删除 `@states` 排列的ID
    @state_turns.delete(state_id)         # 删除回合数记忆用哈希
  end
  #
  # 取得限制
  #
  # 取得现在附加状态的最大限制
  #
  def restriction
    restriction_max = 0
    for state in states
      if state.restriction >= restriction_max
        restriction_max = state.restriction
      end
    end
    return restriction_max
  end
  #
  # 状态 [连续伤害] 判断
  #
  #
  def slip_damage?
    for state in states
      return true if state.slip_damage
    end
    return false
  end
  #
  # 状态 [减少命中率] 判断
  #
  #
  def reduce_hit_ratio?
    for state in states
      return true if state.reduce_hit_ratio
    end
    return false
  end
  #
  # 取得最重要的状态持续信息
  #
  #
  def most_important_state_text
    for state in states
      return state.message3 unless state.message3.empty?
    end
    return ""
  end
  #
  # 解除战斗用状态 (战斗结束时候呼叫)
  #
  #
  def remove_states_battle
    for state in states
      remove_state(state.id) if state.battle_only
    end
  end
  #
  # 状态自动解除（每个回合呼叫）
  #
  #
  def remove_states_auto
    clear_action_results
    for i in @state_turns.keys.clone
      if @state_turns[i] > 0
        @state_turns[i] -= 1
      elsif rand(100) < $data_states[i].auto_release_prob
        remove_state(i)
        @removed_states.push(i)
      end
    end
  end
  #
  # 解除伤害状态（每次伤害时呼叫）
  #
  #
  def remove_states_shock
    for state in states
      if state.release_by_damage
        remove_state(state.id)
        @removed_states.push(state.id)
      end
    end
  end
  #
  # 计算特技消费的 MP 
  #
  # skill : 特技
  #
  def calc_mp_cost(skill)
    if half_mp_cost
      return skill.mp_cost / 2
    else
      return skill.mp_cost
    end
  end
  #
  # 可以使用特技的判定
  #
  # skill : 特技
  #
  def skill_can_use?(skill)
    return false unless skill.is_a?(RPG::Skill)
    return false unless movable?
    return false if silent? and skill.spi_f > 0
    return false if calc_mp_cost(skill) > mp
    if $game_temp.in_battle
      return skill.battle_ok?
    else
      return skill.menu_ok?
    end
  end
  #
  # 计算最终命中率
  #
  # user : 攻击者、技能还有道具的使用者
  # obj  : 技能和道具 (一般攻击的情况为 nil)
  #
  def calc_hit(user, obj = nil)
    if obj == nil                           # 一般攻击的情况
      hit = user.hit                        # 取得命中率
      physical = true
    elsif obj.is_a?(RPG::Skill)             # 使用技能的情况
      hit = obj.hit                         # 取得命中率
      physical = obj.physical_attack
    else                                    # 使用道具的情况
      hit = 100                             # 命中率为 100%
      physical = obj.physical_attack
    end
    if physical                             # 物理攻击的情况
      hit /= 4 if user.reduce_hit_ratio?    # 如果使用者是暗属性则为1/4
    end
    return hit
  end
  #
  # 计算最终回避率
  #
  # user : 攻击者、技能还有道具的使用者
  # obj  : 技能和道具 (一般攻击的情况为 nil)
  #
  def calc_eva(user, obj = nil)
    eva = self.eva
    unless obj == nil                       # 无法一般攻击的情况
      eva = 0 unless obj.physical_attack    # 如果是物理攻击以外的情况则为0
    end
    unless parriable?                       # 不可回避的状态的情况
      eva = 0                               # 回避率为 0%
    end
    return eva
  end
  #
  # 计算一般攻击的伤害
  #
  # attacker : 攻击者
  # 结果代入 `@hp_damage` 。
  #
  def make_attack_damage_value(attacker)
    damage = attacker.atk * 4 - self.def * 2        # 基本计算
    damage = 0 if damage < 0                        # 变负则为 0 
    damage *= elements_max_rate(attacker.element_set)   # 属性修正
    damage /= 100
    if damage == 0                                  # 伤害为 0
      damage = rand(2)                              # 有1/2概率为1伤害
    elsif damage > 0                                # 伤害为正数
      @critical = (rand(100) < attacker.cri)        # 会心一击判定
      @critical = false if prevent_critical         # 会心一击防止？
      damage *= 3 if @critical                      # 会心一击修正
    end
    damage = apply_variance(damage, 20)             # 分散
    damage = apply_guard(damage)                    # 防御修正
    @hp_damage = damage                             # HP 伤害
  end
  #
  # 计算技能还有道具的伤害
  #
  # user : 使用者
  # obj  : 技能和道具
  # 结果代入 `@hp_damage` 和 `@mp_damage` 。
  #
  def make_obj_damage_value(user, obj)
    damage = obj.base_damage                        # 取得基本伤害
    if damage > 0                                   # 伤害为正数
      damage += user.atk * 4 * obj.atk_f / 100      # 打击关系度: 使用者
      damage += user.spi * 2 * obj.spi_f / 100      # 精神关系度: 使用者
      unless obj.ignore_defense                     # 防御力无视以外
        damage -= self.def * 2 * obj.atk_f / 100    # 打击关系度: 对象者
        damage -= self.spi * 1 * obj.spi_f / 100    # 精神关系度: 对象者
      end
      damage = 0 if damage < 0                      # 变负则为 0 
    elsif damage < 0                                # 伤害为负数
      damage -= user.atk * 4 * obj.atk_f / 100      # 打击关系度: 使用者
      damage -= user.spi * 2 * obj.spi_f / 100      # 精神关系度: 使用者
    end
    damage *= elements_max_rate(obj.element_set)    # 属性修正
    damage /= 100
    damage = apply_variance(damage, obj.variance)   # 分散
    damage = apply_guard(damage)                    # 防御修正
    if obj.damage_to_mp  
      @mp_damage = damage                           # MP 伤害
    else
      @hp_damage = damage                           # HP 伤害
    end
  end
  #
  # 吸收効果的计算
  #
  # user : 使用者
  # obj  : 技能和道具
  # 呼出先前计算 `@hp_damage` 和 `@mp_damage` 。
  #
  def make_obj_absorb_effect(user, obj)
    if obj.absorb_damage                        # 吸收的情况
      @hp_damage = [self.hp, @hp_damage].min    # HP 伤害范围修正
      @mp_damage = [self.mp, @mp_damage].min    # MP 伤害范围修正
      if @hp_damage > 0 or @mp_damage > 0       # 伤害为正数的场合
        @absorbed = true                        # 吸收标记 ON
      end
    end
  end
  #
  # 计算使用道具的HP恢复量
  #
  #
  def calc_hp_recovery(user, item)
    result = maxhp * item.hp_recovery_rate / 100 + item.hp_recovery
    result *= 2 if user.pharmacology    # 拥有『药的知识』时候为2倍
    return result
  end
  #
  # 计算使用道具的MP恢复量
  #
  #
  def calc_mp_recovery(user, item)
    result = maxmp * item.mp_recovery_rate / 100 + item.mp_recovery
    result *= 2 if user.pharmacology    # 拥有『药的知识』时候为2倍
    return result
  end
  #
  # 取得属性的最大修正值
  #
  # element_set : 属性
  # 返回所在属性中的最有效的修正值
  #
  def elements_max_rate(element_set)
    return 100 if element_set.empty?                # 无属性的时候
    rate_list = []
    for i in element_set
      rate_list.push(element_rate(i))
    end
    return rate_list.max
  end
  #
  # 应用分散度
  #
  # damage   : 伤害
  # variance : 分散度
  #
  def apply_variance(damage, variance)
    if damage != 0                                  # 伤害为0以外的时候
      amp = [damage.abs * variance / 100, 0].max    # 计算分散的幅度
      damage += rand(amp+1) + rand(amp+1) - amp     # 执行分散
    end
    return damage
  end
  #
  # 应用防御修正
  #
  # damage : 伤害
  #
  def apply_guard(damage)
    if damage > 0 and guarding?                     # 防御判定
      damage /= super_guard ? 4 : 2                 # 减少伤害
    end
    return damage
  end
  #
  # 反射伤害
  #
  # user : 使用者
  # 呼叫前先设定 @hp_damage、@mp_damage、@absorbed 。
  #
  def execute_damage(user)
    if @hp_damage > 0           # 伤害为正数
      remove_states_shock       # 解除伤害状态
    end
    self.hp -= @hp_damage
    self.mp -= @mp_damage
    if @absorbed                # 吸收的情况
      user.hp += @hp_damage
      user.mp += @mp_damage
    end
  end
  #
  # 应用状态变化
  #
  # obj : 技能、道具、还有攻击者
  #
  def apply_state_changes(obj)
    plus = obj.plus_state_set             # 取得状态变化(+)
    minus = obj.minus_state_set           # 取得状态变化(-)
    for i in plus                         # 状态变化 (+)
      next if state_resist?(i)            # 存在无效化？
      next if dead?                       # 战斗不能？
      next if i == 1 and @immortal        # 不死身？
      if state?(i)                        # 已经被附加？
        @remained_states.push(i)          # 记录叠加状态
        next
      end
      if rand(100) < state_probability(i) # 概率判定
        add_state(i)                      # 附加状态
        @added_states.push(i)             # 记录附加状态
      end
    end
    for i in minus                        # 状态变化 (-)
      next unless state?(i)               # 存在无效化？
      remove_state(i)                     # 解除状态
      @removed_states.push(i)             # 记录解除状态
    end
    for i in @added_states & @removed_states
      @added_states.delete(i)             # 记录附加和解除两种记录
      @removed_states.delete(i)           # 如果有状态的话两种都删除
    end
  end
  #
  # 可以使用一般攻击判定
  #
  # attacker : 攻击者
  #
  def attack_effective?(attacker)
    if dead?
      return false
    end
    return true
  end
  #
  # 应用一般攻击效果
  #
  # attacker : 攻击者
  #
  def attack_effect(attacker)
    clear_action_results
    unless attack_effective?(attacker)
      @skipped = true
      return
    end
    if rand(100) >= calc_hit(attacker)            # 命中判断
      @missed = true
      return
    end
    if rand(100) < calc_eva(attacker)             # 回避判断
      @evaded = true
      return
    end
    make_attack_damage_value(attacker)            # 计算伤害
    execute_damage(attacker)                      # 反射伤害
    if @hp_damage == 0                            # 判定物理无伤
      return                                    
    end
    apply_state_changes(attacker)                 # 变化状态
  end
  #
  # 应用可以使用特技可能判定
  #
  # user  : 使用者
  # skill : 特技
  #
  def skill_effective?(user, skill)
    if skill.for_dead_friend? != dead?
      return false
    end
    if not $game_temp.in_battle and skill.for_friend?
      return skill_test(user, skill)
    end
    return true
  end
  #
  # 应用特技测试
  #
  # user  : 使用者
  # skill : 特技
  # 判断对象是否完全恢复否则禁止恢复。
  #
  def skill_test(user, skill)
    tester = self.clone
    tester.make_obj_damage_value(user, skill)
    tester.apply_state_changes(skill)
    if tester.hp_damage < 0
      return true if tester.hp < tester.maxhp
    end
    if tester.mp_damage < 0
      return true if tester.mp < tester.maxmp
    end
    return true unless tester.added_states.empty?
    return true unless tester.removed_states.empty?
    return false
  end
  #
  # 技能的效果适用
  #
  # user  : 使用者
  # skill : 技能
  #
  def skill_effect(user, skill)
    clear_action_results
    unless skill_effective?(user, skill)
      @skipped = true
      return
    end
    if rand(100) >= calc_hit(user, skill)         # 命中判断
      @missed = true
      return
    end
    if rand(100) < calc_eva(user, skill)          # 回避判断
      @evaded = true
      return
    end
    make_obj_damage_value(user, skill)            # 计算伤害
    make_obj_absorb_effect(user, skill)           # 计算吸收效果
    execute_damage(user)                          # 反映伤害
    if skill.physical_attack and @hp_damage == 0  # 判断物理无伤
      return                                    
    end
    apply_state_changes(skill)                    # 变化状态
  end
  #
  # 道具的适用可能判定
  #
  # user : 使用者
  # item : 道具
  #
  def item_effective?(user, item)
    if item.for_dead_friend? != dead?
      return false
    end
    if not $game_temp.in_battle and item.for_friend?
      return item_test(user, item)
    end
    return true
  end
  #
  # 道具的效果适用
  #
  # user : 使用者
  # item : 道具
  # 判断对象若没有伤害否则禁止恢复。
  #
  def item_test(user, item)
    tester = self.clone
    tester.make_obj_damage_value(user, item)
    tester.apply_state_changes(item)
    if tester.hp_damage < 0 or tester.calc_hp_recovery(user, item) > 0
      return true if tester.hp < tester.maxhp
    end
    if tester.mp_damage < 0 or tester.calc_mp_recovery(user, item) > 0
      return true if tester.mp < tester.maxmp
    end
    return true unless tester.added_states.empty?
    return true unless tester.removed_states.empty?
    return true if item.parameter_type > 0
    return false
  end
  #
  # 应用道具的效果
  #
  # user : 使用者
  # item : 物品
  #
  def item_effect(user, item)
    clear_action_results
    unless item_effective?(user, item)
      @skipped = true
      return
    end
    if rand(100) >= calc_hit(user, item)          # 命中判断
      @missed = true
      return
    end
    if rand(100) < calc_eva(user, item)           # 回避判断
      @evaded = true
      return
    end
    hp_recovery = calc_hp_recovery(user, item)    # HP 恢复量计算
    mp_recovery = calc_mp_recovery(user, item)    # MP 恢复量计算
    make_obj_damage_value(user, item)             # 计算伤害
    @hp_damage -= hp_recovery                     # 扣除 HP 恢复量
    @mp_damage -= mp_recovery                     # 扣除 MP 恢复量
    make_obj_absorb_effect(user, item)            # 吸收效果判断
    execute_damage(user)                          # 反射伤害
    item_growth_effect(user, item)                # 应用成长效果
    if item.physical_attack and @hp_damage == 0   # 物理无伤判断
      return                                    
    end
    apply_state_changes(item)                     # 变化状态
  end
  #
  # 应用道具的成长效果
  #
  # user : 使用者
  # item : 道具
  #
  def item_growth_effect(user, item)
    if item.parameter_type > 0 and item.parameter_points != 0
      case item.parameter_type
      when 1  # MaxHP
        @maxhp_plus += item.parameter_points
      when 2  # MaxMP
        @maxmp_plus += item.parameter_points
      when 3  # 攻击力
        @atk_plus += item.parameter_points
      when 4  # 防御力
        @def_plus += item.parameter_points
      when 5  # 精神力
        @spi_plus += item.parameter_points
      when 6  # 敏捷性
        @agi_plus += item.parameter_points
      end
    end
  end
  #
  # 应用连续伤害的效果
  #
  #
  def slip_damage_effect
    if slip_damage? and @hp > 0
      @hp_damage = apply_variance(maxhp / 10, 10)
      @hp_damage = @hp - 1 if @hp_damage >= @hp
      self.hp -= @hp_damage
    end
  end
end
