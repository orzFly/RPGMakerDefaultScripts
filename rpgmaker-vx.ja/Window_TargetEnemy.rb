#
# バトル画面で、行動対象の敵キャラを選択するウィンドウです。
#

class Window_TargetEnemy < Window_Command
  #
  # オブジェクト初期化
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
  # 敵キャラオブジェクト取得
  #
  #
  def enemy
    return @enemies[@index]
  end
end
