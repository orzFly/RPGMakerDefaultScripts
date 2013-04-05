#
# 战斗画面，行动对象选择敌人的窗口
#

class Window_TargetEnemy < Window_Command
  #
  # 初始化对像
  #
  #
  def initialize
    commands = []
    @enemies = []
    for enemy in $game_troop.members
      next unless enemy.exist?
      commands.push(enemy.name)
      @enemies.push(enemy)
    end
    super(416, commands, 2, 4)
  end
  #
  # 获取敌人
  #
  #
  def enemy
    return @enemies[@index]
  end
end
