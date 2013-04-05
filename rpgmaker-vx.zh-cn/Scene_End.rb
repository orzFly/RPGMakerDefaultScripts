#
# 处理游戏结束画面的类。
#

class Scene_End < Scene_Base
  #
  # 开始处理
  #
  #
  def start
    super
    create_menu_background
    create_command_window
  end
  #
  # 开始后处理
  #
  #
  def post_start
    super
    open_command_window
  end
  #
  # 结束前处理
  #
  #
  def pre_terminate
    super
    close_command_window
  end
  #
  # 结束处理
  #
  #
  def terminate
    super
    dispose_command_window
    dispose_menu_background
  end
  #
  # 返回前一个画面
  #
  #
  def return_scene
    $scene = Scene_Menu.new(5)
  end
  #
  # 刷新画面
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
      when 0  # 返回标题
        command_to_title
      when 1  # 关闭游戏
        command_shutdown
      when 2  # 取消
        command_cancel
      end
    end
  end
  #
  # 刷新菜单画面背景
  #
  #
  def update_menu_background
    super
    @menuback_sprite.tone.set(0, 0, 0, 128)
  end
  #
  # 生成指令窗口
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
  # 释放指令窗口
  #
  #
  def dispose_command_window
    @command_window.dispose
  end
  #
  # 打开指令窗口
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
  # 关闭指令窗口
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
  # 指令 [返回标题] 选项时的处理
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
  # 指令 [关闭游戏] 选项时候的处理
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
  # 指令 [取消] 选项时候的处理
  #
  #
  def command_cancel
    Sound.play_decision
    return_scene
  end
end
