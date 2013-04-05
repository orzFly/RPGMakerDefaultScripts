#
# 商店画面、选择要做的事的窗口
#

class Window_ShopCommand < Window_Selectable
  #
  # 初始化对像
  #
  #
  def initialize
    super(0, 64, 480, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    @item_max = 3
    @column_max = 3
    @commands = ["买", "卖", "取消"]
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
  #
  def draw_item(index)
    x = 4 + index * 160
    self.contents.draw_text(x, 0, 128, 32, @commands[index])
  end
end
