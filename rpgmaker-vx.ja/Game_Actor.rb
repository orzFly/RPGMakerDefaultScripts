#
# アクターを扱うクラスです。このクラスは Game_Actors クラス ($game_actors)
# の内部で使用され、Game_Party クラス ($game_party) からも参照されます。
#

class Game_Actor < Game_Battler
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :name                     # 名前
  attr_reader   :character_name           # 歩行グラフィック ファイル名
  attr_reader   :character_index          # 歩行グラフィック インデックス
  attr_reader   :face_name                # 顔グラフィック ファイル名
  attr_reader   :face_index               # 顔グラフィック インデックス
  attr_reader   :class_id                 # 職業 ID
  attr_reader   :weapon_id                # 武器 ID
  attr_reader   :armor1_id                # 盾 ID
  attr_reader   :armor2_id                # 頭防具 ID
  attr_reader   :armor3_id                # 体防具 ID
  attr_reader   :armor4_id                # 装飾品 ID
  attr_reader   :level                    # レベル
  attr_reader   :exp                      # 経験値
  attr_accessor :last_skill_id            # カーソル記憶用 : スキル
  #
  # オブジェクト初期化
  #
  # actor_id : アクター ID
  #
  def initialize(actor_id)
    super()
    setup(actor_id)
    @last_skill_id = 0
  end
  #
  # セットアップ
  #
  # actor_id : アクター ID
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
  # アクターか否かの判定
  #
  #
  def actor?
    return true
  end
  #
  # アクター ID 取得
  #
  #
  def id
    return @actor_id
  end
  #
  # インデックス取得
  #
  #
  def index
    return $game_party.members.index(self)
  end
  #
  # アクターオブジェクト取得
  #
  #
  def actor
    return $data_actors[@actor_id]
  end
  #
  # 職業オブジェクト取得
  #
  #
  def class
    return $data_classes[@class_id]
  end
  #
  # スキルオブジェクトの配列取得
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
  # 武器オブジェクトの配列取得
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
  # 防具オブジェクトの配列取得
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
  # 装備品オブジェクトの配列取得
  #
  #
  def equips
    return weapons + armors
  end
  #
  # 経験値計算
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
  # 属性修正値の取得
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
  # ステートの付加成功率の取得
  #
  # state_id : ステート ID
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
  # ステート無効化判定
  #
  # state_id : ステート ID
  #
  def state_resist?(state_id)
    for armor in armors.compact
      return true if armor.state_set.include?(state_id)
    end
    return false
  end
  #
  # 通常攻撃の属性取得
  #
  #
  def element_set
    result = []
    if weapons.compact == []
      return [1]                  # 素手：格闘属性
    end
    for weapon in weapons.compact
      result |= weapon == nil ? [] : weapon.element_set
    end
    return result
  end
  #
  # 通常攻撃の追加効果 (ステート変化) 取得
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
  # MaxHP の制限値取得
  #
  #
  def maxhp_limit
    return 9999
  end
  #
  # 基本 MaxHP の取得
  #
  #
  def base_maxhp
    return actor.parameters[0, @level]
  end
  #
  # 基本 MaxMP の取得
  #
  #
  def base_maxmp
    return actor.parameters[1, @level]
  end
  #
  # 基本攻撃力の取得
  #
  #
  def base_atk
    n = actor.parameters[2, @level]
    for item in equips.compact do n += item.atk end
    return n
  end
  #
  # 基本防御力の取得
  #
  #
  def base_def
    n = actor.parameters[3, @level]
    for item in equips.compact do n += item.def end
    return n
  end
  #
  # 基本精神力の取得
  #
  #
  def base_spi 
    n = actor.parameters[4, @level]
    for item in equips.compact do n += item.spi end
    return n
  end
  #
  # 基本敏捷性の取得
  #
  #
  def base_agi
    n = actor.parameters[5, @level]
    for item in equips.compact do n += item.agi end
    return n
  end
  #
  # 命中率の取得
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
  # 回避率の取得
  #
  #
  def eva
    n = 5
    for item in armors.compact do n += item.eva end
    return n
  end
  #
  # クリティカル率の取得
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
  # 狙われやすさの取得
  #
  #
  def odds
    return 4 - self.class.position
  end
  #
  # オプション [二刀流] の取得
  #
  #
  def two_swords_style
    return actor.two_swords_style
  end
  #
  # オプション [装備固定] の取得
  #
  #
  def fix_equipment
    return actor.fix_equipment
  end
  #
  # オプション [自動戦闘] の取得
  #
  #
  def auto_battle
    return actor.auto_battle
  end
  #
  # オプション [強力防御] の取得
  #
  #
  def super_guard
    return actor.super_guard
  end
  #
  # オプション [薬の知識] の取得
  #
  #
  def pharmacology
    return actor.pharmacology
  end
  #
  # 武器オプション [ターン内先制] の取得
  #
  #
  def fast_attack
    for weapon in weapons.compact
      return true if weapon.fast_attack
    end
    return false
  end
  #
  # 武器オプション [連続攻撃] の取得
  #
  #
  def dual_attack
    for weapon in weapons.compact
      return true if weapon.dual_attack
    end
    return false
  end
  #
  # 防具オプション [クリティカル防止] の取得
  #
  #
  def prevent_critical
    for armor in armors.compact
      return true if armor.prevent_critical
    end
    return false
  end
  #
  # 防具オプション [消費 MP 半分] の取得
  #
  #
  def half_mp_cost
    for armor in armors.compact
      return true if armor.half_mp_cost
    end
    return false
  end
  #
  # 防具オプション [取得経験値 2 倍] の取得
  #
  #
  def double_exp_gain
    for armor in armors.compact
      return true if armor.double_exp_gain
    end
    return false
  end
  #
  # 防具オプション [HP 自動回復] の取得
  #
  #
  def auto_hp_recover
    for armor in armors.compact
      return true if armor.auto_hp_recover
    end
    return false
  end
  #
  # 通常攻撃 アニメーション ID の取得
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
  # 通常攻撃 アニメーション ID の取得 (二刀流：武器２)
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
  # 経験値の文字列取得
  #
  #
  def exp_s
    return @exp_list[@level+1] > 0 ? @exp : "-------"
  end
  #
  # 次のレベルの経験値の文字列取得
  #
  #
  def next_exp_s
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1] : "-------"
  end
  #
  # 次のレベルまでの経験値の文字列取得
  #
  #
  def next_rest_exp_s
    return @exp_list[@level+1] > 0 ?
      (@exp_list[@level+1] - @exp) : "-------"
  end
  #
  # 装備の変更 (ID で指定)
  #
  # equip_type : 装備部位 (0..4)
  # item_id    : 武器 ID or 防具 ID
  # test       : テストフラグ (戦闘テスト、または装備画面での一時装備)
  # イベントコマンド、および戦闘テストの準備で使用する。
  #
  def change_equip_by_id(equip_type, item_id, test = false)
    if equip_type == 0 or (equip_type == 1 and two_swords_style)
      change_equip(equip_type, $data_weapons[item_id], test)
    else
      change_equip(equip_type, $data_armors[item_id], test)
    end
  end
  #
  # 装備の変更 (オブジェクトで指定)
  #
  # equip_type : 装備部位 (0..4)
  # item       : 武器 or 防具 (nil なら装備解除)
  # test       : テストフラグ (戦闘テスト、または装備画面での一時装備)
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
      unless two_hands_legal?             # 両手持ち違反の場合
        change_equip(1, nil, test)        # 逆の手の装備を外す
      end
    when 1  # 盾
      @armor1_id = item_id
      unless two_hands_legal?             # 両手持ち違反の場合
        change_equip(0, nil, test)        # 逆の手の装備を外す
      end
    when 2  # 頭
      @armor2_id = item_id
    when 3  # 身体
      @armor3_id = item_id
    when 4  # 装飾品
      @armor4_id = item_id
    end
  end
  #
  # 装備の破棄
  #
  # item : 破棄する武器 or 防具
  # 武器／防具の増減で「装備品も含める」のとき使用する。
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
  # 両手装備合法判定
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
  # 装備可能判定
  #
  # item : アイテム
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
  # 経験値の変更
  #
  # exp  : 新しい経験値
  # show : レベルアップ表示フラグ
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
  # レベルアップ
  #
  #
  def level_up
    @level += 1
    for learning in self.class.learnings
      learn_skill(learning.skill_id) if learning.level == @level
    end
  end
  #
  # レベルダウン
  #
  #
  def level_down
    @level -= 1
  end
  #
  # レベルアップメッセージの表示
  #
  # new_skills : 新しく習得したスキルの配列
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
  # 経験値の獲得 (経験値 2 倍のオプションを考慮)
  #
  # exp  : 経験値の増加量
  # show : レベルアップ表示フラグ
  #
  def gain_exp(exp, show)
    if double_exp_gain
      change_exp(@exp + exp * 2, show)
    else
      change_exp(@exp + exp, show)
    end
  end
  #
  # レベルの変更
  #
  # level : 新しいレベル
  # show  : レベルアップ表示フラグ
  #
  def change_level(level, show)
    level = [[level, 99].min, 1].max
    change_exp(@exp_list[level], show)
  end
  #
  # スキルを覚える
  #
  # skill_id : スキル ID
  #
  def learn_skill(skill_id)
    unless skill_learn?($data_skills[skill_id])
      @skills.push(skill_id)
      @skills.sort!
    end
  end
  #
  # スキルを忘れる
  #
  # skill_id : スキル ID
  #
  def forget_skill(skill_id)
    @skills.delete(skill_id)
  end
  #
  # スキルの習得済み判定
  #
  # skill : スキル
  #
  def skill_learn?(skill)
    return @skills.include?(skill.id)
  end
  #
  # スキルの使用可能判定
  #
  # skill : スキル
  #
  def skill_can_use?(skill)
    return false unless skill_learn?(skill)
    return super
  end
  #
  # 名前の変更
  #
  # name : 新しい名前
  #
  def name=(name)
    @name = name
  end
  #
  # 職業 ID の変更
  #
  # class_id : 新しい職業 ID
  #
  def class_id=(class_id)
    @class_id = class_id
    for i in 0..4     # 装備できない装備品を外す
      change_equip(i, nil) unless equippable?(equips[i])
    end
  end
  #
  # グラフィックの変更
  #
  # character_name  : 新しい歩行グラフィック ファイル名
  # character_index : 新しい歩行グラフィック インデックス
  # face_name       : 新しい顔グラフィック ファイル名
  # face_index      : 新しい顔グラフィック インデックス
  #
  def set_graphic(character_name, character_index, face_name, face_index)
    @character_name = character_name
    @character_index = character_index
    @face_name = face_name
    @face_index = face_index
  end
  #
  # スプライトを使うか？
  #
  #
  def use_sprite?
    return false
  end
  #
  # コラプスの実行
  #
  #
  def perform_collapse
    if $game_temp.in_battle and dead?
      @collapse = true
      Sound.play_actor_collapse
    end
  end
  #
  # 自動回復の実行 (ターン終了時に呼び出し)
  #
  #
  def do_auto_recovery
    if auto_hp_recover and not dead?
      self.hp += maxhp / 20
    end
  end
  #
  # 戦闘行動の作成 (自動戦闘用)
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
