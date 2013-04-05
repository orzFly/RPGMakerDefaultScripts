#
# 处理物品画面的类。
#

class Scene_Item
  #
  # 主处理
  #
  #
  def main
    # 生成帮助窗口、物品窗口
    @help_window = Window_Help.new
    @item_window = Window_Item.new
    # 关联帮助窗口
    @item_window.help_window = @help_window
    # 生成目标窗口 (设置为不可见・不活动)
    @target_window = Window_Target.new
    @target_window.visible = false
    @target_window.active = false
    # 执行过度
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面切换就中断循环
      if $scene != self
        break
      end
    end
    # 装备过渡
    Graphics.freeze
    # 释放窗口
    @help_window.dispose
    @item_window.dispose
    @target_window.dispose
  end
  #
  # 刷新画面
  #
  #
  def update
    # 刷新窗口
    @help_window.update
    @item_window.update
    @target_window.update
    # 物品窗口被激活的情况下: 调用 update_item
    if @item_window.active
      update_item
      return
    end
    # 目标窗口被激活的情况下: 调用 update_target
    if @target_window.active
      update_target
      return
    end
  end
  #
  # 刷新画面 (物品窗口被激活的情况下)
  #
  #
  def update_item
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到菜单画面
      $scene = Scene_Menu.new(0)
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 获取物品窗口当前选中的物品数据
      @item = @item_window.item
      # 不使用物品的情况下
      unless @item.is_a?(RPG::Item)
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 不能使用的情况下
      unless $game_party.item_can_use?(@item.id)
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 效果范围是我方的情况下
      if @item.scope >= 3
        # 激活目标窗口
        @item_window.active = false
        @target_window.x = (@item_window.index + 1) % 2 * 304
        @target_window.visible = true
        @target_window.active = true
        # 设置效果范围 (单体/全体) 的对应光标位置
        if @item.scope == 4 || @item.scope == 6
          @target_window.index = -1
        else
          @target_window.index = 0
        end
      # 效果在我方以外的情况下
      else
        # 公共事件 ID 有效的情况下
        if @item.common_event_id > 0
          # 预约调用公共事件
          $game_temp.common_event_id = @item.common_event_id
          # 演奏物品使用时的 SE
          $game_system.se_play(@item.menu_se)
          # 消耗品的情况下
          if @item.consumable
            # 使用的物品数减 1
            $game_party.lose_item(@item.id, 1)
            # 再描绘物品窗口的项目
            @item_window.draw_item(@item_window.index)
          end
          # 切换到地图画面
          $scene = Scene_Map.new
          return
        end
      end
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
      # 由于物品用完而不能使用的场合
      unless $game_party.item_can_use?(@item.id)
        # 再次生成物品窗口的内容
        @item_window.refresh
      end
      # 删除目标窗口
      @item_window.active = true
      @target_window.visible = false
      @target_window.active = false
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 如果物品用完的情况下
      if $game_party.item_number(@item.id) == 0
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 目标是全体的情况下
      if @target_window.index == -1
        # 对同伴全体应用物品使用效果
        used = false
        for i in $game_party.actors
          used |= i.item_effect(@item)
        end
      end
      # 目标是单体的情况下
      if @target_window.index >= 0
        # 对目标角色应用物品的使用效果
        target = $game_party.actors[@target_window.index]
        used = target.item_effect(@item)
      end
      # 使用物品的情况下
      if used
        # 演奏物品使用时的 SE
        $game_system.se_play(@item.menu_se)
        # 消耗品的情况下
        if @item.consumable
          # 使用的物品数减 1
          $game_party.lose_item(@item.id, 1)
          # 再描绘物品窗口的项目
          @item_window.draw_item(@item_window.index)
        end
        # 再生成目标窗口的内容
        @target_window.refresh
        # 全灭的情况下
        if $game_party.all_dead?
          # 切换到游戏结束画面
          $scene = Scene_Gameover.new
          return
        end
        # 公共事件 ID 有效的情况下
        if @item.common_event_id > 0
          # 预约调用公共事件
          $game_temp.common_event_id = @item.common_event_id
          # 切换到地图画面
          $scene = Scene_Map.new
          return
        end
      end
      # 无法使用物品的情况下
      unless used
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
      end
      return
    end
  end
end
