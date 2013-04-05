#
# 一般的命令选择行窗口。
#

class Window_Command < Window_Selectable
  #
  # 定义实例变量
  #
  # 
  attr_reader   :commands                 # 命令  
  #
  # 初始化对象
  #
  # width      : 窗口的宽
  # commands   : 命令字符串序列
  # column_max : 行数 (2 行以上时选择)
  # row_max    : 列数 (0:列数加起来)
  # spacing : 选项横向排列时间隔空白宽度
  #
  def initialize(width, commands, column_max = 1, row_max = 0, spacing = 32)
    if row_max == 0
      row_max = (commands.size + column_max - 1) / column_max
    end
    super(0, 0, width, row_max * WLH + 32, spacing)
    @commands = commands
    @item_max = commands.size
    @column_max = column_max
    refresh
    self.index = 0
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
  # enabled : 有效标记录。是false 的时候半透明绘画
  #
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(rect, @commands[index])
  end
end
