#
# 一般的命令选择行窗口。
#

class Window_Command < Window_Selectable
  #
  # 初始化对像
  #
  # width    : 窗口的宽
  # commands : 命令字符串序列
  #
  def initialize(width, commands)
    # 由命令的个数计算出窗口的高
    super(0, 0, width, commands.size * 32 + 32)
    @item_max = commands.size
    @commands = commands
    self.contents = Bitmap.new(width - 32, @item_max * 32)
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
      draw_item(i, normal_color)
    end
  end
  #
  # 描绘项目
  #
  # index : 项目编号
  # color : 文字色
  #
  def draw_item(index, color)
    self.contents.font.color = color
    rect = Rect.new(4, 32 * index, self.contents.width - 8, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.draw_text(rect, @commands[index])
  end
  #
  # 项目无效化
  #
  # index : 项目编号
  #
  def disable_item(index)
    draw_item(index, disabled_color)
  end
end
