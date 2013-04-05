#
# 名前入力画面の処理を行うクラスです。
#

class Scene_Name < Scene_Base
  #
  # 開始処理
  #
  #
  def start
    super
    create_menu_background
    @actor = $game_actors[$game_temp.name_actor_id]
    @edit_window = Window_NameEdit.new(@actor, $game_temp.name_max_char)
    @input_window = Window_NameInput.new
  end
  #
  # 終了処理
  #
  #
  def terminate
    super
    dispose_menu_background
    @edit_window.dispose
    @input_window.dispose
  end
  #
  # 元の画面へ戻る
  #
  #
  def return_scene
    $scene = Scene_Map.new
  end
  #
  # フレーム更新
  #
  #
  def update
    super
    update_menu_background
    @edit_window.update
    @input_window.update
    if Input.repeat?(Input::B)
      if @edit_window.index > 0             # 文字位置が左端ではない
        Sound.play_cancel
        @edit_window.back
      end
    elsif Input.trigger?(Input::C)
      if @input_window.is_decision          # カーソル位置が [決定] の場合
        if @edit_window.name == ""          # 名前が空の場合
          @edit_window.restore_default      # デフォルトの名前に戻す
          if @edit_window.name == ""
            Sound.play_buzzer
          else
            Sound.play_decision
          end
        else
          Sound.play_decision
          @actor.name = @edit_window.name   # アクターの名前を変更
          return_scene
        end
      elsif @input_window.character != ""   # 文字が空ではない場合
        if @edit_window.index == @edit_window.max_char    # 文字位置が右端
          Sound.play_buzzer
        else
          Sound.play_decision
          @edit_window.add(@input_window.character)       # 文字を追加
        end
      end
    end
  end
end
