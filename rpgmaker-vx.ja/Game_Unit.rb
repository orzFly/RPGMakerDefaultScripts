#
# ユニットを扱うクラスです。このクラスは Game_Party クラスと Game_Troop クラ
# スのスーパークラスとして使用されます。
#

class Game_Unit
  #
  # オブジェクト初期化
  #
  #
  def initialize
  end
  #
  # メンバーの取得 (サブクラスで再定義)
  #
  #
  def members
    return []
  end
  #
  # 生存しているメンバーの配列取得
  #
  #
  def existing_members
    result = []
    for battler in members
      next unless battler.exist?
      result.push(battler)
    end
    return result
  end
  #
  # 戦闘不能のメンバーの配列取得
  #
  #
  def dead_members
    result = []
    for battler in members
      next unless battler.dead?
      result.push(battler)
    end
    return result
  end
  #
  # 全員の戦闘行動クリア
  #
  #
  def clear_actions
    for battler in members
      battler.action.clear
    end
  end
  #
  # ターゲットのランダムな決定
  #
  #
  def random_target
    roulette = []
    for member in existing_members
      member.odds.times do
        roulette.push(member)
      end
    end
    return roulette.size > 0 ? roulette[rand(roulette.size)] : nil
  end
  #
  # ターゲットのランダムな決定 (戦闘不能)
  #
  #
  def random_dead_target
    roulette = []
    for member in dead_members
      roulette.push(member)
    end
    return roulette.size > 0 ? roulette[rand(roulette.size)] : nil
  end
  #
  # ターゲットのスムーズな決定
  #
  # index : インデックス
  #
  def smooth_target(index)
    member = members[index]
    return member if member != nil and member.exist?
    return existing_members[0]
  end
  #
  # ターゲットのスムーズな決定 (戦闘不能)
  #
  # index : インデックス
  #
  def smooth_dead_target(index)
    member = members[index]
    return member if member != nil and member.dead?
    return dead_members[0]
  end
  #
  # 敏捷性平均値の計算
  #
  #
  def average_agi
    result = 0
    n = 0
    for member in members
      result += member.agi
      n += 1
    end
    result /= n if n > 0
    result = 1 if result == 0
    return result
  end
  #
  # スリップダメージの効果適用
  #
  #
  def slip_damage_effect
    for member in members
      member.slip_damage_effect
    end
  end
end
