#
# 处理调试画面的类。
#

class Scene_Debug
  #
  # 主处理
  #
  #
  def main
    # 生成窗口
    @left_window = Window_DebugLeft.new
    @right_window = Window_DebugRight.new
    @help_window = Window_Base.new(192, 352, 448, 128)
    @help_window.contents = Bitmap.new(406, 96)
    # 还原为上次选择的项目
    @left_window.top_row = $game_temp.debug_top_row
    @left_window.index = $game_temp.debug_index
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
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
      # 如果画面被切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 刷新地图
    $game_map.refresh
    # 装备过渡
    Graphics.freeze
    # 释放窗口
    @left_window.dispose
    @right_window.dispose
    @help_window.dispose
  end
  #
  # 刷新画面
  #
  #
  def update
    # 刷新窗口
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
    @left_window.update
    @right_window.update
    # 记忆选择中的项目
    $game_temp.debug_top_row = @left_window.top_row
    $game_temp.debug_index = @left_window.index
    # 左侧窗口被激活的情况下: 调用 update_left
    if @left_window.active
      update_left
      return
    end
    # 右侧窗口被激活的情况下: 调用 update_right
    if @right_window.active
      update_right
      return
    end
  end
  #
  # 刷新画面 (左侧窗口被激活的情况下)
  #
  #
  def update_left
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到地图画面
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 显示帮助
      if @left_window.mode == 0
        text1 = "C (Enter) : ON / OFF"
        @help_window.contents.draw_text(4, 0, 406, 32, text1)
      else
        text1 = "← : -1   → : +1"
        text2 = "L (Pageup) : -10"
        text3 = "R (Pagedown) : +10"
        @help_window.contents.draw_text(4, 0, 406, 32, text1)
        @help_window.contents.draw_text(4, 32, 406, 32, text2)
        @help_window.contents.draw_text(4, 64, 406, 32, text3)
      end
      # 激活右侧窗口
      @left_window.active = false
      @right_window.active = true
      @right_window.index = 0
      return
    end
  end
  #
  # 刷新画面 (右侧窗口被激活的情况下)
  #
  #
  def update_right
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 激活左侧窗口
      @left_window.active = true
      @right_window.active = false
      @right_window.index = -1
      # 删除帮助
      @help_window.contents.clear
      return
    end
    # 获取被选择的开关 / 变量的 ID
    current_id = @right_window.top_id + @right_window.index
    # 开关的情况下
    if @right_window.mode == 0
      # 按下 C 键的情况下
      if Input.trigger?(Input::C)
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 逆转 ON / OFF 状态
        $game_switches[current_id] = (not $game_switches[current_id])
        @right_window.refresh
        return
      end
    end
    # 变量的情况下
    if @right_window.mode == 1
      # 按下右键的情况下
      if Input.repeat?(Input::RIGHT)
        # 演奏光标 SE
        $game_system.se_play($data_system.cursor_se)
        # 变量加 1
        $game_variables[current_id] += 1
        # 检查上限
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        end
        @right_window.refresh
        return
      end
      # 按下左键的情况下
      if Input.repeat?(Input::LEFT)
        # 演奏光标 SE
        $game_system.se_play($data_system.cursor_se)
        # 变量减 1
        $game_variables[current_id] -= 1
        # 检查下限
        if $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        @right_window.refresh
        return
      end
      # 按下 R 键的情况下
      if Input.repeat?(Input::R)
        # 演奏光标 SE
        $game_system.se_play($data_system.cursor_se)
        # 变量加 10
        $game_variables[current_id] += 10
        # 检查上限
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        end
        @right_window.refresh
        return
      end
      # 按下 L 键的情况下
      if Input.repeat?(Input::L)
        # 演奏光标 SE
        $game_system.se_play($data_system.cursor_se)
        # 变量减 10
        $game_variables[current_id] -= 10
        # 检查下限
        if $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        @right_window.refresh
        return
      end
    end
  end
end
