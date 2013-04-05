#
# 处理特技画面的类。
#

class Scene_Skill
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
    # 生成帮助窗口、状态窗口、特技窗口
    @help_window = Window_Help.new
    @status_window = Window_SkillStatus.new(@actor)
    @skill_window = Window_Skill.new(@actor)
    # 关联帮助窗口
    @skill_window.help_window = @help_window
    # 生成目标窗口 (设置为不可见・不活动)
    @target_window = Window_Target.new
    @target_window.visible = false
    @target_window.active = false
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
      # 如果画面切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @help_window.dispose
    @status_window.dispose
    @skill_window.dispose
    @target_window.dispose
  end
  #
  # 刷新画面
  #
  #
  def update
    # 刷新窗口
    @help_window.update
    @status_window.update
    @skill_window.update
    @target_window.update
    # 特技窗口被激活的情况下: 调用 update_skill
    if @skill_window.active
      update_skill
      return
    end
    # 目标窗口被激活的情况下: 调用 update_target
    if @target_window.active
      update_target
      return
    end
  end
  #
  # 刷新画面 (特技窗口被激活的情况下)
  #
  #
  def update_skill
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到菜单画面
      $scene = Scene_Menu.new(1)
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 获取特技窗口现在选择的特技的数据
      @skill = @skill_window.skill
      # 不能使用的情况下
      if @skill == nil or not @actor.skill_can_use?(@skill.id)
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 效果范围是我方的情况下
      if @skill.scope >= 3
        # 激活目标窗口
        @skill_window.active = false
        @target_window.x = (@skill_window.index + 1) % 2 * 304
        @target_window.visible = true
        @target_window.active = true
        # 设置效果范围 (单体/全体) 的对应光标位置
        if @skill.scope == 4 || @skill.scope == 6
          @target_window.index = -1
        elsif @skill.scope == 7
          @target_window.index = @actor_index - 10
        else
          @target_window.index = 0
        end
      # 效果在我方以外的情况下
      else
        # 公共事件 ID 有效的情况下
        if @skill.common_event_id > 0
          # 预约调用公共事件
          $game_temp.common_event_id = @skill.common_event_id
          # 演奏特技使用时的 SE
          $game_system.se_play(@skill.menu_se)
          # 消耗 SP
          @actor.sp -= @skill.sp_cost
          # 再生成各窗口的内容
          @status_window.refresh
          @skill_window.refresh
          @target_window.refresh
          # 切换到地图画面
          $scene = Scene_Map.new
          return
        end
      end
      return
    end
    # 按下 R 键的情况下
    if Input.trigger?(Input::R)
      # 演奏光标 SE
      $game_system.se_play($data_system.cursor_se)
      # 移至下一位角色
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      # 切换到别的特技画面
      $scene = Scene_Skill.new(@actor_index)
      return
    end
    # 按下 L 键的情况下
    if Input.trigger?(Input::L)
      # 演奏光标 SE
      $game_system.se_play($data_system.cursor_se)
      # 移至上一位角色
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      # 切换到别的特技画面
      $scene = Scene_Skill.new(@actor_index)
      return
    end
  end
  #
  # 刷新画面 (目标窗口被激活的情况下)
  #
  #
  def update_target
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 删除目标窗口
      @skill_window.active = true
      @target_window.visible = false
      @target_window.active = false
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 因为 SP 不足而无法使用的情况下
      unless @actor.skill_can_use?(@skill.id)
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 目标是全体的情况下
      if @target_window.index == -1
        # 对同伴全体应用特技使用效果
        used = false
        for i in $game_party.actors
          used |= i.skill_effect(@actor, @skill)
        end
      end
      # 目标是使用者的情况下
      if @target_window.index <= -2
        # 对目标角色应用特技的使用效果
        target = $game_party.actors[@target_window.index + 10]
        used = target.skill_effect(@actor, @skill)
      end
      # 目标是单体的情况下
      if @target_window.index >= 0
        # 对目标角色应用特技的使用效果
        target = $game_party.actors[@target_window.index]
        used = target.skill_effect(@actor, @skill)
      end
      # 使用特技的情况下
      if used
        # 演奏特技使用时的 SE
        $game_system.se_play(@skill.menu_se)
        # 消耗 SP
        @actor.sp -= @skill.sp_cost
        # 再生成各窗口内容
        @status_window.refresh
        @skill_window.refresh
        @target_window.refresh
        # 全灭的情况下
        if $game_party.all_dead?
          # 切换到游戏结束画面
          $scene = Scene_Gameover.new
          return
        end
        # 公共事件 ID 有效的情况下
        if @skill.common_event_id > 0
          # 预约调用公共事件
          $game_temp.common_event_id = @skill.common_event_id
          # 切换到地图画面
          $scene = Scene_Map.new
          return
        end
      end
      # 无法使用特技的情况下
      unless used
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
      end
      return
    end
  end
end
