#
# 处理游戏结束画面的类。
#

class Scene_Gameover
  #
  # 主处理
  #
  #
  def main
    # 生成游戏结束图形
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.gameover($data_system.gameover_name)
    # 停止 BGM、BGS
    $game_system.bgm_play(nil)
    $game_system.bgs_play(nil)
    # 演奏游戏结束 ME
    $game_system.me_play($data_system.gameover_me)
    # 执行过渡
    Graphics.transition(120)
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面情报
      update
      # 如果画面被切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放游戏结束图形
    @sprite.bitmap.dispose
    @sprite.dispose
    # 执行过度
    Graphics.transition(40)
    # 准备过渡
    Graphics.freeze
    # 战斗测试的情况下
    if $BTEST
      $scene = nil
    end
  end
  #
  # 刷新画面
  #
  #
  def update
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 切换到标题画面
      $scene = Scene_Title.new
    end
  end
end
