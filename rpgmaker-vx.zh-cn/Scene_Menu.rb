#
# 处理菜单画面的类。
#

class Scene_Menu < Scene_Base
  #
  # 初始化对象
  #
  # menu_index : 命令光标的初期位置
  #
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #
  # 开始处理
  #
  #
  def start
    super
    create_menu_background
    create_command_window
    @gold_window = Window_Gold.new(0, 360)
    @status_window = Window_MenuStatus.new(160, 0)
  end
  #
  # 结束处理
  #
  #
  def terminate
    super
    dispose_menu_background
    @command_window.dispose
    @gold_window.dispose
    @status_window.dispose
  end
  #
  # 刷新画面
  #
  #
  def update
    super
    update_menu_background
    @command_window.update
    @gold_window.update
    @status_window.update
    if @command_window.active
      update_command_selection
    elsif @status_window.active
      update_actor_selection
    end
  end
  #
  # 生成指令窗口
  #
  #
  def create_command_window
    s1 = Vocab::item
    s2 = Vocab::skill
    s3 = Vocab::equip
    s4 = Vocab::status
    s5 = Vocab::save
    s6 = Vocab::game_end
    @command_window = Window_Command.new(160, [s1, s2, s3, s4, s5, s6])
    @command_window.index = @menu_index
    if $game_party.members.size == 0          # 队伍人数为0的场合
      @command_window.draw_item(0, false)     # 道具无效化
      @command_window.draw_item(1, false)     # 技能无效化
      @command_window.draw_item(2, false)     # 装备无效化
      @command_window.draw_item(3, false)     # 状态无效化
    end
    if $game_system.save_disabled             # 禁止保存的情况
      @command_window.draw_item(4, false)     # 保存无效化
    end
  end
  #
  # 刷新指令选择
  #
  #
  def update_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::C)
      if $game_party.members.size == 0 and @command_window.index < 4
        Sound.play_buzzer
        return
      elsif $game_system.save_disabled and @command_window.index == 4
        Sound.play_buzzer
        return
      end
      Sound.play_decision
      case @command_window.index
      when 0      # 道具
        $scene = Scene_Item.new
      when 1,2,3  # 技能、装备、状态
        start_actor_selection
      when 4      # 保存
        $scene = Scene_File.new(true, false, false)
      when 5      # 结束游戏
        $scene = Scene_End.new
      end
    end
  end
  #
  # 开始角色选择
  #
  #
  def start_actor_selection
    @command_window.active = false
    @status_window.active = true
    if $game_party.last_actor_index < @status_window.item_max
      @status_window.index = $game_party.last_actor_index
    else
      @status_window.index = 0
    end
  end
  #
  # 结束角色选择
  #
  #
  def end_actor_selection
    @command_window.active = true
    @status_window.active = false
    @status_window.index = -1
  end
  #
  # 刷新角色选择
  #
  #
  def update_actor_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_actor_selection
    elsif Input.trigger?(Input::C)
      $game_party.last_actor_index = @status_window.index
      Sound.play_decision
      case @command_window.index
      when 1  # 技能
        $scene = Scene_Skill.new(@status_window.index)
      when 2  # 装备
        $scene = Scene_Equip.new(@status_window.index)
      when 3  # 状态
        $scene = Scene_Status.new(@status_window.index)
      end
    end
  end
end
