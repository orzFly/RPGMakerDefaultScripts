#
# 处理有关敌人队伍以及战斗数据的类。也进行战斗事件的处理
# 这个类的实例请参考$game_troop。
#

class Game_Troop < Game_Unit
  #
  # 在敌人名称后面加入的文字表
  #
  #
  LETTER_TABLE = [ 'Ａ','Ｂ','Ｃ','Ｄ','Ｅ','Ｆ','Ｇ','Ｈ','Ｉ','Ｊ',
                   'Ｋ','Ｌ','Ｍ','Ｎ','Ｏ','Ｐ','Ｑ','Ｒ','Ｓ','Ｔ',
                   'Ｕ','Ｖ','Ｗ','Ｘ','Ｙ','Ｚ']
  #
  # 定义实例变量
  #
  #
  attr_reader   :screen                   # 战斗画面的状态
  attr_reader   :interpreter              # 战斗事件用解释器 
  attr_reader   :event_flags              # 战斗事件执行完毕标记
  attr_reader   :turn_count               # 回合数
  attr_reader   :name_counts              # 敌人名称的出现数记录哈希
  attr_accessor :can_escape               # 允许逃走标记
  attr_accessor :can_lose                 # 允许失败标记
  attr_accessor :preemptive               # 先制攻击标记
  attr_accessor :surprise                 # 不意打标记
  attr_accessor :turn_ending              # 回合结束处理中标记
  attr_accessor :forcing_battler          # 强制行动的战斗对象
  #
  # 初始化对象
  #
  #
  def initialize
    super
    @screen = Game_Screen.new
    @interpreter = Game_Interpreter.new
    @event_flags = {}
    @enemies = []       # 建立敌人序列
    clear
  end
  #
  # 取得成员
  #
  #
  def members
    return @enemies
  end
  #
  # 清除
  #
  #
  def clear
    @screen.clear
    @interpreter.clear
    @event_flags.clear
    @enemies = []
    @turn_count = 0
    @names_count = {}
    @can_escape = false
    @can_lose = false
    @preemptive = false
    @surprise = false
    @turn_ending = false
    @forcing_battler = nil
  end
  #
  # 取得敌人对象
  #
  #
  def troop
    return $data_troops[@troop_id]
  end
  #
  # 设置
  #
  # troop_id : 敌人队伍 ID
  #
  def setup(troop_id)
    clear
    @troop_id = troop_id
    @enemies = []
    for member in troop.members
      next if $data_enemies[member.enemy_id] == nil
      enemy = Game_Enemy.new(@enemies.size, member.enemy_id)
      enemy.hidden = member.hidden
      enemy.immortal = member.immortal
      enemy.screen_x = member.x
      enemy.screen_y = member.y
      @enemies.push(enemy)
    end
    make_unique_names
  end
  #
  # 对相同名字的敌人附加 ABC 等文字
  #
  #
  def make_unique_names
    for enemy in members
      next unless enemy.exist?
      next unless enemy.letter.empty?
      n = @names_count[enemy.original_name]
      n = 0 if n == nil
      enemy.letter = LETTER_TABLE[n % LETTER_TABLE.size]
      @names_count[enemy.original_name] = n + 1
    end
    for enemy in members
      n = @names_count[enemy.original_name]
      n = 0 if n == nil
      enemy.plural = true if n >= 2
    end
  end
  #
  # 刷新画面
  #
  #
  def update
    @screen.update
  end
  #
  # 取得敌人名称的排列
  #
  # 战斗开始时表示用。重复的将除去。
  #
  def enemy_names
    names = []
    for enemy in members
      next unless enemy.exist?
      next if names.include?(enemy.original_name)
      names.push(enemy.original_name)
    end
    return names
  end
  #
  # 战斗事件 (页面) 的符合条件判断
  #
  # page : 战斗事件页面
  #
  def conditions_met?(page)
    c = page.condition
    if not c.turn_ending and not c.turn_valid and not c.enemy_valid and
       not c.actor_valid and not c.switch_valid
      return false      # 条件未设定……不执行
    end
    if @event_flags[page]
      return false      # 执行完毕
    end
    if c.turn_ending    # 回合结束时
      return false unless @turn_ending
    end
    if c.turn_valid     # 回合数
      n = @turn_count
      a = c.turn_a
      b = c.turn_b
      return false if (b == 0 and n != a)
      return false if (b > 0 and (n < 1 or n < a or n % b != a % b))
    end
    if c.enemy_valid    # 敌人
      enemy = $game_troop.members[c.enemy_index]
      return false if enemy == nil
      return false if enemy.hp * 100.0 / enemy.maxhp > c.enemy_hp
    end
    if c.actor_valid    # 角色
      actor = $game_actors[c.actor_id]
      return false if actor == nil 
      return false if actor.hp * 100.0 / actor.maxhp > c.actor_hp
    end
    if c.switch_valid   # 开关
      return false if $game_switches[c.switch_id] == false
    end
    return true         # 符合条件
  end
  #
  # 设置战斗事件
  #
  #
  def setup_battle_event
    return if @interpreter.running?
    if $game_temp.common_event_id > 0
      common_event = $data_common_events[$game_temp.common_event_id]
      @interpreter.setup(common_event.list)
      $game_temp.common_event_id = 0
      return
    end
    for page in troop.pages
      next unless conditions_met?(page)
      @interpreter.setup(page.list)
      if page.span <= 1
        @event_flags[page] = true
      end
      return
    end
  end
  #
  # 增加回合
  #
  #
  def increase_turn
    for page in troop.pages
      if page.span == 1
        @event_flags[page] = false
      end
    end
    @turn_count += 1
  end
  #
  # 生成战斗行动
  #
  #
  def make_actions
    if @preemptive
      clear_actions
    else
      for enemy in members
        enemy.make_action
      end
    end
  end
  #
  # 全灭判定
  #
  #
  def all_dead?
    return existing_members.empty?
  end
  #
  # 经验值的合计计算
  #
  #
  def exp_total
    exp = 0
    for enemy in dead_members
      exp += enemy.exp unless enemy.hidden
    end
    return exp
  end
  #
  # 金钱的合计计算
  #
  #
  def gold_total
    gold = 0
    for enemy in dead_members
      gold += enemy.gold unless enemy.hidden
    end
    return gold
  end
  #
  # 生成掉落道具的序列
  #
  #
  def make_drop_items
    drop_items = []
    for enemy in dead_members
      for di in [enemy.drop_item1, enemy.drop_item2]
        next if di.kind == 0
        next if rand(di.denominator) != 0
        if di.kind == 1
          drop_items.push($data_items[di.item_id])
        elsif di.kind == 2
          drop_items.push($data_weapons[di.weapon_id])
        elsif di.kind == 3
          drop_items.push($data_armors[di.armor_id])
        end
      end
    end
    return drop_items
  end
end