#
# 处理状态画面的类。
#

class Scene_Status < Scene_Base
  #
  # 初始化对像
  #
  # actor_index : 角色索引
  #
  def initialize(actor_index = 0)
    @actor_index = actor_index
  end
  #
  # 开始处理
  #
  #
  def start
    super
    create_menu_background
    @actor = $game_party.members[@actor_index]
    @status_window = Window_Status.new(@actor)
  end
  #
  # 结束处理
  #
  #
  def terminate
    super
    dispose_menu_background
    @status_window.dispose
  end
  #
  # 返回前一个界面
  #
  #
  def return_scene
    $scene = Scene_Menu.new(3)
  end
  #
  # 切换下一个角色的画面
  #
  #
  def next_actor
    @actor_index += 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Status.new(@actor_index)
  end
  #
  # 切换前一个角色的画面
  #
  #
  def prev_actor
    @actor_index += $game_party.members.size - 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Status.new(@actor_index)
  end
  #
  # 刷新画面
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
