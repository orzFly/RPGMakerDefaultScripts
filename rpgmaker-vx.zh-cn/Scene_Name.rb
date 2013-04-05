#
# 处理姓名输入画面的类。
#

class Scene_Name < Scene_Base
  #
  # 开始处理
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
  # 结束处理
  #
  #
  def terminate
    super
    dispose_menu_background
    @edit_window.dispose
    @input_window.dispose
  end
  #
  # 返回前一个画面
  #
  #
  def return_scene
    $scene = Scene_Map.new
  end
  #
  # 刷新画面
  #
  #
  def update
    super
    update_menu_background
    @edit_window.update
    @input_window.update
    if Input.repeat?(Input::B)
      if @edit_window.index > 0             # 文字位置不在左端
        Sound.play_cancel
        @edit_window.back
      end
    elsif Input.trigger?(Input::C)
      if @input_window.is_decision          # 光标位置在 [决定] 的情况
        if @edit_window.name == ""          # 姓名为空的情况
          @edit_window.restore_default      # 返回默认姓名
          if @edit_window.name == ""
            Sound.play_buzzer
          else
            Sound.play_decision
          end
        else
          Sound.play_decision
          @actor.name = @edit_window.name   # 变更角色姓名
          return_scene
        end
      elsif @input_window.character != ""   # 文字不为空的情况
        if @edit_window.index == @edit_window.max_char    # 文字位置在右端
          Sound.play_buzzer
        else
          Sound.play_decision
          @edit_window.add(@input_window.character)       # 追加文字
        end
      end
    end
  end
end
