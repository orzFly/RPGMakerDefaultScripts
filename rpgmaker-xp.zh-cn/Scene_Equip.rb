#
# 处理装备画面的类。
#

class Scene_Equip
  #
  # 初始化对像
  #
  # actor_index : 角色索引
  # equip_index : 装备索引
  #
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
    @equip_index = equip_index
  end
  #
  # 主处理
  #
  #
  def main
    # 获取角色
    @actor = $game_party.actors[@actor_index]
    # 生成窗口
    @help_window = Window_Help.new
    @left_window = Window_EquipLeft.new(@actor)
    @right_window = Window_EquipRight.new(@actor)
    @item_window1 = Window_EquipItem.new(@actor, 0)
    @item_window2 = Window_EquipItem.new(@actor, 1)
    @item_window3 = Window_EquipItem.new(@actor, 2)
    @item_window4 = Window_EquipItem.new(@actor, 3)
    @item_window5 = Window_EquipItem.new(@actor, 4)
    # 关联帮助窗口
    @right_window.help_window = @help_window
    @item_window1.help_window = @help_window
    @item_window2.help_window = @help_window
    @item_window3.help_window = @help_window
    @item_window4.help_window = @help_window
    @item_window5.help_window = @help_window
    # 设置光标位置
    @right_window.index = @equip_index
    refresh
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
      # 如果画面切换的话的就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @help_window.dispose
    @left_window.dispose
    @right_window.dispose
    @item_window1.dispose
    @item_window2.dispose
    @item_window3.dispose
    @item_window4.dispose
    @item_window5.dispose
  end
  #
  # 刷新
  #
  #
  def refresh
    # 设置物品窗口的可视状态
    @item_window1.visible = (@right_window.index == 0)
    @item_window2.visible = (@right_window.index == 1)
    @item_window3.visible = (@right_window.index == 2)
    @item_window4.visible = (@right_window.index == 3)
    @item_window5.visible = (@right_window.index == 4)
    # 获取当前装备中的物品
    item1 = @right_window.item
    # 设置当前的物品窗口到 @item_window
    case @right_window.index
    when 0
      @item_window = @item_window1
    when 1
      @item_window = @item_window2
    when 2
      @item_window = @item_window3
    when 3
      @item_window = @item_window4
    when 4
      @item_window = @item_window5
    end
    # 右窗口被激活的情况下
    if @right_window.active
      # 删除变更装备后的能力
      @left_window.set_new_parameters(nil, nil, nil)
    end
    # 物品窗口被激活的情况下
    if @item_window.active
      # 获取现在选中的物品
      item2 = @item_window.item
      # 变更装备
      last_hp = @actor.hp
      last_sp = @actor.sp
      @actor.equip(@right_window.index, item2 == nil ? 0 : item2.id)
      # 获取变更装备后的能力值
      new_atk = @actor.atk
      new_pdef = @actor.pdef
      new_mdef = @actor.mdef
      # 返回到装备
      @actor.equip(@right_window.index, item1 == nil ? 0 : item1.id)
      @actor.hp = last_hp
      @actor.sp = last_sp
      # 描画左窗口
      @left_window.set_new_parameters(new_atk, new_pdef, new_mdef)
    end
  end
  #
  # 刷新画面
  #
  #
  def update
    # 刷新窗口
    @left_window.update
    @right_window.update
    @item_window.update
    refresh
    # 右侧窗口被激活的情况下: 调用 update_right
    if @right_window.active
      update_right
      return
    end
    # 物品窗口被激活的情况下: 调用 update_item
    if @item_window.active
      update_item
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
      # 切换到菜单画面
      $scene = Scene_Menu.new(2)
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 固定装备的情况下
      if @actor.equip_fix?(@right_window.index)
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 激活物品窗口
      @right_window.active = false
      @item_window.active = true
      @item_window.index = 0
      return
    end
    # 按下 R 键的情况下
    if Input.trigger?(Input::R)
      # 演奏光标 SE
      $game_system.se_play($data_system.cursor_se)
      # 移至下一位角色
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      # 切换到别的装备画面
      $scene = Scene_Equip.new(@actor_index, @right_window.index)
      return
    end
    # 按下 L 键的情况下
    if Input.trigger?(Input::L)
      # 演奏光标 SE
      $game_system.se_play($data_system.cursor_se)
      # 移至上一位角色
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      # 切换到别的装备画面
      $scene = Scene_Equip.new(@actor_index, @right_window.index)
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
      # 激活右侧窗口
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 演奏装备 SE
      $game_system.se_play($data_system.equip_se)
      # 获取物品窗口现在选择的装备数据
      item = @item_window.item
      # 变更装备
      @actor.equip(@right_window.index, item == nil ? 0 : item.id)
      # 激活右侧窗口
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      # 再生成右侧窗口、物品窗口的内容
      @right_window.refresh
      @item_window.refresh
      return
    end
  end
end
