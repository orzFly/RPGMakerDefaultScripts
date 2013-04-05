#
# 处理敌人的类。
# 这个类是作为Game_Troop类($game_troop)的内部使用。
#

class Game_Enemy < Game_Battler
  #
  # 定义实例变量
  #
  #
  attr_reader   :index                    # 敌人队伍内的索引
  attr_reader   :enemy_id                 # 敌人 ID
  attr_reader   :original_name            # 原本的名称
  attr_accessor :letter                   # 给名称的加上的ABC文字
  attr_accessor :plural                   # 复数出现标记
  attr_accessor :screen_x                 # 战斗画面 X 坐标
  attr_accessor :screen_y                 # 战斗画面 Y 坐标
  #
  # 初始化对象
  #
  # index    : 敌人队伍内的索引
  # enemy_id : 敌人 ID
  #
  def initialize(index, enemy_id)
    super()
    @index = index
    @enemy_id = enemy_id
    enemy = $data_enemies[@enemy_id]
    @original_name = enemy.name
    @letter = ''
    @plural = false
    @screen_x = 0
    @screen_y = 0
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = maxhp
    @mp = maxmp
  end
  #
  # 角色在否判定
  #
  #
  def actor?
    return false
  end
  #
  # 取得敌人对象
  #
  #
  def enemy
    return $data_enemies[@enemy_id]
  end
  #
  # 取得显示名字
  #
  #
  def name
    if @plural
      return @original_name + letter
    else
      return @original_name
    end
  end
  #
  # 取得基本 MaxHP 
  #
  #
  def base_maxhp
    return enemy.maxhp
  end
  #
  # 取得基本 MaxMP 
  #
  #
  def base_maxmp
    return enemy.maxmp
  end
  #
  # 取得基本攻击力
  #
  #
  def base_atk
    return enemy.atk
  end
  #
  # 取得基本防御力
  #
  #
  def base_def
    return enemy.def
  end
  #
  # 取得基本精神力
  #
  #
  def base_spi
    return enemy.spi
  end
  #
  # 取得基本敏捷性
  #
  #
  def base_agi
    return enemy.agi
  end
  #
  # 取得命中率
  #
  #
  def hit
    return enemy.hit
  end
  #
  # 取得回避率
  #
  #
  def eva
    return enemy.eva
  end
  #
  # 取得会心一击率
  #
  #
  def cri
    return enemy.has_critical ? 10 : 0
  end
  #
  # 取得瞄准
  #
  #
  def odds
    return 1
  end
  #
  # 取得属性修正值
  #
  # element_id : 属性 ID
  #
  def element_rate(element_id)
    rank = enemy.element_ranks[element_id]
    result = [0,200,150,100,50,0,-100][rank]
    for state in states
      result /= 2 if state.element_set.include?(element_id)
    end
    return result
  end
  #
  # 取得状态附加成功率
  #
  # state_id : 状态 ID
  #
  def state_probability(state_id)
    if $data_states[state_id].nonresistance
      return 100
    else
      rank = enemy.state_ranks[state_id]
      return [0,100,80,60,40,20,0][rank]
    end
  end
  #
  # 取得经验值
  #
  #
  def exp
    return enemy.exp
  end
  #
  # 取得金钱
  #
  #
  def gold
    return enemy.gold
  end
  #
  # 取得掉落道具1
  #
  #
  def drop_item1
    return enemy.drop_item1
  end
  #
  # 取得掉落道具2
  #
  #
  def drop_item2
    return enemy.drop_item2
  end
  #
  # 使用活动块么？
  #
  #
  def use_sprite?
    return true
  end
  #
  # 取得战斗画面 Z 坐标
  #
  #
  def screen_z
    return 100
  end
  #
  # 执行崩坏效果
  #
  #
  def perform_collapse
    if $game_temp.in_battle and dead?
      @collapse = true
      Sound.play_enemy_collapse
    end
  end
  #
  # 逃跑
  #
  #
  def escape
    @hidden = true
    @action.clear
  end
  #
  # 变身
  #
  # enemy_id : 变身的敌人 ID
  #
  def transform(enemy_id)
    @enemy_id = enemy_id
    if enemy.name != @original_name
      @original_name = enemy.name
      @letter = ''
      @plural = false
    end
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    make_action
  end
  #
  # 行动条件符合判定
  #
  # action : 战斗行动
  #
  def conditions_met?(action)
    case action.condition_type
    when 1  # 回合数
      n = $game_troop.turn_count
      a = action.condition_param1
      b = action.condition_param2
      return false if (b == 0 and n != a)
      return false if (b > 0 and (n < 1 or n < a or n % b != a % b))
    when 2  # HP
      hp_rate = hp * 100.0 / maxhp
      return false if hp_rate < action.condition_param1
      return false if hp_rate > action.condition_param2
    when 3  # MP
      mp_rate = mp * 100.0 / maxmp
      return false if mp_rate < action.condition_param1
      return false if mp_rate > action.condition_param2
    when 4  # 状态
      return false unless state?(action.condition_param1)
    when 5  # 队伍等级
      return false if $game_party.max_level < action.condition_param1
    when 6  # 开关
      switch_id = action.condition_param1
      return false if $game_switches[switch_id] == false
    end
    return true
  end
  #
  # 生成战斗行动
  #
  #
  def make_action
    @action.clear
    return unless movable?
    available_actions = []
    rating_max = 0
    for action in enemy.actions
      next unless conditions_met?(action)
      if action.kind == 1
        next unless skill_can_use?($data_skills[action.skill_id])
      end
      available_actions.push(action)
      rating_max = [rating_max, action.rating].max
    end
    ratings_total = 0
    rating_zero = rating_max - 3
    for action in available_actions
      next if action.rating <= rating_zero
      ratings_total += action.rating - rating_zero
    end
    return if ratings_total == 0
    value = rand(ratings_total)
    for action in available_actions
      next if action.rating <= rating_zero
      if value < action.rating - rating_zero
        @action.kind = action.kind
        @action.basic = action.basic
        @action.skill_id = action.skill_id
        @action.decide_random_target
        return
      else
        value -= action.rating - rating_zero
      end
    end
  end
end
