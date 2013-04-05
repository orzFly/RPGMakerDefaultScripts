#
# 敵グループおよび戦闘に関するデータを扱うクラスです。バトルイベントの処理も
# 行います。このクラスのインスタンスは $game_troop で参照されます。
#

class Game_Troop < Game_Unit
  #
  # 敵キャラ名の後ろにつける文字の表
  #
  #
  LETTER_TABLE = [ 'Ａ','Ｂ','Ｃ','Ｄ','Ｅ','Ｆ','Ｇ','Ｈ','Ｉ','Ｊ',
                   'Ｋ','Ｌ','Ｍ','Ｎ','Ｏ','Ｐ','Ｑ','Ｒ','Ｓ','Ｔ',
                   'Ｕ','Ｖ','Ｗ','Ｘ','Ｙ','Ｚ']
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :screen                   # バトル画面の状態
  attr_reader   :interpreter              # バトルイベント用インタプリタ
  attr_reader   :event_flags              # バトルイベント実行済みフラグ
  attr_reader   :turn_count               # ターン数
  attr_reader   :name_counts              # 敵キャラ名の出現数記録ハッシュ
  attr_accessor :can_escape               # 逃走可能フラグ
  attr_accessor :can_lose                 # 敗北可能フラグ
  attr_accessor :preemptive               # 先制攻撃フラグ
  attr_accessor :surprise                 # 不意打ちフラグ
  attr_accessor :turn_ending              # ターン終了処理中フラグ
  attr_accessor :forcing_battler          # 戦闘行動の強制対象
  #
  # オブジェクト初期化
  #
  #
  def initialize
    super
    @screen = Game_Screen.new
    @interpreter = Game_Interpreter.new
    @event_flags = {}
    @enemies = []       # トループメンバー (敵キャラオブジェクトの配列)
    clear
  end
  #
  # メンバーの取得
  #
  #
  def members
    return @enemies
  end
  #
  # クリア
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
  # 敵グループオブジェクト取得
  #
  #
  def troop
    return $data_troops[@troop_id]
  end
  #
  # セットアップ
  #
  # troop_id : 敵グループ ID
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
  # 同名の敵キャラに ABC などの文字を付加
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
  # フレーム更新
  #
  #
  def update
    @screen.update
  end
  #
  # 敵キャラ名の配列取得
  #
  # 戦闘開始時の表示用。重複は除去する。
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
  # バトルイベント (ページ) の条件合致判定
  #
  # page : バトルイベントページ
  #
  def conditions_met?(page)
    c = page.condition
    if not c.turn_ending and not c.turn_valid and not c.enemy_valid and
       not c.actor_valid and not c.switch_valid
      return false      # 条件未設定…実行しない
    end
    if @event_flags[page]
      return false      # 実行済み
    end
    if c.turn_ending    # ターン終了時
      return false unless @turn_ending
    end
    if c.turn_valid     # ターン数
      n = @turn_count
      a = c.turn_a
      b = c.turn_b
      return false if (b == 0 and n != a)
      return false if (b > 0 and (n < 1 or n < a or n % b != a % b))
    end
    if c.enemy_valid    # 敵キャラ
      enemy = $game_troop.members[c.enemy_index]
      return false if enemy == nil
      return false if enemy.hp * 100.0 / enemy.maxhp > c.enemy_hp
    end
    if c.actor_valid    # アクター
      actor = $game_actors[c.actor_id]
      return false if actor == nil 
      return false if actor.hp * 100.0 / actor.maxhp > c.actor_hp
    end
    if c.switch_valid   # スイッチ
      return false if $game_switches[c.switch_id] == false
    end
    return true         # 条件合致
  end
  #
  # バトルイベントのセットアップ
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
  # ターンの増加
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
  # 戦闘行動の作成
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
  # 全滅判定
  #
  #
  def all_dead?
    return existing_members.empty?
  end
  #
  # 経験値の合計計算
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
  # お金の合計計算
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
  # ドロップアイテムの配列作成
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
