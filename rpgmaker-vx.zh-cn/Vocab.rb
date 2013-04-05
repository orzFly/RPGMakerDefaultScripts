#
# 定义系统用语和信息的模块。利用定量直接定义Message。
# 使用全局变量 $data_system 取得用语资料。
#

module Vocab

  # 商店画面
  ShopBuy         = "买入"
  ShopSell        = "卖出"
  ShopCancel      = "离开"
  Possession      = "持有数"

  # 资料画面
  ExpTotal        = "现在的经验值"
  ExpNext         = "还有 %s 升级"

  # 存档／读档画面
  SaveMessage     = "确定在这个档位保存么？"
  LoadMessage     = "确定在这个档位读取么？"
  File            = "文件"

  # 复数队员的情况
  PartyName       = "%s等人"

  # 战斗基本信息
  Emerge          = "%s出现了！"
  Preemptive      = "%s先制攻击！"
  Surprise        = "%s出其不意！"
  EscapeStart     = "%s逃跑了！"
  EscapeFailure   = "可是没有成功逃跑！"

  # 战斗结束信息
  Victory         = "%s胜利！"
  Defeat          = "%s战败了……"
  ObtainExp       = "获得经验值 %s ！"
  ObtainGold      = "获得 %s%s 金钱！"
  ObtainItem      = "获得了 %s ！"
  LevelUp         = "%s的%s提升到 %s ！"
  ObtainSkill     = "%s学会了！"

  # 战斗行动
  DoAttack        = "%s攻击！"
  DoGuard         = "%s进行防御。"
  DoEscape        = "%s逃跑。"
  DoWait          = "%s先观察一下情况。"
  UseItem         = "%s使用 %s ！"

  # 特别攻击效果
  CriticalToEnemy = "会心一击！！"
  CriticalToActor = "遭到痛恨的一击！！"

  # 角色对象的行动结果
  ActorDamage     = "%s受到 %s 的伤害！"
  ActorLoss       = "%s的%s减少了 %s ！"
  ActorDrain      = "%s的%s被夺去了 %s ！"
  ActorNoDamage   = "%s并没有受到伤害！"
  ActorNoHit      = "Miss！%s并没有受到攻击！"
  ActorEvasion    = "%s躲过了攻击！"
  ActorRecovery   = "%s的%s恢复了 %s ！"

  # 敌人对象的行动结果
  EnemyDamage     = "给予 %s %s 伤害！"
  EnemyLoss       = "%s的%s减少了 %s ！"
  EnemyDrain      = "%s的%s被夺去了 %s ！"
  EnemyNoDamage   = "%s并没有受到伤害！"
  EnemyNoHit      = "Miss！%s并没有受到攻击！"
  EnemyEvasion    = "%s躲过了攻击！"
  EnemyRecovery   = "%s的%s恢复了 %s ！"

  # 物理攻击以外的技能、道具等效果无效
  ActionFailure   = "%s并没产生效果！"

  # 等级
  def self.level
    return $data_system.terms.level
  end

  # 等级 (略)
  def self.level_a
    return $data_system.terms.level_a
  end

  # HP
  def self.hp
    return $data_system.terms.hp
  end

  # HP (略)
  def self.hp_a
    return $data_system.terms.hp_a
  end

  # MP
  def self.mp
    return $data_system.terms.mp
  end

  # MP (略)
  def self.mp_a
    return $data_system.terms.mp_a
  end

  # 攻击力
  def self.atk
    return $data_system.terms.atk
  end

  # 防御力
  def self.def
    return $data_system.terms.def
  end

  # 精神力
  def self.spi
    return $data_system.terms.spi
  end

  # 敏捷性
  def self.agi
    return $data_system.terms.agi
  end

  # 武器
  def self.weapon
    return $data_system.terms.weapon
  end

  # 盾
  def self.armor1
    return $data_system.terms.armor1
  end

  # 头
  def self.armor2
    return $data_system.terms.armor2
  end

  # 身体
  def self.armor3
    return $data_system.terms.armor3
  end

  # 装饰品
  def self.armor4
    return $data_system.terms.armor4
  end

  # 武器 1
  def self.weapon1
    return $data_system.terms.weapon1
  end

  # 武器 2
  def self.weapon2
    return $data_system.terms.weapon2
  end

  # 攻击
  def self.attack
    return $data_system.terms.attack
  end

  # 技能
  def self.skill
    return $data_system.terms.skill
  end

  # 防御
  def self.guard
    return $data_system.terms.guard
  end

  # 道具
  def self.item
    return $data_system.terms.item
  end

  # 装备
  def self.equip
    return $data_system.terms.equip
  end

  # 状态
  def self.status
    return $data_system.terms.status
  end

  # 保存
  def self.save
    return $data_system.terms.save
  end

  # 游戏结束
  def self.game_end
    return $data_system.terms.game_end
  end

  # 战斗
  def self.fight
    return $data_system.terms.fight
  end

  # 逃跑
  def self.escape
    return $data_system.terms.escape
  end

  # 新的游戏
  def self.new_game
    return $data_system.terms.new_game
  end

  # 继续游戏
  def self.continue
    return $data_system.terms.continue
  end

  # 离开游戏
  def self.shutdown
    return $data_system.terms.shutdown
  end

  # 往标题
  def self.to_title
    return $data_system.terms.to_title
  end

  # 取消
  def self.cancel
    return $data_system.terms.cancel
  end

  # G (货币单位)
  def self.gold
    return $data_system.terms.gold
  end

end
