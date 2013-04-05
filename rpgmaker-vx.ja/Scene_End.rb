#
# ゲーム終了画面の処理を行うクラスです。
#

class Scene_End < Scene_Base
  #
  # 開始処理
  #
  #
  def start
    super
    create_menu_background
    create_command_window
  end
  #
  # 開始後処理
  #
  #
  def post_start
    super
    open_command_window
  end
  #
  # 終了前処理
  #
  #
  def pre_terminate
    super
    close_command_window
  end
  #
  # 終了処理
  #
  #
  def terminate
    super
    dispose_command_window
    dispose_menu_background
  end
  #
  # 元の画面へ戻る
  #
  #
  def return_scene
    $scene = Scene_Menu.new(5)
  end
  #
  # フレーム更新
  #
  #
  def update
    super
    update_menu_background
    @command_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::C)
      case @command_window.index
      when 0  # タイトルへ
        command_to_title
      when 1  # シャットダウン
        command_shutdown
      when 2  # やめる
        command_cancel
      end
    end
  end
  #
  # メニュー画面系の背景更新
  #
  #
  def update_menu_background
    super
    @menuback_sprite.tone.set(0, 0, 0, 128)
  end
  #
  # コマンドウィンドウの作成
  #
  #
  def create_command_window
    s1 = Vocab::to_title
    s2 = Vocab::shutdown
    s3 = Vocab::cancel
    @command_window = Window_Command.new(172, [s1, s2, s3])
    @command_window.x = (544 - @command_window.width) / 2
    @command_window.y = (416 - @command_window.height) / 2
    @command_window.openness = 0
  end
  #
  # コマンドウィンドウの解放
  #
  #
  def dispose_command_window
    @command_window.dispose
  end
  #
  # コマンドウィンドウを開く
  #
  #
  def open_command_window
    @command_window.open
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 255
  end
  #
  # コマンドウィンドウを閉じる
  #
  #
  def close_command_window
    @command_window.close
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 0
  end
  #
  # コマンド [タイトルへ] 選択時の処理
  #
  #
  def command_to_title
    Sound.play_decision
    RPG::BGM.fade(800)
    RPG::BGS.fade(800)
    RPG::ME.fade(800)
    $scene = Scene_Title.new
    close_command_window
    Graphics.fadeout(60)
  end
  #
  # コマンド [シャットダウン] 選択時の処理
  #
  #
  def command_shutdown
    Sound.play_decision
    RPG::BGM.fade(800)
    RPG::BGS.fade(800)
    RPG::ME.fade(800)
    $scene = nil
  end
  #
  # コマンド [やめる] 選択時の処理
  #
  #
  def command_cancel
    Sound.play_decision
    return_scene
  end
end
