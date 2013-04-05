#
# 处理游戏结束画面的类。
#

class Scene_End
  #
  # 主处理
  #
  #
  def main
    # 生成命令窗口
    s1 = "返回标题画面"
    s2 = "退出"
    s3 = "取消"
    @command_window = Window_Command.new(192, [s1, s2, s3])
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 240 - @command_window.height / 2
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入情报
      Input.update
      # 刷新画面
      update
      # 如果画面切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @command_window.dispose
    # 如果在标题画面切换中的情况下
    if $scene.is_a?(Scene_Title)
      # 淡入淡出画面
      Graphics.transition
      Graphics.freeze
    end
  end
  #
  # 刷新画面
  #
  #
  def update
    # 刷新命令窗口
    @command_window.update
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到菜单画面
      $scene = Scene_Menu.new(5)
      return
    end
    # 按下 C 键的场合下
    if Input.trigger?(Input::C)
      # 命令窗口光标位置分支
      case @command_window.index
      when 0  # 返回标题画面
        command_to_title
      when 1  # 退出
        command_shutdown
      when 2  # 取消
        command_cancel
      end
      return
    end
  end
  #
  # 选择命令 [返回标题画面] 时的处理
  #
  #
  def command_to_title
    # 演奏确定 SE
    $game_system.se_play($data_system.decision_se)
    # 淡入淡出 BGM、BGS、ME
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # 切换到标题画面
    $scene = Scene_Title.new
  end
  #
  # 选择命令 [退出] 时的处理
  #
  #
  def command_shutdown
    # 演奏确定 SE
    $game_system.se_play($data_system.decision_se)
    # 淡入淡出 BGM、BGS、ME
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # 退出
    $scene = nil
  end
  #
  # 选择命令 [取消] 时的处理
  #
  #
  def command_cancel
    # 演奏确定 SE
    $game_system.se_play($data_system.decision_se)
    # 切换到菜单画面
    $scene = Scene_Menu.new(5)
  end
end
