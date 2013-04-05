#
# 敵キャラを扱うクラスです。このクラスは Game_Troop クラス ($game_troop) の
# 内部で使用されます。
#

class Game_Enemy < Game_Battler
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :index                    # 敵グループ内インデックス
  attr_reader   :enemy_id                 # 敵キャラ ID
  attr_reader   :original_name            # 元の名前
  attr_accessor :letter                   # 名前につける ABC の文字
  attr_accessor :plural                   # 複数出現フラグ
  attr_accessor :screen_x                 # バトル画面 X 座標
  attr_accessor :screen_y                 # バトル画面 Y 座標
  #
  # オブジェクト初期化
  #
  # index    : 敵グループ内インデックス
  # enemy_id : 敵キャラ ID
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
  # アクターか否かの判定
  #
  #
  def actor?
    return false
  end
  #
  # 敵キャラオブジェクト取得
  #
  #
  def enemy
    return $data_enemies[@enemy_id]
  end
  #
  # 表示名の取得
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
  # 基本 MaxHP の取得
  #
  #
  def base_maxhp
    return enemy.maxhp
  end
  #
  # 基本 MaxMP の取得
  #
  #
  def base_maxmp
    return enemy.maxmp
  end
  #
  # 基本攻撃力の取得
  #
  #
  def base_atk
    return enemy.atk
  end
  #
  # 基本防御力の取得
  #
  #
  def base_def
    return enemy.def
  end
  #
  # 基本精神力の取得
  #
  #
  def base_spi
    return enemy.spi
  end
  #
  # 基本敏捷性の取得
  #
  #
  def base_agi
    return enemy.agi
  end
  #
  # 命中率の取得
  #
  #
  def hit
    return enemy.hit
  end
  #
  # 回避率の取得
  #
  #
  def eva
    return enemy.eva
  end
  #
  # クリティカル率の取得
  #
  #
  def cri
    return enemy.has_critical ? 10 : 0
  end
  #
  # 狙われやすさの取得
  #
  #
  def odds
    return 1
  end
  #
  # 属性修正値の取得
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
  # ステートの付加成功率の取得
  #
  # state_id : ステート ID
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
  # 経験値の取得
  #
  #
  def exp
    return enemy.exp
  end
  #
  # お金の取得
  #
  #
  def gold
    return enemy.gold
  end
  #
  # ドロップアイテム 1 の取得
  #
  #
  def drop_item1
    return enemy.drop_item1
  end
  #
  # ドロップアイテム 2 の取得
  #
  #
  def drop_item2
    return enemy.drop_item2
  end
  #
  # スプライトを使うか？
  #
  #
  def use_sprite?
    return true
  end
  #
  # バトル画面 Z 座標の取得
  #
  #
  def screen_z
    return 100
  end
  #
  # コラプスの実行
  #
  #
  def perform_collapse
    if $game_temp.in_battle and dead?
      @collapse = true
      Sound.play_enemy_collapse
    end
  end
  #
  # 逃げる
  #
  #
  def escape
    @hidden = true
    @action.clear
  end
  #
  # 変身
  #
  # enemy_id : 変身先の敵キャラ ID
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
  # 行動条件合致判定
  #
  # action : 戦闘行動
  #
  def conditions_met?(action)
    case action.condition_type
    when 1  # ターン数
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
    when 4  # ステート
      return false unless state?(action.condition_param1)
    when 5  # パーティレベル
      return false if $game_party.max_level < action.condition_param1
    when 6  # スイッチ
      switch_id = action.condition_param1
      return false if $game_switches[switch_id] == false
    end
    return true
  end
  #
  # 戦闘行動の作成
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
