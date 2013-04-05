#
# 调试画面、个别显示开关及变量的窗口。
#

class Window_DebugRight < Window_Selectable
  #
  # 定义实例变量
  #
  #
  attr_reader   :mode                     # 模式 (0:开关、1:变量)
  attr_reader   :top_id                   # 开头显示的 ID
  #
  # 初始化对像
  #
  # x     : 窗口的X坐标
  # y     : 窗口的Y坐标  
  #
  def initialize(x, y)
    super(x, y, 368, 10 * WLH + 32)
    self.index = -1
    self.active = false
    @item_max = 10
    @mode = 0
    @top_id = 1
    refresh
  end
  #
  # 刷新
  #
  #
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #
  # 描绘项目
  #
  # index : 项目编号
  #
  def draw_item(index)
    current_id = @top_id + index
    id_text = sprintf("%04d:", current_id)
    id_width = self.contents.text_size(id_text).width
    if @mode == 0
      name = $data_system.switches[current_id]
      status = $game_switches[current_id] ? "[ON]" : "[OFF]"
    else
      name = $data_system.variables[current_id]
      status = $game_variables[current_id]
    end
    if name == nil
      name = ""
    end
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.draw_text(rect, id_text)
    rect.x += id_width
    rect.width -= id_width + 60
    self.contents.draw_text(rect, name)
    rect.width += 60
    self.contents.draw_text(rect, status, 2)
  end
  #
  # 设置模式
  #
  # id : 新的模式
  #
  def mode=(mode)
    if @mode != mode
      @mode = mode
      refresh
    end
  end
  #
  # 设置开头显示的 ID
  #
  # id : 新的 ID
  #
  def top_id=(id)
    if @top_id != id
      @top_id = id
      refresh
    end
  end
end
