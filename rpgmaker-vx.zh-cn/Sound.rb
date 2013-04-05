#
# 演奏音效的模块。
# 取得数据库中关于SE的设定，赋予全局变量 $data_system ， 并演奏。
#

module Sound

  # 移动光标
  def self.play_cursor
    $data_system.sounds[0].play
  end

  # 决定
  def self.play_decision
    $data_system.sounds[1].play
  end

  # 取消
  def self.play_cancel
    $data_system.sounds[2].play
  end

  # 错误
  def self.play_buzzer
    $data_system.sounds[3].play
  end

  # 装备
  def self.play_equip
    $data_system.sounds[4].play
  end

  # 保存
  def self.play_save
    $data_system.sounds[5].play
  end

  # 读取
  def self.play_load
    $data_system.sounds[6].play
  end

  # 战斗开始
  def self.play_battle_start
    $data_system.sounds[7].play
  end

  # 逃走
  def self.play_escape
    $data_system.sounds[8].play
  end

  # 敌人的一般攻击
  def self.play_enemy_attack
    $data_system.sounds[9].play
  end

  # 敌人受到伤害
  def self.play_enemy_damage
    $data_system.sounds[10].play
  end

  # 敌人被消灭
  def self.play_enemy_collapse
    $data_system.sounds[11].play
  end

  # 我方受到伤害
  def self.play_actor_damage
    $data_system.sounds[12].play
  end

  # 我方战斗不能
  def self.play_actor_collapse
    $data_system.sounds[13].play
  end

  # 回復
  def self.play_recovery
    $data_system.sounds[14].play
  end

  # Miss
  def self.play_miss
    $data_system.sounds[15].play
  end

  # 攻击回避
  def self.play_evasion
    $data_system.sounds[16].play
  end

  # 商店
  def self.play_shop
    $data_system.sounds[17].play
  end

  # 适用道具
  def self.play_use_item
    $data_system.sounds[18].play
  end

  # 适用技能
  def self.play_use_skill
    $data_system.sounds[19].play
  end

end
