#
# 特技及物品的说明、角色的状态显示的窗口。
#

class Window_Help < Window_Base
  #
  # 初始化对像
  #
  #
  def initialize
    super(0, 0, 544, WLH + 32)
  end
  #
  # 设置文本
  #
  # text  : 窗口显示的字符串
  # align : 对齐方式 (0..左对齐、1..中间对齐、2..右对齐)
  #
  def set_text(text, align = 0)
    if text != @text or align != @align
      self.contents.clear
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, self.width - 40, WLH, text, align)
      @text = text
      @align = align
    end
  end
end
