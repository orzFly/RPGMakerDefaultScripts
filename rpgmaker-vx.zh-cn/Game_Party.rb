#
# 处理队伍的类。包含金钱以及物品的信息。
# 这个类的实例请参考 $game_party 。
#

class Game_Party < Game_Unit
  #
  # 定量
  #
  #
  MAX_MEMBERS = 4                         # 最大队伍人数
  #
  # 定义实例变量
  #
  #
  attr_reader   :gold                     # 金钱
  attr_reader   :steps                    # 步数
  attr_accessor :last_item_id             # 光标记忆用 : 道具
  attr_accessor :last_actor_index         # 光标记忆用 : 角色
  attr_accessor :last_target_index        # 光标记忆用 : 目标
  #
  # 初始化对象
  #
  #
  def initialize
    super
    @gold = 0
    @steps = 0
    @last_item_id = 0
    @last_actor_index = 0
    @last_target_index = 0
    @actors = []      # 队伍成员 (角色 ID)
    @items = {}       # 所持物品哈希 (道具 ID)
    @weapons = {}     # 所持物品哈希 (武器 ID)
    @armors = {}      # 所持物品哈希 (防具 ID)
  end
  #
  # 取得成员
  #
  #
  def members
    result = []
    for i in @actors
      result.push($game_actors[i])
    end
    return result
  end
  #
  # 取得道具对象序列（包含武器和防具）
  #
  #
  def items
    result = []
    for i in @items.keys.sort
      result.push($data_items[i]) if @items[i] > 0
    end
    for i in @weapons.keys.sort
      result.push($data_weapons[i]) if @weapons[i] > 0
    end
    for i in @armors.keys.sort
      result.push($data_armors[i]) if @armors[i] > 0
    end
    return result
  end
  #
  # 设置初期同伴
  #
  #
  def setup_starting_members
    @actors = []
    for i in $data_system.party_members
      @actors.push(i)
    end
  end
  #
  # 取得队伍名
  #
  # 1人的时候取角色名称、2人以上为 “○○们” 。
  #
  def name
    if @actors.size == 0
      return ''
    elsif @actors.size == 1
      return members[0].name
    else
      return sprintf(Vocab::PartyName, members[0].name)
    end
  end
  #
  # 设置战斗测试用同伴
  #
  #
  def setup_battle_test_members
    @actors = []
    for battler in $data_system.test_battlers
      actor = $game_actors[battler.actor_id]
      actor.change_level(battler.level, false)
      actor.change_equip_by_id(0, battler.weapon_id, true)
      actor.change_equip_by_id(1, battler.armor1_id, true)
      actor.change_equip_by_id(2, battler.armor2_id, true)
      actor.change_equip_by_id(3, battler.armor3_id, true)
      actor.change_equip_by_id(4, battler.armor4_id, true)
      actor.recover_all
      @actors.push(actor.id)
    end
    @items = {}
    for i in 1...$data_items.size
      if $data_items[i].battle_ok?
        @items[i] = 99 unless $data_items[i].name.empty?
      end
    end
  end
  #
  # 取得最大等级
  #
  #
  def max_level
    level = 0
    for i in @actors
      actor = $game_actors[i]
      level = actor.level if level < actor.level
    end
    return level
  end
  #
  # 加入同伴
  #
  # actor_id : 角色 ID
  #
  def add_actor(actor_id)
    if @actors.size < MAX_MEMBERS and not @actors.include?(actor_id)
      @actors.push(actor_id)
      $game_player.refresh
    end
  end
  #
  # 角色离开
  #
  # actor_id : 角色 ID
  #
  def remove_actor(actor_id)
    @actors.delete(actor_id)
    $game_player.refresh
  end
  #
  # 增加金钱（减少）
  #
  # n : 金额
  #
  def gain_gold(n)
    @gold = [[@gold + n, 0].max, 9999999].min
  end
  #
  # 减少金钱
  #
  # n : 金额
  #
  def lose_gold(n)
    gain_gold(-n)
  end
  #
  # 步数増加
  #
  #
  def increase_steps
    @steps += 1
  end
  #
  # 获取物品的所持数
  #
  # item : 物品
  #
  def item_number(item)
    case item
    when RPG::Item
      number = @items[item.id]
    when RPG::Weapon
      number = @weapons[item.id]
    when RPG::Armor
      number = @armors[item.id]
    end
    return number == nil ? 0 : number
  end
  #
  # 判断是否持有物品
  #
  # item          : 物品
  # include_equip : 包含装备
  #
  def has_item?(item, include_equip = false)
    if item_number(item) > 0
      return true
    end
    if include_equip
      for actor in members
        return true if actor.equips.include?(item)
      end
    end
    return false
  end
  #
  # 增加物品(减少)
  #
  # item          : 物品
  # n             : 个数
  # include_equip : 包括装备
  #
  def gain_item(item, n, include_equip = false)
    number = item_number(item)
    case item
    when RPG::Item
      @items[item.id] = [[number + n, 0].max, 99].min
    when RPG::Weapon
      @weapons[item.id] = [[number + n, 0].max, 99].min
    when RPG::Armor
      @armors[item.id] = [[number + n, 0].max, 99].min
    end
    n += number
    if include_equip and n < 0
      for actor in members
        while n < 0 and actor.equips.include?(item)
          actor.discard_equip(item)
          n += 1
        end
      end
    end
  end
  #
  # 减少物品
  #
  # item          : 物品
  # n             : 个数
  # include_equip : 包括装备
  #
  def lose_item(item, n, include_equip = false)
    gain_item(item, -n, include_equip)
  end
  #
  # 消耗物品
  #
  # item : 物品
  # 如果指定对象为消耗物品，所持数减去1。
  #
  def consume_item(item)
    if item.is_a?(RPG::Item) and item.consumable
      lose_item(item, 1)
    end
  end
  # 
  # 判断物品可以使用
  #
  # item_id : 物品 ID
  #
  def item_can_use?(item)
    return false unless item.is_a?(RPG::Item)
    return false if item_number(item) == 0
    if $game_temp.in_battle
      return item.battle_ok?
    else
      return item.menu_ok?
    end
  end
  #
  # 可以输入命令的判定
  #
  # 可以处理自动战斗的输入。
  #
  def inputable?
    for actor in members
      return true if actor.inputable?
    end
    return false
  end
  #
  # 全灭判定
  #
  #
  def all_dead?
    if @actors.size == 0 and not $game_temp.in_battle
      return false 
    end
    return existing_members.empty?
  end
  #
  # 玩家每一步动作的处理
  #
  #
  def on_player_walk
    for actor in members
      if actor.slip_damage?
        actor.hp -= 1 if actor.hp > 1   # 毒伤害
        $game_map.screen.start_flash(Color.new(255,0,0,64), 4)
      end
      if actor.auto_hp_recover and actor.hp > 0
        actor.hp += 1                   # HP 自动恢复
      end
    end
  end
  #
  # 执行自动恢复 (回合结束时呼叫)
  #
  #
  def do_auto_recovery
    for actor in members
      actor.do_auto_recovery
    end
  end
  #
  # 解除战斗用状态（战斗结束时呼叫）
  #
  #
  def remove_states_battle
    for actor in members
      actor.remove_states_battle
    end
  end
end
