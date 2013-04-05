#encoding:utf-8
#
# 管理游戲單位的類。是 Game_Party 和 Game_Troop 類的父類。
#

class Game_Unit
  #
  # 定義案例變量
  #
  #
  attr_reader   :in_battle                # 戰鬥中的標志
  #
  # 初始化物件
  #
  #
  def initialize
    @in_battle = false
  end
  #
  # 取得成員
  #
  #
  def members
    return []
  end
  #
  # 取得存活的成員數組
  #
  #
  def alive_members
    members.select {|member| member.alive? }
  end
  #
  # 取得死亡的成員數組
  #
  #
  def dead_members
    members.select {|member| member.dead? }
  end
  #
  # 取得可以行動的成員數組
  #
  #
  def movable_members
    members.select {|member| member.movable? }
  end
  #
  # 清除全員的戰鬥行為
  #
  #
  def clear_actions
    members.each {|member| member.clear_actions }
  end
  #
  # 計算敏捷值的平均值
  #
  #
  def agi
    return 1 if members.size == 0
    members.inject(0) {|r, member| r += member.agi } / members.size
  end
  #
  # 計算受到攻擊的幾率的總數
  #
  #
  def tgr_sum
    alive_members.inject(0) {|r, member| r + member.tgr }
  end
  #
  # 隨機決定目的
  #
  #
  def random_target
    tgr_rand = rand * tgr_sum
    alive_members.each do |member|
      tgr_rand -= member.tgr
      return member if tgr_rand < 0
    end
    alive_members[0]
  end
  #
  # 隨機決定目的（無法戰鬥）
  #
  #
  def random_dead_target
    dead_members.empty? ? nil : dead_members[rand(dead_members.size)]
  end
  #
  # 決定順帶目的
  #
  # 也就是如果上下目的無效，則取得下一個目的
  #
  def smooth_target(index)
    member = members[index]
    (member && member.alive?) ? member : alive_members[0]
  end
  #
  # 決定順帶目的（無法戰鬥）
  #
  #
  def smooth_dead_target(index)
    member = members[index]
    (member && member.dead?) ? member : dead_members[0]
  end
  #
  # 清除行動結果
  #
  #
  def clear_results
    members.select {|member| member.result.clear }
  end
  #
  # 戰鬥開始處理
  #
  #
  def on_battle_start
    members.each {|member| member.on_battle_start }
    @in_battle = true
  end
  #
  # 戰鬥結束處理
  #
  #
  def on_battle_end
    @in_battle = false
    members.each {|member| member.on_battle_end }
  end
  #
  # 生成戰鬥行動
  #
  #
  def make_actions
    members.each {|member| member.make_actions }
  end
  #
  # 判定是否全滅
  #
  #
  def all_dead?
    alive_members.empty?
  end
  #
  # 取得保護弱者的戰鬥者
  #
  #
  def substitute_battler
    members.find {|member| member.substitute? }
  end
end
