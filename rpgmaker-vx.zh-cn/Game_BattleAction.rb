#
# 处理行动 (战斗中的行动) 的类。这个类在 Game_Battler 类
# 的内部使用。
#

class Game_BattleAction
  #
  # 定义实例变量
  #
  #
  attr_accessor :battler                  # 战斗者
  attr_accessor :speed                    # 速度
  attr_accessor :kind                     # 种类 (基本 / 特技 / 物品)
  attr_accessor :basic                    # 基本 (攻击 / 防御 / 逃跑 / 待机)
  attr_accessor :skill_id                 # 特技 ID
  attr_accessor :item_id                  # 物品 ID
  attr_accessor :target_index             # 对像索引
  attr_accessor :forcing                  # 强制标记
  attr_accessor :value                    # 自动战斗用 评价值
  #
  # 初始化对像
  #
  # battler : 战斗者
  #
  def initialize(battler)
    @battler = battler
    clear
  end
  #
  # 清除
  #
  #
  def clear
    @speed = 0
    @kind = 0
    @basic = -1
    @skill_id = 0
    @item_id = 0
    @target_index = -1
    @forcing = false
    @value = 0
  end
  #
  # 获取己方伙伴
  #
  #
  def friends_unit
    if battler.actor?
      return $game_party
    else
      return $game_troop
    end
  end
  #
  # 获取敌方伙伴
  #
  #
  def opponents_unit
    if battler.actor?
      return $game_troop
    else
      return $game_party
    end
  end
  #
  # 设置普通攻击
  #
  #
  def set_attack
    @kind = 0
    @basic = 0
  end
  #
  # 设置防御
  #
  #
  def set_guard
    @kind = 0
    @basic = 1
  end
  #
  # 设置特技
  #
  # skill_id : 特技 ID
  #
  def set_skill(skill_id)
    @kind = 1
    @skill_id = skill_id
  end
  #
  # 设置物品
  #
  # item_id : 物品 ID
  #
  def set_item(item_id)
    @kind = 2
    @item_id = item_id
  end
  #
  # 普通攻击判定
  #
  #
  def attack?
    return (@kind == 0 and @basic == 0)
  end
  #
  # 防御判定
  #
  #
  def guard?
    return (@kind == 0 and @basic == 1)
  end
  #
  # 什么都不做的行动判断
  #
  #
  def nothing?
    return (@kind == 0 and @basic < 0)
  end
  #
  # 特技判定
  #
  #
  def skill?
    return @kind == 1
  end
  #
  # 特技对象取得
  #
  #
  def skill
    return skill? ? $data_skills[@skill_id] : nil
  end
  #
  # 物品判定
  #
  #
  def item?
    return @kind == 2
  end
  #
  # 物品对象取得
  #
  #
  def item
    return item? ? $data_items[@item_id] : nil
  end
  #
  # 己方单体使用判定
  #
  #
  def for_friend?
    return true if skill? and skill.for_friend?
    return true if item? and item.for_friend?
    return false
  end
  #
  # 战斗不能的己方单体用判定
  #
  #
  def for_dead_friend?
    return true if skill? and skill.for_dead_friend?
    return true if item? and item.for_dead_friend?
    return false
  end
  #
  # 随机目标 
  #
  #
  def decide_random_target
    if for_friend?
      target = friends_unit.random_target
    elsif for_dead_friend?
      target = friends_unit.random_dead_target
    else
      target = opponents_unit.random_target
    end
    if target == nil
      clear
    else
      @target_index = target.index
    end
  end
  #
  # 最后的目标 
  #
  #
  def decide_last_target
    if @target_index == -1
      target = nil
    elsif for_friend?
      target = friends_unit.members[@target_index]
    else
      target = opponents_unit.members[@target_index]
    end
    if target == nil or not target.exist?
      clear
    end
  end
  #
  # 行动准备
  #
  #
  def prepare
    if battler.berserker? or battler.confusion?   # 暴走或混乱
      set_attack                                  # 变更为普通攻击
    end
  end
  #
  # 行动有效与否判断
  #
  # 活动指令不是 [强制战斗行动] 时
  # 因物品或特技用完预定不能行动时 返回 false。
  #
  def valid?
    return false if nothing?                      # 什么也不做
    return true if @forcing                       # 强制行动中
    return false unless battler.movable?          # 行动不能
    if skill?                                     # 特技
      return false unless battler.skill_can_use?(skill)
    elsif item?                                   # 物品
      return false unless friends_unit.item_can_use?(item)
    end
    return true
  end
  #
  # 确定行动速度
  #
  #
  def make_speed
    @speed = battler.agi + rand(5 + battler.agi / 4)
    @speed += skill.speed if skill?
    @speed += item.speed if item?
    @speed += 2000 if guard?
    @speed += 1000 if attack? and battler.fast_attack
  end
  #
  # 生成目标序列
  #
  #
  def make_targets
    if attack?
      return make_attack_targets
    elsif skill?
      return make_obj_targets(skill)
    elsif item?
      return make_obj_targets(item)
    end
  end
  #
  # 生成普通攻击目标
  #
  #
  def make_attack_targets
    targets = []
    if battler.confusion?
      targets.push(friends_unit.random_target)
    elsif battler.berserker?
      targets.push(opponents_unit.random_target)
    else
      targets.push(opponents_unit.smooth_target(@target_index))
    end
    if battler.dual_attack      # 连续攻击
      targets += targets
    end
    return targets.compact
  end
  #
  # 生成特技或物品的目标
  #
  # obj : 特技或物品
  #
  def make_obj_targets(obj)
    targets = []
    if obj.for_opponent?
      if obj.for_random?
        if obj.for_one?         # 敌单体 随机
          number_of_targets = 1
        elsif obj.for_two?      # 敌二体 随机
          number_of_targets = 2
        else                    # 敌三体 随机
          number_of_targets = 3
        end
        number_of_targets.times do
          targets.push(opponents_unit.random_target)
        end
      elsif obj.dual?           # 敌单体 连续
        targets.push(opponents_unit.smooth_target(@target_index))
        targets += targets
      elsif obj.for_one?        # 敌单体
        targets.push(opponents_unit.smooth_target(@target_index))
      else                      # 敌全体
        targets += opponents_unit.existing_members
      end
    elsif obj.for_user?         # 使用者
      targets.push(battler)
    elsif obj.for_dead_friend?
      if obj.for_one?           # 己方单体 (战斗不能)
        targets.push(friends_unit.smooth_dead_target(@target_index))
      else                      # 己方全体 (战斗不能)
        targets += friends_unit.dead_members
      end
    elsif obj.for_friend?
      if obj.for_one?           # 己方単体
        targets.push(friends_unit.smooth_target(@target_index))
      else                      # 己方全体
        targets += friends_unit.existing_members
      end
    end
    return targets.compact
  end
  #
  # 行动价值评价 (自动战斗用)
  #
  # `@value` 和 `@target_index` 自动设置
  #
  def evaluate
    if attack?
      evaluate_attack
    elsif skill?
      evaluate_skill
    else
      @value = 0
    end
    if @value > 0
      @value + rand(nil)
    end
  end
  #
  # 普通攻击的评价
  #
  #
  def evaluate_attack
    @value = 0
    for target in opponents_unit.existing_members
      value = evaluate_attack_with_target(target)
      if value > @value
        @value = value
        @target_index = target.index
      end
    end
  end
  #
  # 普通攻击的评价 (目标指定)
  #
  # target : 对象战斗者
  #
  def evaluate_attack_with_target(target)
    target.clear_action_results
    target.make_attack_damage_value(battler)
    return target.hp_damage.to_f / [target.hp, 1].max
  end
  #
  # 特技的评价
  #
  #
  def evaluate_skill
    @value = 0
    unless battler.skill_can_use?(skill)
      return
    end
    if skill.for_opponent?
      targets = opponents_unit.existing_members
    elsif skill.for_user?
      targets = [battler]
    elsif skill.for_dead_friend?
      targets = friends_unit.dead_members
    else
      targets = friends_unit.existing_members
    end
    for target in targets
      value = evaluate_skill_with_target(target)
      if skill.for_all?
        @value += value
      elsif value > @value
        @value = value
        @target_index = target.index
      end
    end
  end
  #
  # 特技的评价 (目标指定)
  #
  # target : 对象战斗者
  #
  def evaluate_skill_with_target(target)
    target.clear_action_results
    target.make_obj_damage_value(battler, skill)
    if skill.for_opponent?
      return target.hp_damage.to_f / [target.hp, 1].max
    else
      recovery = [-target.hp_damage, target.maxhp - target.hp].min
      return recovery.to_f / target.maxhp
    end
  end
end
