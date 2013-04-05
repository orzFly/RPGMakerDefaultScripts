#
# ゲームオーバー画面の処理を行うクラスです。
#

class Scene_Gameover < Scene_Base
  #
  # 開始処理
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
  # 終了処理
  #
  #
  def terminate
    super
    dispose_gameover_graphic
    $scene = nil if $BTEST
  end
  #
  # フレーム更新
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
  # トランジション実行
  #
  #
  def perform_transition
    Graphics.transition(180)
  end
  #
  # ゲームオーバーグラフィックの作成
  #
  #
  def create_gameover_graphic
    @sprite = Sprite.new
    @sprite.bitmap = Cache.system("GameOver")
  end
  #
  # ゲームオーバーグラフィックの解放
  #
  #
  def dispose_gameover_graphic
    @sprite.bitmap.dispose
    @sprite.dispose
  end
end
