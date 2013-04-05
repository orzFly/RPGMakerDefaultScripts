#
# 处理角色的类。本类在 Game_Actors 类 ($game_actors)
# 的内部使用、请参考Game_Party类($game_party) 。
#

class Game_Actor < Game_Battler
  #
  # 定义实例变量
  #
  #
  attr_reader   :name                     # 名称
  attr_reader   :character_name           # 角色行走图 文件名
  attr_reader   :character_index          # 角色行走图 索引
  attr_reader   :face_name                # 角色脸图 文件名
  attr_reader   :face_index               # 角色脸图 索引
  attr_reader   :class_id                 # 职业 ID
  attr_reader   :weapon_id                # 武器 ID
  attr_reader   :armor1_id                # 盾 ID
  attr_reader   :armor2_id                # 头防具 ID
  attr_reader   :armor3_id                # 身体防具 ID
  attr_reader   :armor4_id                # 装饰品 ID
  attr_reader   :level                    # 等级
  attr_reader   :exp                      # 经验值
  attr_accessor :last_skill_id            # 记忆光标用 : 特技
  #
  # 初始化对像
  #
  # actor_id : 角色ID
  #
  def initialize(actor_id)
    super()
    setup(actor_id)
    @last_skill_id = 0
  end
  #
  # 设置
  #
  # actor_id : 角色 ID
  #
  def setup(actor_id)
    actor = $data_actors[actor_id]
    @actor_id = actor_id
    @name = actor.name
    @character_name = actor.character_name
    @character_index = actor.character_index
    @face_name = actor.face_name
    @face_index = actor.face_index
    @class_id = actor.class_id
    @weapon_id = actor.weapon_id
    @armor1_id = actor.armor1_id
    @armor2_id = actor.armor2_id
    @armor3_id = actor.armor3_id
    @armor4_id = actor.armor4_id
    @level = actor.initial_level
    @exp_list = Array.new(101)
    make_exp_list
    @exp = @exp_list[@level]
    @skills = []
    for i in self.class.learnings
      learn_skill(i.skill_id) if i.level <= @level
    end
    clear_extra_values
    recover_all
  end
  #
  # 角色在否判断
  #
  #
  def actor?
    return true
  end
  #
  # 获取角色 ID 
  #
  #
  def id
    return @actor_id
  end
  #
  # 获取索引
  #
  #
  def index
    return $game_party.members.index(self)
  end
  #
  # 获取角色对象
  #
  #
  def actor
    return $data_actors[@actor_id]
  end
  #
  # 获取职业
  #
  #
  def class
    return $data_classes[@class_id]
  end
  #
  # 获取特技对象序列
  #
  #
  def skills
    result = []
    for i in @skills
      result.push($data_skills[i])
    end
    return result
  end
  #
  # 获取武器对象序列
  #
  #
  def weapons
    result = []
    result.push($data_weapons[@weapon_id])
    if two_swords_style
      result.push($data_weapons[@armor1_id])
    end
    return result
  end
  #
  # 获取防具对象序列
  #
  #
  def armors
    result = []
    unless two_swords_style
      result.push($data_armors[@armor1_id])
    end
    result.push($data_armors[@armor2_id])
    result.push($data_armors[@armor3_id])
    result.push($data_armors[@armor4_id])
    return result
  end
  #
  # 获取装备品对象序列
  #
  #
  def equips
    return weapons + armors
  end
  #
  # 计算经验值
  #
  #
  def make_exp_list
    @exp_list[1] = @exp_list[100] = 0
    m = actor.exp_basis
    n = 0.75 + actor.exp_inflation / 200.0;
    for i in 2..99
      @exp_list[i] = @exp_list[i-1] + Integer(m)
      m *= 1 + n;
      n *= 0.9;
    end
  end
  #
  # 获取属性修正值
  #
  # element_id : 属性 ID
  #
  def element_rate(element_id)
    rank = self.class.element_ranks[element_id]
    result = [0,200,150,100,50,0,-100][rank]
    for armor in armors.compact
      result /= 2 if armor.element_set.include?(element_id)
    end
    for state in states
      result /= 2 if state.element_set.include?(element_id)
    end
    return result
  end
  #
  # 获取状态的成功率
  #
  # state_id : 状态 ID
  #
  def state_probability(state_id)
    if $data_states[state_id].nonresistance
      return 100
    else
      rank = self.class.state_ranks[state_id]
      return [0,100,80,60,40,20,0][rank]
    end
  end
  #
  # 状态无效化
  #
  # state_id : 状态 ID
  #
  def state_resist?(state_id)
    for armor in armors.compact
      return true if armor.state_set.include?(state_id)
    end
    return false
  end
  #
  # 获取普通攻击的属性
  #
  #
  def element_set
    result = []
    if weapons.compact == []
      return [1]                  # 徒手：格斗属性
    end
    for weapon in weapons.compact
      result |= weapon == nil ? [] : weapon.element_set
    end
    return result
  end
  #
  # 获取普通攻击的追加效果 (状态変化) 
  #
  #
  def plus_state_set
    result = []
    for weapon in weapons.compact
      result |= weapon == nil ? [] : weapon.state_set
    end
    return result
  end
  #
  # 获取MaxHP 的上限值
  #
  #
  def maxhp_limit
    return 9999
  end
  #
  # 获取基本 MaxHP
  #
  #
  def base_maxhp
    return actor.parameters[0, @level]
  end
  #
  # 获取基本 MaxMP
  #
  #
  def base_maxmp
    return actor.parameters[1, @level]
  end
  #
  # 获取基本攻击力
  #
  #
  def base_atk
    n = actor.parameters[2, @level]
    for item in equips.compact do n += item.atk end
    return n
  end
  #
  # 获取基本防御力
  #
  #
  def base_def
    n = actor.parameters[3, @level]
    for item in equips.compact do n += item.def end
    return n
  end
  #
  # 获取基本精神力
  #
  #
  def base_spi 
    n = actor.parameters[4, @level]
    for item in equips.compact do n += item.spi end
    return n
  end
  #
  # 获取基本敏捷性
  #
  #
  def base_agi
    n = actor.parameters[5, @level]
    for item in equips.compact do n += item.agi end
    return n
  end
  #
  # 获取命中率
  #
  #
  def hit
    if two_swords_style
      n1 = weapons[0] == nil ? 95 : weapons[0].hit
      n2 = weapons[1] == nil ? 95 : weapons[1].hit
      n = [n1, n2].min
    else
      n = weapons[0] == nil ? 95 : weapons[0].hit
    end
    return n
  end
  #
  # 获取回避率
  #
  #
  def eva
    n = 5
    for item in armors.compact do n += item.eva end
    return n
  end
  #
  # 获取会心一击率
  #
  #
  def cri
    n = 4
    n += 4 if actor.critical_bonus
    for weapon in weapons.compact
      n += 4 if weapon.critical_bonus
    end
    return n
  end
  #
  # 获取瞄准
  #
  #
  def odds
    return 4 - self.class.position
  end
  #
  # 获取选项 [二刀流]
  #
  #
  def two_swords_style
    return actor.two_swords_style
  end
  #
  # 获取选项 [装备固定]
  #
  #
  def fix_equipment
    return actor.fix_equipment
  end
  #
  # 获取选项 [自动战斗]
  #
  #
  def auto_battle
    return actor.auto_battle
  end
  #
  # 获取选项 [強力防御] 
  #
  #
  def super_guard
    return actor.super_guard
  end
  #
  # 获取选项 [药的知识]
  #
  #
  def pharmacology
    return actor.pharmacology
  end
  #
  # 获取武器选项 [回合内先制攻击] 
  #
  #
  def fast_attack
    for weapon in weapons.compact
      return true if weapon.fast_attack
    end
    return false
  end
  #
  # 获取武器选项 [连续攻击]
  #
  #
  def dual_attack
    for weapon in weapons.compact
      return true if weapon.dual_attack
    end
    return false
  end
  #
  # 获取防具选项 [防止会心一击]
  #
  #
  def prevent_critical
    for armor in armors.compact
      return true if armor.prevent_critical
    end
    return false
  end
  #
  # 获取防具选项 [减半消费 MP] 
  #
  #
  def half_mp_cost
    for armor in armors.compact
      return true if armor.half_mp_cost
    end
    return false
  end
  #
  # 获取防具选项 [取得2倍经验值] 
  #
  #
  def double_exp_gain
    for armor in armors.compact
      return true if armor.double_exp_gain
    end
    return false
  end
  #
  # 取得防具选项 [HP 自动恢复]
  #
  #
  def auto_hp_recover
    for armor in armors.compact
      return true if armor.auto_hp_recover
    end
    return false
  end
  #
  # 获取普通攻击的动画ID
  #
  #
  def atk_animation_id
    if two_swords_style
      return weapons[0].animation_id if weapons[0] != nil
      return weapons[1] == nil ? 1 : 0
    else
      return weapons[0] == nil ? 1 : weapons[0].animation_id
    end
  end
  #
  # 获取普通攻击的动画ID(二刀流：武器２)
  #
  #
  def atk_animation_id2
    if two_swords_style
      return weapons[1] == nil ? 0 : weapons[1].animation_id
    else
      return 0
    end
  end
  #
  # 获取 经验 字符串
  #
  #
  def exp_s
    return @exp_list[@level+1] > 0 ? @exp : "-------"
  end
  #
  # 获取下一等级的 经验 字符串
  #
  #
  def next_exp_s
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1] : "-------"
  end
  #
  # 获取离下一等级还需的 经验 字符串
  #
  #
  def next_rest_exp_s
    return @exp_list[@level+1] > 0 ?
      (@exp_list[@level+1] - @exp) : "-------"
  end
  #
  # 变更装备 (用 ID 来指定)
  #
  # equip_type : 装备部位 (0..4)
  # item_id    : 武器 ID or 防具 ID
  # test       : 测试标记（战斗测试，还有装备画面的暂时装备）
  # 用于事件指令，战斗测试的准备。
  #
  def change_equip_by_id(equip_type, item_id, test = false)
    if equip_type == 0 or (equip_type == 1 and two_swords_style)
      change_equip(equip_type, $data_weapons[item_id], test)
    else
      change_equip(equip_type, $data_armors[item_id], test)
    end
  end
  #
  # 变更装备 (用装备来指定)
  #
  # equip_type : 装备部位 (0..4)
  # item       : 武器 or 防具 (nil 表示 解除装备)
  # test       : 测试标记（战斗测试，还有装备画面的暂时装备）
  #
  def change_equip(equip_type, item, test = false)
    last_item = equips[equip_type]
    unless test
      return if $game_party.item_number(item) == 0 if item != nil
      $game_party.gain_item(last_item, 1)
      $game_party.lose_item(item, 1)
    end
    item_id = item == nil ? 0 : item.id
    case equip_type
    when 0  # 武器
      @weapon_id = item_id
      unless two_hands_legal?             # 不是双手装备情况下
        change_equip(1, nil, test)        # 避开副手的装备
      end
    when 1  # 盾
      @armor1_id = item_id
      unless two_hands_legal?             # 不是双手装备情况下
        change_equip(0, nil, test)        # 避开副手的装备
      end
    when 2  # 头
      @armor2_id = item_id
    when 3  # 身体
      @armor3_id = item_id
    when 4  # 装饰品
      @armor4_id = item_id
    end
  end
  #
  # 丢弃装備
  #
  # item : 丢弃的武器 or 防具
  # 武器/防护具 的增减「装备品也包含在内」时使用。
  #
  def discard_equip(item)
    if item.is_a?(RPG::Weapon)
      if @weapon_id == item.id
        @weapon_id = 0
      elsif two_swords_style and @armor1_id == item.id
        @armor1_id = 0
      end
    elsif item.is_a?(RPG::Armor)
      if not two_swords_style and @armor1_id == item.id
        @armor1_id = 0
      elsif @armor2_id == item.id
        @armor2_id = 0
      elsif @armor3_id == item.id
        @armor3_id = 0
      elsif @armor4_id == item.id
        @armor4_id = 0
      end
    end
  end
  #
  # 两手装备合法判定
  #
  #
  def two_hands_legal?
    if weapons[0] != nil and weapons[0].two_handed
      return false if @armor1_id != 0
    end
    if weapons[1] != nil and weapons[1].two_handed
      return false if @weapon_id != 0
    end
    return true
  end
  #
  # 可以装备判定
  #
  # item : 装备物品
  #
  def equippable?(item)
    if item.is_a?(RPG::Weapon)
      return self.class.weapon_set.include?(item.id)
    elsif item.is_a?(RPG::Armor)
      return false if two_swords_style and item.kind == 0
      return self.class.armor_set.include?(item.id)
    end
    return false
  end
  #
  # 更改经验值
  #
  # exp  : 新的经验值
  # show : 显示的标志
  #
  def change_exp(exp, show)
    last_level = @level
    last_skills = skills
    @exp = [[exp, 9999999].min, 0].max
    while @exp >= @exp_list[@level+1] and @exp_list[@level+1] > 0
      level_up
    end
    while @exp < @exp_list[@level]
      level_down
    end
    @hp = [@hp, maxhp].min
    @mp = [@mp, maxmp].min
    if show and @level > last_level
      display_level_up(skills - last_skills)
    end
  end
  #
  # 等级上升
  #
  #
  def level_up
    @level += 1
    for learning in self.class.learnings
      learn_skill(learning.skill_id) if learning.level == @level
    end
  end
  #
  # 等级下降
  #
  #
  def level_down
    @level -= 1
  end
  #
  # 升级消息的显示
  #
  # new_skills : 新学习技能的序列
  #
  def display_level_up(new_skills)
    $game_message.new_page
    text = sprintf(Vocab::LevelUp, @name, Vocab::level, @level)
    $game_message.texts.push(text)
    for skill in new_skills
      text = sprintf(Vocab::ObtainSkill, skill.name)
      $game_message.texts.push(text)
    end
  end
  #
  # 经验值得获得 (2倍经验值得情况也包含在内)
  #
  # exp  : 经验值的增加量
  # show : 等级上升的标记
  #
  def gain_exp(exp, show)
    if double_exp_gain
      change_exp(@exp + exp * 2, show)
    else
      change_exp(@exp + exp, show)
    end
  end
  #
  # 更改等级
  #
  # level : 新的等级
  # show  : 等级上升的标记
  #
  def change_level(level, show)
    level = [[level, 99].min, 1].max
    change_exp(@exp_list[level], show)
  end
  #
  # 学习特技
  #
  # skill_id : 特技 ID
  #
  def learn_skill(skill_id)
    unless skill_learn?($data_skills[skill_id])
      @skills.push(skill_id)
      @skills.sort!
    end
  end
  #
  # 遗忘特技
  #
  # skill_id : 特技 ID
  #
  def forget_skill(skill_id)
    @skills.delete(skill_id)
  end
  #
  # 已经学会的特技判定
  #
  # skill_id : 特技 ID
  #
  def skill_learn?(skill)
    return @skills.include?(skill.id)
  end
  #
  # 可以使用特技判定
  #
  # skill_id : 特技 ID
  #
  def skill_can_use?(skill)
    return false unless skill_learn?(skill)
    return super
  end
  #
  # 更改名称
  #
  # name : 新的名称
  #
  def name=(name)
    @name = name
  end
  #
  # 更改职业 ID
  #
  # class_id : 新的职业 ID
  #
  def class_id=(class_id)
    @class_id = class_id
    for i in 0..4     # 检查更改职业后，装备是否仍能佩戴
      change_equip(i, nil) unless equippable?(equips[i])
    end
  end
  #
  # 更改图形
  #
  # character_name  : 新的角色行走图 文件名
  # character_index : 新的角色行走图 索引
  # face_name       : 新的角色脸图 文件名
  # face_index      : 新的角色脸图 索引
  #
  def set_graphic(character_name, character_index, face_name, face_index)
    @character_name = character_name
    @character_index = character_index
    @face_name = face_name
    @face_index = face_index
  end
  #
  # 使用活动块么？
  #
  #
  def use_sprite?
    return false
  end
  #
  # 执行崩坏
  #
  #
  def perform_collapse
    if $game_temp.in_battle and dead?
      @collapse = true
      Sound.play_actor_collapse
    end
  end
  #
  # 执行自动恢复 (回合结束的时候呼叫)
  #
  #
  def do_auto_recovery
    if auto_hp_recover and not dead?
      self.hp += maxhp / 20
    end
  end
  #
  # 生成战斗行动 (自动战斗用)
  #
  #
  def make_action
    @action.clear
    return unless movable?
    action_list = []
    action = Game_BattleAction.new(self)
    action.set_attack
    action.evaluate
    action_list.push(action)
    for skill in skills
      action = Game_BattleAction.new(self)
      action.set_skill(skill.id)
      action.evaluate
      action_list.push(action)
    end
    max_value = 0
    for action in action_list
      if action.value > max_value
        @action = action
        max_value = action.value
      end
    end
  end
end