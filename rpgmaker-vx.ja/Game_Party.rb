#
# パーティを扱うクラスです。ゴールドやアイテムなどの情報が含まれます。このク
# ラスのインスタンスは $game_party で参照されます。
#

class Game_Party < Game_Unit
  #
  # 定数
  #
  #
  MAX_MEMBERS = 4                         # 最大パーティ人数
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :gold                     # ゴールド
  attr_reader   :steps                    # 歩数
  attr_accessor :last_item_id             # カーソル記憶用 : アイテム
  attr_accessor :last_actor_index         # カーソル記憶用 : アクター
  attr_accessor :last_target_index        # カーソル記憶用 : ターゲット
  #
  # オブジェクト初期化
  #
  #
  def initialize
    super
    @gold = 0
    @steps = 0
    @last_item_id = 0
    @last_actor_index = 0
    @last_target_index = 0
    @actors = []      # パーティメンバー (アクター ID)
    @items = {}       # 所持品ハッシュ (アイテム ID)
    @weapons = {}     # 所持品ハッシュ (武器 ID)
    @armors = {}      # 所持品ハッシュ (防具 ID)
  end
  #
  # メンバーの取得
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
  # アイテムオブジェクトの配列取得 (武器と防具を含む)
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
  # 初期パーティのセットアップ
  #
  #
  def setup_starting_members
    @actors = []
    for i in $data_system.party_members
      @actors.push(i)
    end
  end
  #
  # パーティ名の取得
  #
  # 一人ならそのアクターの名前、複数なら "○○たち" を返す。
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
  # 戦闘テスト用パーティのセットアップ
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
  # 最大レベルの取得
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
  # アクターを加える
  #
  # actor_id : アクター ID
  #
  def add_actor(actor_id)
    if @actors.size < MAX_MEMBERS and not @actors.include?(actor_id)
      @actors.push(actor_id)
      $game_player.refresh
    end
  end
  #
  # アクターを外す
  #
  # actor_id : アクター ID
  #
  def remove_actor(actor_id)
    @actors.delete(actor_id)
    $game_player.refresh
  end
  #
  # ゴールドの増加 (減少)
  #
  # n : 金額
  #
  def gain_gold(n)
    @gold = [[@gold + n, 0].max, 9999999].min
  end
  #
  # ゴールドの減少
  #
  # n : 金額
  #
  def lose_gold(n)
    gain_gold(-n)
  end
  #
  # 歩数増加
  #
  #
  def increase_steps
    @steps += 1
  end
  #
  # アイテムの所持数取得
  #
  # item : アイテム
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
  # アイテムの所持判定
  #
  # item          : アイテム
  # include_equip : 装備品も含める
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
  # アイテムの増加 (減少)
  #
  # item          : アイテム
  # n             : 個数
  # include_equip : 装備品も含める
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
  # アイテムの減少
  #
  # item          : アイテム
  # n             : 個数
  # include_equip : 装備品も含める
  #
  def lose_item(item, n, include_equip = false)
    gain_item(item, -n, include_equip)
  end
  #
  # アイテムの消耗
  #
  # item : アイテム
  # 指定されたオブジェクトが消耗アイテムであれば、所持数を 1 減らす。
  #
  def consume_item(item)
    if item.is_a?(RPG::Item) and item.consumable
      lose_item(item, 1)
    end
  end
  #
  # アイテムの使用可能判定
  #
  # item : アイテム
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
  # コマンド入力可能判定
  #
  # 自動戦闘は入力可能として扱う。
  #
  def inputable?
    for actor in members
      return true if actor.inputable?
    end
    return false
  end
  #
  # 全滅判定
  #
  #
  def all_dead?
    if @actors.size == 0 and not $game_temp.in_battle
      return false 
    end
    return existing_members.empty?
  end
  #
  # プレイヤーが 1 歩動いたときの処理
  #
  #
  def on_player_walk
    for actor in members
      if actor.slip_damage?
        actor.hp -= 1 if actor.hp > 1   # 毒ダメージ
        $game_map.screen.start_flash(Color.new(255,0,0,64), 4)
      end
      if actor.auto_hp_recover and actor.hp > 0
        actor.hp += 1                   # HP 自動回復
      end
    end
  end
  #
  # 自動回復の実行 (ターン終了時に呼び出し)
  #
  #
  def do_auto_recovery
    for actor in members
      actor.do_auto_recovery
    end
  end
  #
  # 戦闘用ステートの解除 (戦闘終了時に呼び出し)
  #
  #
  def remove_states_battle
    for actor in members
      actor.remove_states_battle
    end
  end
end
