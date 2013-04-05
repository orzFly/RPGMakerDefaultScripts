#encoding:utf-8
#
# 橫印選擇的指令視窗
#

class Window_HorzCommand < Window_Command
  #
  # 取得顯示行數
  #
  #
  def visible_line_number
    return 1
  end
  #
  # 取得列數
  #
  #
  def col_max
    return 4
  end
  #
  # 取得行間距的寬度
  #
  #
  def spacing
    return 8
  end
  #
  # 計算視窗內容的寬度
  #
  #
  def contents_width
    (item_width + spacing) * item_max - spacing
  end
  #
  # 計算視窗內容的高度
  #
  #
  def contents_height
    item_height
  end
  #
  # 取得首列位置
  #
  #
  def top_col
    ox / (item_width + spacing)
  end
  #
  # 設定首列位置
  #
  #
  def top_col=(col)
    col = 0 if col < 0
    col = col_max - 1 if col > col_max - 1
    self.ox = col * (item_width + spacing)
  end
  #
  # 取得尾列位置
  #
  #
  def bottom_col
    top_col + col_max - 1
  end
  #
  # 設定尾列位置
  #
  #
  def bottom_col=(col)
    self.top_col = col - (col_max - 1)
  end
  #
  # 確保游標在畫面範圍內卷動
  #
  #
  def ensure_cursor_visible
    self.top_col = index if index < top_col
    self.bottom_col = index if index > bottom_col
  end
  #
  # 取得專案的繪制矩形
  #
  #
  def item_rect(index)
    rect = super
    rect.x = index * (item_width + spacing)
    rect.y = 0
    rect
  end
  #
  # 取得對齊方向
  #
  #
  def alignment
    return 1
  end
  #
  # 游標向下搬移
  #
  #
  def cursor_down(wrap = false)
  end
  #
  # 游標向上搬移
  #
  #
  def cursor_up(wrap = false)
  end
  #
  # 游標移至下一頁
  #
  #
  def cursor_pagedown
  end
  #
  # 游標移至上一頁
  #
  #
  def cursor_pageup
  end
end
