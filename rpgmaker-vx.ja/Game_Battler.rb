#
# バトラーを扱うクラスです。このクラスは Game_Actor クラスと Game_Enemy クラ
# スのスーパークラスとして使用されます。
#

class Game_Battler
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :battler_name             # 戦闘グラフィック ファイル名
  attr_reader   :battler_hue              # 戦闘グラフィック 色相
  attr_reader   :hp                       # HP
  attr_reader   :mp                       # MP
  attr_reader   :action                   # 戦闘行動
  attr_accessor :hidden                   # 隠れフラグ
  attr_accessor :immortal                 # 不死身フラグ
  attr_accessor :animation_id             # アニメーション ID
  attr_accessor :animation_mirror         # アニメーション 左右反転フラグ
  attr_accessor :white_flash              # 白フラッシュフラグ
  attr_accessor :blink                    # 点滅フラグ
  attr_accessor :collapse                 # 崩壊フラグ
  attr_reader   :skipped                  # 行動結果: スキップフラグ
  attr_reader   :missed                   # 行動結果: 命中失敗フラグ
  attr_reader   :evaded                   # 行動結果: 回避成功フラグ
  attr_reader   :critical                 # 行動結果: クリティカルフラグ
  attr_reader   :absorbed                 # 行動結果: 吸収フラグ
  attr_reader   :hp_damage                # 行動結果: HP ダメージ
  attr_reader   :mp_damage                # 行動結果: MP ダメージ
  #
  # オブジェクト初期化
  #
  #
  def initialize
    @battler_name = ""
    @battler_hue = 0
    @hp = 0
    @mp = 0
    @action = Game_BattleAction.new(self)
    @states = []                    # ステート (ID の配列)
    @state_turns = {}               # ステートの持続ターン数 (ハッシュ)
    @hidden = false   
    @immortal = false
    clear_extra_values
    clear_sprite_effects
    clear_action_results
  end
  #
  # 能力値に加算する値をクリア
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
  # スプライトとの通信用変数をクリア
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
  # 行動効果の保持用変数をクリア
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
    @added_states = []              # 付加されたステート (ID の配列)
    @removed_states = []            # 解除されたステート (ID の配列)
    @remained_states = []           # 変化しなかったステート (ID の配列)
  end
  #
  # 現在のステートをオブジェクトの配列で取得
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
  # 直前の行動で付加されたステートをオブジェクトの配列で取得
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
  # 直前の行動で解除されたステートをオブジェクトの配列で取得
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
  # 直前の行動で変化しなかったステートをオブジェクトの配列で取得
  #
  # すでに眠っている相手をさらに眠らせようとした場合などの判定用。
  #
  def remained_states
    result = []
    for i in @remained_states
      result.push($data_states[i])
    end
    return result
  end
  #
  # 直前の行動でステートに対して何らかの働きかけがあったかを判定
  #
  #
  def states_active?
    return true unless @added_states.empty?
    return true unless @removed_states.empty?
    return true unless @remained_states.empty?
    return false
  end
  #
  # MaxHP の制限値取得
  #
  #
  def maxhp_limit
    return 999999
  end
  #
  # MaxHP の取得
  #
  #
  def maxhp
    return [[base_maxhp + @maxhp_plus, 1].max, maxhp_limit].min
  end
  #
  # MaxMP の取得
  #
  #
  def maxmp
    return [[base_maxmp + @maxmp_plus, 0].max, 9999].min
  end
  #
  # 攻撃力の取得
  #
  #
  def atk
    n = [[base_atk + @atk_plus, 1].max, 999].min
    for state in states do n *= state.atk_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #
  # 防御力の取得
  #
  #
  def def
    n = [[base_def + @def_plus, 1].max, 999].min
    for state in states do n *= state.def_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #
  # 精神力の取得
  #
  #
  def spi
    n = [[base_spi + @spi_plus, 1].max, 999].min
    for state in states do n *= state.spi_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #
  # 敏捷性の取得
  #
  #
  def agi
    n = [[base_agi + @agi_plus, 1].max, 999].min
    for state in states do n *= state.agi_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #
  # オプション [強力防御] の取得
  #
  #
  def super_guard
    return false
  end
  #
  # 武器オプション [ターン内先制] の取得
  #
  #
  def fast_attack
    return false
  end
  #
  # 武器オプション [連続攻撃] の取得
  #
  #
  def dual_attack
    return false
  end
  #
  # 防具オプション [クリティカル防止] の取得
  #
  #
  def prevent_critical
    return false
  end
  #
  # 防具オプション [消費 MP 半分] の取得
  #
  #
  def half_mp_cost
    return false
  end
  #
  # MaxHP の設定
  #
  # new_maxhp : 新しい MaxHP
  #
  def maxhp=(new_maxhp)
    @maxhp_plus += new_maxhp - self.maxhp
    @maxhp_plus = [[@maxhp_plus, -9999].max, 9999].min
    @hp = [@hp, self.maxhp].min
  end
  #
  # MaxMP の設定
  #
  # new_maxmp : 新しい MaxMP
  #
  def maxmp=(new_maxmp)
    @maxmp_plus += new_maxmp - self.maxmp
    @maxmp_plus = [[@maxmp_plus, -9999].max, 9999].min
    @mp = [@mp, self.maxmp].min
  end
  #
  # 攻撃力の設定
  #
  # new_atk : 新しい攻撃力
  #
  def atk=(new_atk)
    @atk_plus += new_atk - self.atk
    @atk_plus = [[@atk_plus, -999].max, 999].min
  end
  #
  # 防御力の設定
  #
  # new_def : 新しい防御力
  #
  def def=(new_def)
    @def_plus += new_def - self.def
    @def_plus = [[@def_plus, -999].max, 999].min
  end
  #
  # 精神力の設定
  #
  # new_spi : 新しい精神力
  #
  def spi=(new_spi)
    @spi_plus += new_spi - self.spi
    @spi_plus = [[@spi_plus, -999].max, 999].min
  end
  #
  # 敏捷性の設定
  #
  # agi : 新しい敏捷性
  #
  def agi=(new_agi)
    @agi_plus += new_agi - self.agi
    @agi_plus = [[@agi_plus, -999].max, 999].min
  end
  #
  # HP の変更
  #
  # hp : 新しい HP
  #
  def hp=(hp)
    @hp = [[hp, maxhp].min, 0].max
    if @hp == 0 and not state?(1) and not @immortal
      add_state(1)                # 戦闘不能 (ステート 1 番) を付加
      @added_states.push(1)
    elsif @hp > 0 and state?(1)
      remove_state(1)             # 戦闘不能 (ステート 1 番) を解除
      @removed_states.push(1)
    end
  end
  #
  # MP の変更
  #
  # mp : 新しい MP
  #
  def mp=(mp)
    @mp = [[mp, maxmp].min, 0].max
  end
  #
  # 全回復
  #
  #
  def recover_all
    @hp = maxhp
    @mp = maxmp
    for i in @states.clone do remove_state(i) end
  end
  #
  # 戦闘不能判定
  #
  #
  def dead?
    return (not @hidden and @hp == 0 and not @immortal)
  end
  #
  # 存在判定
  #
  #
  def exist?
    return (not @hidden and not dead?)
  end
  #
  # コマンド入力可能判定
  #
  #
  def inputable?
    return (not @hidden and restriction <= 1)
  end
  #
  # 行動可能判定
  #
  #
  def movable?
    return (not @hidden and restriction < 4)
  end
  #
  # 回避可能判定
  #
  #
  def parriable?
    return (not @hidden and restriction < 5)
  end
  #
  # 沈黙状態判定
  #
  #
  def silent?
    return (not @hidden and restriction == 1)
  end
  #
  # 暴走状態判定
  #
  #
  def berserker?
    return (not @hidden and restriction == 2)
  end
  #
  # 混乱状態判定
  #
  #
  def confusion?
    return (not @hidden and restriction == 3)
  end
  #
  # 防御中判定
  #
  #
  def guarding?
    return @action.guard?
  end
  #
  # 属性修正値の取得
  #
  # element_id : 属性 ID
  #
  def element_rate(element_id)
    return 100
  end
  #
  # ステートの付加成功率の取得
  #
  #
  def state_probability(state_id)
    return 0
  end
  #
  # ステート無効化判定
  #
  # state_id : ステート ID
  #
  def state_resist?(state_id)
    return false
  end
  #
  # 通常攻撃の属性取得
  #
  #
  def element_set
    return []
  end
  #
  # 通常攻撃のステート変化 (+) 取得
  #
  #
  def plus_state_set
    return []
  end
  #
  # 通常攻撃のステート変化 (-) 取得
  #
  #
  def minus_state_set
    return []
  end
  #
  # ステートの検査
  #
  # state_id : ステート ID
  # 該当するステートが付加されていれば true を返す。
  #
  def state?(state_id)
    return @states.include?(state_id)
  end
  #
  # ステートがフルかどうかの判定
  #
  # state_id : ステート ID
  # 持続ターン数が自然解除の最低ターン数と同じなら true を返す。
  #
  def state_full?(state_id)
    return false unless state?(state_id)
    return @state_turns[state_id] == $data_states[state_id].hold_turn
  end
  #
  # 無視するべきステートかどうかの判定
  #
  # state_id : ステート ID
  # 次の条件を満たすときに true を返す。
  # ＊付加しようとする新しいステートＡが、現在付加されているステートＢの
  # [解除するステート] のリストに含まれている。
  # ＊そのステートＢが新しいステートＡの [解除するステート] のリストには
  # 含まれていない。
  # この条件は、戦闘不能のときに毒を付加しようとした場合などに該当する。
  # 攻撃力下降のときに攻撃力上昇を付加するような場合には該当しない。
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
  # 相殺するべきステートかどうかの判定
  #
  # state_id : ステート ID
  # 次の条件を満たすときに true を返す。
  # ＊新しいステートのオプション [逆効果と相殺] が有効である。
  # ＊付加しようとする新しいステートの [解除するステート] のリストに、
  # 現在付加されているステートの少なくともひとつが含まれている。
  # 攻撃力下降のときに攻撃力上昇を付加する場合などに該当する。
  #
  def state_offset?(state_id)
    return false unless $data_states[state_id].offset_by_opposite
    for i in @states
      return true if $data_states[state_id].state_set.include?(i)
    end
    return false
  end
  #
  # ステートの並び替え
  #
  # 配列 `@states` の内容を表示優先度の大きい順に並び替える。
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
  # ステートの付加
  #
  # state_id : ステート ID
  #
  def add_state(state_id)
    state = $data_states[state_id]        # ステートデータを取得
    return if state == nil                # データが無効？
    return if state_ignore?(state_id)     # 無視するべきステート？
    unless state?(state_id)               # このステートが付加されていない？
      unless state_offset?(state_id)      # 相殺するべきステートではない？
        @states.push(state_id)            # ID を `@states` 配列に追加
      end
      if state_id == 1                    # 戦闘不能 (ステート 1 番) なら
        @hp = 0                           # HP を 0 に変更する
      end
      unless inputable?                   # 自由意思で行動できない場合
        @action.clear                     # 戦闘行動をクリアする
      end
      for i in state.state_set            # [解除するステート] に指定されて
        remove_state(i)                   # いるステートを実際に解除する
        @removed_states.delete(i)         # 自動解除の分は表示しない
      end
      sort_states                         # 表示優先度の大きい順に並び替え
    end
    @state_turns[state_id] = state.hold_turn    # 自然解除のターン数を設定
  end
  #
  # ステートの解除
  #
  # state_id : ステート ID
  #
  def remove_state(state_id)
    return unless state?(state_id)        # このステートが付加されていない？
    if state_id == 1 and @hp == 0         # 戦闘不能 (ステート 1 番) なら
      @hp = 1                             # HP を 1 に変更する
    end
    @states.delete(state_id)              # ID を `@states` 配列から削除
    @state_turns.delete(state_id)         # ターン数記憶用ハッシュから削除
  end
  #
  # 制約の取得
  #
  # 現在付加されているステートから最大の restriction を取得する。
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
  # ステート [スリップダメージ] 判定
  #
  #
  def slip_damage?
    for state in states
      return true if state.slip_damage
    end
    return false
  end
  #
  # ステート [命中率減少] 判定
  #
  #
  def reduce_hit_ratio?
    for state in states
      return true if state.reduce_hit_ratio
    end
    return false
  end
  #
  # 最重要のステート継続メッセージを取得
  #
  #
  def most_important_state_text
    for state in states
      return state.message3 unless state.message3.empty?
    end
    return ""
  end
  #
  # 戦闘用ステートの解除 (戦闘終了時に呼び出し)
  #
  #
  def remove_states_battle
    for state in states
      remove_state(state.id) if state.battle_only
    end
  end
  #
  # ステート自然解除 (ターンごとに呼び出し)
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
  # ダメージによるステート解除 (ダメージごとに呼び出し)
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
  # スキルの消費 MP 計算
  #
  # skill : スキル
  #
  def calc_mp_cost(skill)
    if half_mp_cost
      return skill.mp_cost / 2
    else
      return skill.mp_cost
    end
  end
  #
  # スキルの使用可能判定
  #
  # skill : スキル
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
  # 最終命中率の計算
  #
  # user : 攻撃者、スキルまたはアイテムの使用者
  # obj  : スキルまたはアイテム (通常攻撃の場合は nil)
  #
  def calc_hit(user, obj = nil)
    if obj == nil                           # 通常攻撃の場合
      hit = user.hit                        # 命中率を取得
      physical = true
    elsif obj.is_a?(RPG::Skill)             # スキルの場合
      hit = obj.hit                         # 成功率を取得
      physical = obj.physical_attack
    else                                    # アイテムの場合
      hit = 100                             # 命中率を 100% とする
      physical = obj.physical_attack
    end
    if physical                             # 物理攻撃の場合
      hit /= 4 if user.reduce_hit_ratio?    # 使用者が暗闇なら 1/4 にする
    end
    return hit
  end
  #
  # 最終回避率の計算
  #
  # user : 攻撃者、スキルまたはアイテムの使用者
  # obj  : スキルまたはアイテム (通常攻撃の場合は nil)
  #
  def calc_eva(user, obj = nil)
    eva = self.eva
    unless obj == nil                       # 通常攻撃ではない場合
      eva = 0 unless obj.physical_attack    # 物理攻撃以外なら 0% とする
    end
    unless parriable?                       # 回避不可能な状態の場合
      eva = 0                               # 回避率を 0% とする
    end
    return eva
  end
  #
  # 通常攻撃によるダメージ計算
  #
  # attacker : 攻撃者
  # 結果は `@hp_damage` に代入する。
  #
  def make_attack_damage_value(attacker)
    damage = attacker.atk * 4 - self.def * 2        # 基本計算
    damage = 0 if damage < 0                        # マイナスなら 0 に
    damage *= elements_max_rate(attacker.element_set)   # 属性修正
    damage /= 100
    if damage == 0                                  # ダメージが 0
      damage = rand(2)                              # 1/2 の確率で 1 ダメージ
    elsif damage > 0                                # ダメージが正の数
      @critical = (rand(100) < attacker.cri)        # クリティカル判定
      @critical = false if prevent_critical         # クリティカル防止？
      damage *= 3 if @critical                      # クリティカル修正
    end
    damage = apply_variance(damage, 20)             # 分散
    damage = apply_guard(damage)                    # 防御修正
    @hp_damage = damage                             # HP にダメージ
  end
  #
  # スキルまたはアイテムによるダメージ計算
  #
  # user : スキルまたはアイテムの使用者
  # obj  : スキルまたはアイテム
  # 結果は `@hp_damage` または `@mp_damage` に代入する。
  #
  def make_obj_damage_value(user, obj)
    damage = obj.base_damage                        # 基本ダメージを取得
    if damage > 0                                   # ダメージが正の数
      damage += user.atk * 4 * obj.atk_f / 100      # 打撃関係度: 使用者
      damage += user.spi * 2 * obj.spi_f / 100      # 精神関係度: 使用者
      unless obj.ignore_defense                     # 防御力無視以外
        damage -= self.def * 2 * obj.atk_f / 100    # 打撃関係度: 対象者
        damage -= self.spi * 1 * obj.spi_f / 100    # 精神関係度: 対象者
      end
      damage = 0 if damage < 0                      # マイナスなら 0 に
    elsif damage < 0                                # ダメージが負の数
      damage -= user.atk * 4 * obj.atk_f / 100      # 打撃関係度: 使用者
      damage -= user.spi * 2 * obj.spi_f / 100      # 精神関係度: 使用者
    end
    damage *= elements_max_rate(obj.element_set)    # 属性修正
    damage /= 100
    damage = apply_variance(damage, obj.variance)   # 分散
    damage = apply_guard(damage)                    # 防御修正
    if obj.damage_to_mp  
      @mp_damage = damage                           # MP にダメージ
    else
      @hp_damage = damage                           # HP にダメージ
    end
  end
  #
  # 吸収効果の計算
  #
  # user : スキルまたはアイテムの使用者
  # obj  : スキルまたはアイテム
  # 呼び出し前に `@hp_damage` と `@mp_damage` が計算されていること。
  #
  def make_obj_absorb_effect(user, obj)
    if obj.absorb_damage                        # 吸収の場合
      @hp_damage = [self.hp, @hp_damage].min    # HP ダメージ範囲修正
      @mp_damage = [self.mp, @mp_damage].min    # MP ダメージ範囲修正
      if @hp_damage > 0 or @mp_damage > 0       # ダメージが正の数の場合
        @absorbed = true                        # 吸収フラグ ON
      end
    end
  end
  #
  # アイテムによる HP 回復量計算
  #
  #
  def calc_hp_recovery(user, item)
    result = maxhp * item.hp_recovery_rate / 100 + item.hp_recovery
    result *= 2 if user.pharmacology    # 薬の知識で効果 2 倍
    return result
  end
  #
  # アイテムによる MP 回復量計算
  #
  #
  def calc_mp_recovery(user, item)
    result = maxmp * item.mp_recovery_rate / 100 + item.mp_recovery
    result *= 2 if user.pharmacology    # 薬の知識で効果 2 倍
    return result
  end
  #
  # 属性の最大修正値の取得
  #
  # element_set : 属性
  # 与えられた属性の中で最も有効な修正値を返す
  #
  def elements_max_rate(element_set)
    return 100 if element_set.empty?                # 無属性の場合
    rate_list = []
    for i in element_set
      rate_list.push(element_rate(i))
    end
    return rate_list.max
  end
  #
  # 分散度の適用
  #
  # damage   : ダメージ
  # variance : 分散度
  #
  def apply_variance(damage, variance)
    if damage != 0                                  # ダメージ 0 以外なら
      amp = [damage.abs * variance / 100, 0].max    # 分散の幅を計算
      damage += rand(amp+1) + rand(amp+1) - amp     # 分散実行
    end
    return damage
  end
  #
  # 防御修正の適用
  #
  # damage : ダメージ
  #
  def apply_guard(damage)
    if damage > 0 and guarding?                     # 防御判定
      damage /= super_guard ? 4 : 2                 # ダメージ減少
    end
    return damage
  end
  #
  # ダメージの反映
  #
  # user : スキルかアイテムの使用者
  # 呼び出し前に @hp_damage、@mp_damage、@absorbed が設定されていること。
  #
  def execute_damage(user)
    if @hp_damage > 0           # ダメージが正の数
      remove_states_shock       # 衝撃によるステート解除
    end
    self.hp -= @hp_damage
    self.mp -= @mp_damage
    if @absorbed                # 吸収の場合
      user.hp += @hp_damage
      user.mp += @mp_damage
    end
  end
  #
  # ステート変化の適用
  #
  # obj : スキル、アイテム、または攻撃者
  #
  def apply_state_changes(obj)
    plus = obj.plus_state_set             # ステート変化(+) を取得
    minus = obj.minus_state_set           # ステート変化(-) を取得
    for i in plus                         # ステート変化 (+)
      next if state_resist?(i)            # 無効化されている？
      next if dead?                       # 戦闘不能？
      next if i == 1 and @immortal        # 不死身？
      if state?(i)                        # すでに付加されている？
        @remained_states.push(i)          # 変化しなかったステートを記録
        next
      end
      if rand(100) < state_probability(i) # 確率判定
        add_state(i)                      # ステートを付加
        @added_states.push(i)             # 付加したステートを記録
      end
    end
    for i in minus                        # ステート変化 (-)
      next unless state?(i)               # 付加されていない？
      remove_state(i)                     # ステートを解除
      @removed_states.push(i)             # 解除したステートを記録する
    end
    for i in @added_states & @removed_states
      @added_states.delete(i)             # 付加と解除の両方に記録されている
      @removed_states.delete(i)           # ステートがあれば両方削除する
    end
  end
  #
  # 通常攻撃の適用可能判定
  #
  # attacker : 攻撃者
  #
  def attack_effective?(attacker)
    if dead?
      return false
    end
    return true
  end
  #
  # 通常攻撃の効果適用
  #
  # attacker : 攻撃者
  #
  def attack_effect(attacker)
    clear_action_results
    unless attack_effective?(attacker)
      @skipped = true
      return
    end
    if rand(100) >= calc_hit(attacker)            # 命中判定
      @missed = true
      return
    end
    if rand(100) < calc_eva(attacker)             # 回避判定
      @evaded = true
      return
    end
    make_attack_damage_value(attacker)            # ダメージ計算
    execute_damage(attacker)                      # ダメージ反映
    if @hp_damage == 0                            # 物理ノーダメージ判定
      return                                    
    end
    apply_state_changes(attacker)                 # ステート変化
  end
  #
  # スキルの適用可能判定
  #
  # user  : スキルの使用者
  # skill : スキル
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
  # スキルの適用テスト
  #
  # user  : スキルの使用者
  # skill : スキル
  # 使用対象が全快しているときの回復禁止などを判定する。
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
  # スキルの効果適用
  #
  # user  : スキルの使用者
  # skill : スキル
  #
  def skill_effect(user, skill)
    clear_action_results
    unless skill_effective?(user, skill)
      @skipped = true
      return
    end
    if rand(100) >= calc_hit(user, skill)         # 命中判定
      @missed = true
      return
    end
    if rand(100) < calc_eva(user, skill)          # 回避判定
      @evaded = true
      return
    end
    make_obj_damage_value(user, skill)            # ダメージ計算
    make_obj_absorb_effect(user, skill)           # 吸収効果計算
    execute_damage(user)                          # ダメージ反映
    if skill.physical_attack and @hp_damage == 0  # 物理ノーダメージ判定
      return                                    
    end
    apply_state_changes(skill)                    # ステート変化
  end
  #
  # アイテムの適用可能判定
  #
  # user : アイテムの使用者
  # item : アイテム
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
  # アイテムの適用テスト
  #
  # user : アイテムの使用者
  # item : アイテム
  # 使用対象が全快しているときの回復禁止などを判定する。
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
  # アイテムの効果適用
  #
  # user : アイテムの使用者
  # item : アイテム
  #
  def item_effect(user, item)
    clear_action_results
    unless item_effective?(user, item)
      @skipped = true
      return
    end
    if rand(100) >= calc_hit(user, item)          # 命中判定
      @missed = true
      return
    end
    if rand(100) < calc_eva(user, item)           # 回避判定
      @evaded = true
      return
    end
    hp_recovery = calc_hp_recovery(user, item)    # HP 回復量計算
    mp_recovery = calc_mp_recovery(user, item)    # MP 回復量計算
    make_obj_damage_value(user, item)             # ダメージ計算
    @hp_damage -= hp_recovery                     # HP 回復量を差し引く
    @mp_damage -= mp_recovery                     # MP 回復量を差し引く
    make_obj_absorb_effect(user, item)            # 吸収効果計算
    execute_damage(user)                          # ダメージ反映
    item_growth_effect(user, item)                # 成長効果適用
    if item.physical_attack and @hp_damage == 0   # 物理ノーダメージ判定
      return                                    
    end
    apply_state_changes(item)                     # ステート変化
  end
  #
  # アイテムの成長効果適用
  #
  # user : アイテムの使用者
  # item : アイテム
  #
  def item_growth_effect(user, item)
    if item.parameter_type > 0 and item.parameter_points != 0
      case item.parameter_type
      when 1  # MaxHP
        @maxhp_plus += item.parameter_points
      when 2  # MaxMP
        @maxmp_plus += item.parameter_points
      when 3  # 攻撃力
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
  # スリップダメージの効果適用
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
