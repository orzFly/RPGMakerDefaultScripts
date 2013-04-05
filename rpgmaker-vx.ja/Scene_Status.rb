#
# ステータス画面の処理を行うクラスです。
#

class Scene_Status < Scene_Base
  #
  # オブジェクト初期化
  #
  # actor_index : アクターインデックス
  #
  def initialize(actor_index = 0)
    @actor_index = actor_index
  end
  #
  # 開始処理
  #
  #
  def start
    super
    create_menu_background
    @actor = $game_party.members[@actor_index]
    @status_window = Window_Status.new(@actor)
  end
  #
  # 終了処理
  #
  #
  def terminate
    super
    dispose_menu_background
    @status_window.dispose
  end
  #
  # 元の画面へ戻る
  #
  #
  def return_scene
    $scene = Scene_Menu.new(3)
  end
  #
  # 次のアクターの画面に切り替え
  #
  #
  def next_actor
    @actor_index += 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Status.new(@actor_index)
  end
  #
  # 前のアクターの画面に切り替え
  #
  #
  def prev_actor
    @actor_index += $game_party.members.size - 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Status.new(@actor_index)
  end
  #
  # フレーム更新
  #
  #
  def update
    update_menu_background
    @status_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::R)
      Sound.play_cursor
      next_actor
    elsif Input.trigger?(Input::L)
      Sound.play_cursor
      prev_actor
    end
    super
  end
end
