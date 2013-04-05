#encoding:utf-8
#
# 除錯畫面中，顯示開關和變量編號的視窗。
#

class Window_DebugLeft < Window_Selectable
  #
  # 類變量
  #
  #
  @@last_top_row = 0                      # 儲存頂行用
  @@last_index   = 0                      # 儲存游標位置用
  #
  # 定義案例變量
  #
  #
  attr_reader   :right_window             # 右視窗
  #
  # 初始化物件
  #
  #
  def initialize(x, y)
    super(x, y, window_width, window_height)
    refresh
    self.top_row = @@last_top_row
    select(@@last_index)
    activate
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    return 164
  end
  #
  # 取得視窗的高度
  #
  #
  def window_height
    Graphics.height
  end
  #
  # 取得專案數
  #
  #
  def item_max
    @item_max || 0
  end
  #
  # 更新畫面
  #
  #
  def update
    super
    return unless @right_window
    @right_window.mode = mode
    @right_window.top_id = top_id
  end
  #
  # 取得模式
  #
  #
  def mode
    index < @switch_max ? :switch : :variable
  end
  #
  # 取得頂端 ID 
  #
  #
  def top_id
    (index - (index < @switch_max ? 0 : @switch_max)) * 10 + 1
  end
  #
  # 重新整理
  #
  #
  def refresh
    @switch_max = ($data_system.switches.size - 1 + 9) / 10
    @variable_max = ($data_system.variables.size - 1 + 9) / 10
    @item_max = @switch_max + @variable_max
    create_contents
    draw_all_items
  end
  #
  # 繪制專案
  #
  #
  def draw_item(index)
    if index < @switch_max
      n = index * 10
      text = sprintf("S [%04d-%04d]", n+1, n+10)
    else
      n = (index - @switch_max) * 10
      text = sprintf("V [%04d-%04d]", n+1, n+10)
    end
    draw_text(item_rect_for_text(index), text)
  end
  #
  # 按下取消鍵時的處理
  #
  #
  def process_cancel
    super
    @@last_top_row = top_row
    @@last_index = index
  end
  #
  # 設定右視窗
  #
  #
  def right_window=(right_window)
    @right_window = right_window
    update
  end
end
