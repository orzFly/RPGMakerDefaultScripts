#
# 调试画面、指定开关及变量块的窗口。
#

class Window_DebugLeft < Window_Selectable
  #
  # 初始化对像
  #
  # x     : 窗口的X坐标
  # y     : 窗口的Y坐标  
  #
  def initialize(x, y)
    super(x, y, 176, 416)
    self.index = 0
    refresh
  end
  #
  # 刷新
  #
  #
  def refresh
    @switch_max = ($data_system.switches.size - 1 + 9) / 10
    @variable_max = ($data_system.variables.size - 1 + 9) / 10
    @item_max = @switch_max + @variable_max
    create_contents
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
    if index < @switch_max
      n = index * 10
      text = sprintf("S [%04d-%04d]", n+1, n+10)
    else
      n = (index - @switch_max) * 10
      text = sprintf("V [%04d-%04d]", n+1, n+10)
    end
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.draw_text(rect, text)
  end
  #
  # 获取模式
  #
  #
  def mode
    if self.index < @switch_max
      return 0
    else
      return 1
    end
  end
  #
  # 获取开头显示的 ID
  #
  #
  def top_id
    if self.index < @switch_max
      return self.index * 10 + 1
    else
      return (self.index - @switch_max) * 10 + 1
    end
  end
end
