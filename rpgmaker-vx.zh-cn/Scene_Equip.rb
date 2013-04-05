#
# 处理装备画面的类。
#

class Scene_Equip < Scene_Base
  #
  # 定量
  #
  #
  EQUIP_TYPE_MAX = 5                      # 装备部位数量
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
  # 开始处理
  #
  #
  def start
    super
    create_menu_background
    @actor = $game_party.members[@actor_index]
    @help_window = Window_Help.new
    create_item_windows
    @equip_window = Window_Equip.new(208, 56, @actor)
    @equip_window.help_window = @help_window
    @equip_window.index = @equip_index
    @status_window = Window_EquipStatus.new(0, 56, @actor)
  end
  #
  # 结束处理
  #
  #
  def terminate
    super
    dispose_menu_background
    @help_window.dispose
    @equip_window.dispose
    @status_window.dispose
    dispose_item_windows
  end
  #
  # 返回前一个画面
  #
  #
  def return_scene
    $scene = Scene_Menu.new(2)
  end
  #
  # 切换下一个角色的画面
  #
  #
  def next_actor
    @actor_index += 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Equip.new(@actor_index, @equip_window.index)
  end
  #
  # 切换前一个角色的画面
  #
  #
  def prev_actor
    @actor_index += $game_party.members.size - 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Equip.new(@actor_index, @equip_window.index)
  end
  #
  # 刷新画面
  #
  #
  def update
    super
    update_menu_background
    @help_window.update
    update_equip_window
    update_status_window
    update_item_windows
    if @equip_window.active
      update_equip_selection
    elsif @item_window.active
      update_item_selection
    end
  end
  #
  # 生成道具窗口
  #
  #
  def create_item_windows
    @item_windows = []
    for i in 0...EQUIP_TYPE_MAX
      @item_windows[i] = Window_EquipItem.new(0, 208, 544, 208, @actor, i)
      @item_windows[i].help_window = @help_window
      @item_windows[i].visible = (@equip_index == i)
      @item_windows[i].y = 208
      @item_windows[i].height = 208
      @item_windows[i].active = false
      @item_windows[i].index = -1
    end
  end
  #
  # 释放道具窗口
  #
  #
  def dispose_item_windows
    for window in @item_windows
      window.dispose
    end
  end
  #
  # 刷新道具窗口
  #
  #
  def update_item_windows
    for i in 0...EQUIP_TYPE_MAX
      @item_windows[i].visible = (@equip_window.index == i)
      @item_windows[i].update
    end
    @item_window = @item_windows[@equip_window.index]
  end
  #
  # 刷新装备窗口
  #
  #
  def update_equip_window
    @equip_window.update
  end
  #
  # 刷新状态窗口
  #
  #
  def update_status_window
    if @equip_window.active
      @status_window.set_new_parameters(nil, nil, nil, nil)
    elsif @item_window.active
      temp_actor = @actor.clone
      temp_actor.change_equip(@equip_window.index, @item_window.item, true)
      new_atk = temp_actor.atk
      new_def = temp_actor.def
      new_spi = temp_actor.spi
      new_agi = temp_actor.agi
      @status_window.set_new_parameters(new_atk, new_def, new_spi, new_agi)
    end
    @status_window.update
  end
  #
  # 刷新装备部位选项
  #
  #
  def update_equip_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::R)
      Sound.play_cursor
      next_actor
    elsif Input.trigger?(Input::L)
      Sound.play_cursor
      prev_actor
    elsif Input.trigger?(Input::C)
      if @actor.fix_equipment
        Sound.play_buzzer
      else
        Sound.play_decision
        @equip_window.active = false
        @item_window.active = true
        @item_window.index = 0
      end
    end
  end
  #
  # 刷新道具选项
  #
  #
  def update_item_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @equip_window.active = true
      @item_window.active = false
      @item_window.index = -1
    elsif Input.trigger?(Input::C)
      Sound.play_equip
      @actor.change_equip(@equip_window.index, @item_window.item)
      @equip_window.active = true
      @item_window.active = false
      @item_window.index = -1
      @equip_window.refresh
      for item_window in @item_windows
        item_window.refresh
      end
    end
  end
end
