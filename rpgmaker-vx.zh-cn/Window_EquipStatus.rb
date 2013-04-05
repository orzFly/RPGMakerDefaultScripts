#
# 装备画面的、显示角色能力值变化的窗口。
#

class Window_EquipStatus < Window_Base
  #
  # 初始化对像
  #
  # x : 窗口的X坐标
  # y : 窗口的Y坐标
  # actor  : 角色
  #
  def initialize(x, y, actor)
    super(x, y, 208, WLH * 5 + 32)
    @actor = actor
    refresh
  end
  #
  # 刷新
  #
  #
  def refresh
    self.contents.clear
    draw_actor_name(@actor, 4, 0)
    draw_parameter(0, WLH * 1, 0)
    draw_parameter(0, WLH * 2, 1)
    draw_parameter(0, WLH * 3, 2)
    draw_parameter(0, WLH * 4, 3)
  end
  #
  # 变更装备后的能力值设置
  #
  # new_atk  : 变更装备后的攻击力
  # new_pdef : 变更装备后的物理力
  # new_spi : 变更装备后的精神力
  # new_agi : 变更装备后的敏捷性  
  # 
  def set_new_parameters(new_atk, new_def, new_spi, new_agi)
    if @new_atk != new_atk or @new_def != new_def or
       @new_spi != new_spi or @new_agi != new_agi
      @new_atk = new_atk
      @new_def = new_def
      @new_spi = new_spi
      @new_agi = new_agi
      refresh
    end
  end
  #
  # 获取变更装备后的能力值的描画颜色
  #
  # old_value : 变更装备前的能力值
  # new_value : 变更装备后的能力值
  #
  def new_parameter_color(old_value, new_value)
    if new_value > old_value      # 变强
      return power_up_color
    elsif new_value == old_value  # 不变
      return normal_color
    else                          # 变弱
      return power_down_color
    end
  end
  #
  # 能力值的描画
  #
  # x     : 描画目标 X 坐标
  # y     : 描画目标 Y 坐标
  # type : 能力值的种类(0～3)
  #
  def draw_parameter(x, y, type)
    case type
    when 0
      name = Vocab::atk
      value = @actor.atk
      new_value = @new_atk
    when 1
      name = Vocab::def
      value = @actor.def
      new_value = @new_def
    when 2
      name = Vocab::spi
      value = @actor.spi
      new_value = @new_spi
    when 3
      name = Vocab::agi
      value = @actor.agi
      new_value = @new_agi
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x + 4, y, 80, WLH, name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 90, y, 30, WLH, value, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(x + 122, y, 20, WLH, "→", 1)
    if new_value != nil
      self.contents.font.color = new_parameter_color(value, new_value)
      self.contents.draw_text(x + 142, y, 30, WLH, new_value, 2)
    end
  end
end
