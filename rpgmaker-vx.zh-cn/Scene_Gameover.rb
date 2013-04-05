#
# 处理游戏结束画面的类。
#

class Scene_Gameover < Scene_Base
  #
  # 开始处理
  #
  #
  def start
    super
    RPG::BGM.stop
    RPG::BGS.stop
    $data_system.gameover_me.play
    Graphics.transition(120)
    Graphics.freeze
    create_gameover_graphic
  end
  #
  # 结束处理
  #
  #
  def terminate
    super
    dispose_gameover_graphic
    $scene = nil if $BTEST
  end
  #
  # 刷新画面
  #
  #
  def update
    super
    if Input.trigger?(Input::C)
      $scene = Scene_Title.new
      Graphics.fadeout(120)
    end
  end
  #
  # 执行过渡
  #
  #
  def perform_transition
    Graphics.transition(180)
  end
  #
  # 作成Gameover图像
  #
  #
  def create_gameover_graphic
    @sprite = Sprite.new
    @sprite.bitmap = Cache.system("GameOver")
  end
  #
  # 释放Gameover图像
  #
  #
  def dispose_gameover_graphic
    @sprite.bitmap.dispose
    @sprite.dispose
  end
end
