#encoding:utf-8
#
# 戰鬥畫面中，選擇角色行動的視窗。
#

class Window_ActorCommand < Window_Command
  #
  # 初始化物件
  #
  #
  def initialize
    super(0, 0)
    self.openness = 0
    deactivate
    @actor = nil
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    return 128
  end
  #
  # 取得顯示行數
  #
  #
  def visible_line_number
    return 4
  end
  #
  # 生成指令清單
  #
  #
  def make_command_list
    return unless @actor
    add_attack_command
    add_skill_commands
    add_guard_command
    add_item_command
  end
  #
  # 加入攻擊指令
  #
  #
  def add_attack_command
    add_command(Vocab::attack, :attack, @actor.attack_usable?)
  end
  #
  # 加入技能指令
  #
  #
  def add_skill_commands
    @actor.added_skill_types.sort.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id)
    end
  end
  #
  # 加入防御指令
  #
  #
  def add_guard_command
    add_command(Vocab::guard, :guard, @actor.guard_usable?)
  end
  #
  # 加入物品指令
  #
  #
  def add_item_command
    add_command(Vocab::item, :item)
  end
  #
  # 設定
  #
  #
  def setup(actor)
    @actor = actor
    clear_command_list
    make_command_list
    refresh
    select(0)
    activate
    open
  end
end
