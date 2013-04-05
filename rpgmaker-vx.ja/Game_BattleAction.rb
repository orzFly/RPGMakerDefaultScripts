#
# 戦闘行動を扱うクラスです。このクラスは Game_Battler クラスの内部で使用され
# ます。
#

class Game_BattleAction
  #
  # 公開インスタンス変数
  #
  #
  attr_accessor :battler                  # バトラー
  attr_accessor :speed                    # スピード
  attr_accessor :kind                     # 種別 (基本 / スキル / アイテム)
  attr_accessor :basic                    # 基本 (攻撃 / 防御 / 逃走 / 待機)
  attr_accessor :skill_id                 # スキル ID
  attr_accessor :item_id                  # アイテム ID
  attr_accessor :target_index             # 対象インデックス
  attr_accessor :forcing                  # 強制フラグ
  attr_accessor :value                    # 自動戦闘用 評価値
  #
  # オブジェクト初期化
  #
  # battler : バトラー
  #
  def initialize(battler)
    @battler = battler
    clear
  end
  #
  # クリア
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
  # 味方ユニットを取得
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
  # 敵ユニットを取得
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
  # 通常攻撃を設定
  #
  #
  def set_attack
    @kind = 0
    @basic = 0
  end
  #
  # 防御を設定
  #
  #
  def set_guard
    @kind = 0
    @basic = 1
  end
  #
  # スキルを設定
  #
  # skill_id : スキル ID
  #
  def set_skill(skill_id)
    @kind = 1
    @skill_id = skill_id
  end
  #
  # アイテムを設定
  #
  # item_id : アイテム ID
  #
  def set_item(item_id)
    @kind = 2
    @item_id = item_id
  end
  #
  # 通常攻撃判定
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
  # 何もしない行動判定
  #
  #
  def nothing?
    return (@kind == 0 and @basic < 0)
  end
  #
  # スキル判定
  #
  #
  def skill?
    return @kind == 1
  end
  #
  # スキルオブジェクト取得
  #
  #
  def skill
    return skill? ? $data_skills[@skill_id] : nil
  end
  #
  # アイテム判定
  #
  #
  def item?
    return @kind == 2
  end
  #
  # アイテムオブジェクト取得
  #
  #
  def item
    return item? ? $data_items[@item_id] : nil
  end
  #
  # 味方単体用判定
  #
  #
  def for_friend?
    return true if skill? and skill.for_friend?
    return true if item? and item.for_friend?
    return false
  end
  #
  # 戦闘不能の味方単体用判定
  #
  #
  def for_dead_friend?
    return true if skill? and skill.for_dead_friend?
    return true if item? and item.for_dead_friend?
    return false
  end
  #
  # ランダムターゲット
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
  # ラストターゲット
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
  # 行動準備
  #
  #
  def prepare
    if battler.berserker? or battler.confusion?   # 暴走か混乱なら
      set_attack                                  # 通常攻撃に変更
    end
  end
  #
  # 行動が有効か否かの判定
  #
  # イベントコマンドによる [戦闘行動の強制] ではないとき、ステートの制限
  # やアイテム切れなどで予定の行動ができなければ false を返す。
  #
  def valid?
    return false if nothing?                      # 何もしない
    return true if @forcing                       # 行動強制中
    return false unless battler.movable?          # 行動不能
    if skill?                                     # スキル
      return false unless battler.skill_can_use?(skill)
    elsif item?                                   # アイテム
      return false unless friends_unit.item_can_use?(item)
    end
    return true
  end
  #
  # 行動スピードの決定
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
  # ターゲットの配列作成
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
  # 通常攻撃のターゲット作成
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
    if battler.dual_attack      # 連続攻撃
      targets += targets
    end
    return targets.compact
  end
  #
  # スキルまたはアイテムのターゲット作成
  #
  # obj : スキルまたはアイテム
  #
  def make_obj_targets(obj)
    targets = []
    if obj.for_opponent?
      if obj.for_random?
        if obj.for_one?         # 敵単体 ランダム
          number_of_targets = 1
        elsif obj.for_two?      # 敵二体 ランダム
          number_of_targets = 2
        else                    # 敵三体 ランダム
          number_of_targets = 3
        end
        number_of_targets.times do
          targets.push(opponents_unit.random_target)
        end
      elsif obj.dual?           # 敵単体 連続
        targets.push(opponents_unit.smooth_target(@target_index))
        targets += targets
      elsif obj.for_one?        # 敵単体
        targets.push(opponents_unit.smooth_target(@target_index))
      else                      # 敵全体
        targets += opponents_unit.existing_members
      end
    elsif obj.for_user?         # 使用者
      targets.push(battler)
    elsif obj.for_dead_friend?
      if obj.for_one?           # 味方単体 (戦闘不能)
        targets.push(friends_unit.smooth_dead_target(@target_index))
      else                      # 味方全体 (戦闘不能)
        targets += friends_unit.dead_members
      end
    elsif obj.for_friend?
      if obj.for_one?           # 味方単体
        targets.push(friends_unit.smooth_target(@target_index))
      else                      # 味方全体
        targets += friends_unit.existing_members
      end
    end
    return targets.compact
  end
  #
  # 行動の価値評価 (自動戦闘用)
  #
  # `@value` および `@target_index` を自動的に設定する。
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
  # 通常攻撃の評価
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
  # 通常攻撃の評価 (ターゲット指定)
  #
  # target : 対象バトラー
  #
  def evaluate_attack_with_target(target)
    target.clear_action_results
    target.make_attack_damage_value(battler)
    return target.hp_damage.to_f / [target.hp, 1].max
  end
  #
  # スキルの評価
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
  # スキルの評価 (ターゲット指定)
  #
  # target : 対象バトラー
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
