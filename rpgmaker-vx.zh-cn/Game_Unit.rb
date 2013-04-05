#
# 处理成员的类。
# 这个类是作为Game_Party类和Game_Troop类的超级类而使用。
#

class Game_Unit
  #
  # 初始化对象
  #
  #
  def initialize
  end
  #
  # 取得成员 (重新定义子类)
  #
  #
  def members
    return []
  end
  #
  # 取得生存成员的序列
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
  # 取得战斗不能成员的序列
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
  # 全体成员的战斗行动序列
  #
  #
  def clear_actions
    for battler in members
      battler.action.clear
    end
  end
  #
  # 随机目标确定
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
  # 随机目标确定（战斗不能）
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
  # 随机目标确定
  #
  # index : 索引
  #
  def smooth_target(index)
    member = members[index]
    return member if member != nil and member.exist?
    return existing_members[0]
  end
  #
  # 随机目标确定（战斗不能）
  #
  # index : 索引
  #
  def smooth_dead_target(index)
    member = members[index]
    return member if member != nil and member.dead?
    return dead_members[0]
  end
  #
  # 计算敏捷性平均值
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
  # 应用连续伤害效果
  #
  #
  def slip_damage_effect
    for member in members
      member.slip_damage_effect
    end
  end
end
