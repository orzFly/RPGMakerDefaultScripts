#
# 战斗中显示文章的信息窗口。通常信息窗口之上追加功能
# 带有显示战斗进行战斗进行说明的功能。
#

class Window_BattleMessage < Window_Message
  #
  # 初始化状态
  #
  #
  def initialize
    super
    self.openness = 255
    @lines = []
    refresh
  end
  #
  # 释放
  #
  #
  def dispose
    super
  end
  #
  # 刷新画面
  #
  #
  def update
    super
  end
  #
  # 窗口打开 (无效化)
  #
  #
  def open
  end
  #
  # 窗口关闭 (无效化)
  #
  #
  def close
  end
  #
  # 设置窗口背景与位置 (无效化)
  #
  #
  def reset_window
  end
  #
  # 清除
  #
  #
  def clear
    @lines.clear
    refresh
  end
  #
  # 获取行数
  #
  #
  def line_number
    return @lines.size
  end
  #
  # 返回一行
  #
  #
  def back_one
    @lines.pop
    refresh
  end
  #
  # 返回指定行
  #
  # line_number : 行编号
  #
  def back_to(line_number)
    while @lines.size > line_number
      @lines.pop
    end
    refresh
  end
  #
  # 追加文章
  #
  # text : 追加的文章
  #
  def add_instant_text(text)
    @lines.push(text)
    refresh
  end
  #
  # 替换文章
  #
  # text : 替换的文章
  # 最下行用其他文章替换
  #
  def replace_instant_text(text)
    @lines.pop
    @lines.push(text)
    refresh
  end
  #
  # 获取最底行的文章
  #
  #
  def last_instant_text
    return @lines[-1]
  end
  #
  # 刷新
  #
  #
  def refresh
    self.contents.clear
    for i in 0...@lines.size
      draw_line(i)
    end
  end
  #
  # 描画行
  #
  # index : 行编号
  #
  def draw_line(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.x += 4
    rect.y += index * WLH
    rect.width = contents.width - 8
    rect.height = WLH
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.draw_text(rect, @lines[index])
  end
end
