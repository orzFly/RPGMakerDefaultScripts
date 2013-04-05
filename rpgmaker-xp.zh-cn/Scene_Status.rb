#
# 处理状态画面的类。
#

class Scene_Status
  #
  # 初始化对像
  #
  # actor_index : 角色索引
  #
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
  end
  #
  # 主处理
  #
  #
  def main
    # 获取角色
    @actor = $game_party.actors[@actor_index]
    # 生成状态窗口
    @status_window = Window_Status.new(@actor)
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面被切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @status_window.dispose
  end
  #
  # 刷新画面
  #
  #
  def update
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到菜单画面
      $scene = Scene_Menu.new(3)
      return
    end
    # 按下 R 键的情况下
    if Input.trigger?(Input::R)
      # 演奏光标 SE
      $game_system.se_play($data_system.cursor_se)
      # 移至下一位角色
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      # 切换到别的状态画面
      $scene = Scene_Status.new(@actor_index)
      return
    end
    # 按下 L 键的情况下
    if Input.trigger?(Input::L)
      # 演奏光标 SE
      $game_system.se_play($data_system.cursor_se)
      # 移至上一位角色
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      # 切换到别的状态画面
      $scene = Scene_Status.new(@actor_index)
      return
    end
  end
end
