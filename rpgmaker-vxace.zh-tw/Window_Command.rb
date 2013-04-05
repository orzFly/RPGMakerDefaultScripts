#encoding:utf-8
#
# 帶有指令選擇的視窗
#

class Window_Command < Window_Selectable
  #
  # 初始化物件
  #
  #
  def initialize(x, y)
    clear_command_list
    make_command_list
    super(x, y, window_width, window_height)
    refresh
    select(0)
    activate
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    return 160
  end
  #
  # 取得視窗的高度
  #
  #
  def window_height
    fitting_height(visible_line_number)
  end
  #
  # 取得顯示行數
  #
  #
  def visible_line_number
    item_max
  end
  #
  # 取得專案數
  #
  #
  def item_max
    @list.size
  end
  #
  # 清除指令清單
  #
  #
  def clear_command_list
    @list = []
  end
  #
  # 生成指令清單
  #
  #
  def make_command_list
  end
  #
  # 加入指令
  #
  # name    : 指令名稱
  # symbol  : 對應的符號
  # enabled : 有效狀態的標志
  # ext     : 任意的延伸資料
  #
  def add_command(name, symbol, enabled = true, ext = nil)
    @list.push({:name=>name, :symbol=>symbol, :enabled=>enabled, :ext=>ext})
  end
  #
  # 取得指令名稱
  #
  #
  def command_name(index)
    @list[index][:name]
  end
  #
  # 取得指令的有效狀態
  #
  #
  def command_enabled?(index)
    @list[index][:enabled]
  end
  #
  # 取得選項的指令資料
  #
  #
  def current_data
    index >= 0 ? @list[index] : nil
  end
  #
  # 取得選項的有效狀態
  #
  #
  def current_item_enabled?
    current_data ? current_data[:enabled] : false
  end
  #
  # 取得選項的符號
  #
  #
  def current_symbol
    current_data ? current_data[:symbol] : nil
  end
  #
  # 取得選項的延伸資料
  #
  #
  def current_ext
    current_data ? current_data[:ext] : nil
  end
  #
  # 將游標搬移到特殊的標志符對應的選項
  #
  #
  def select_symbol(symbol)
    @list.each_index {|i| select(i) if @list[i][:symbol] == symbol }
  end
  #
  # 將游標搬移到特殊的延伸資料對應的選項
  #
  #
  def select_ext(ext)
    @list.each_index {|i| select(i) if @list[i][:ext] == ext }
  end
  #
  # 繪制專案
  #
  #
  def draw_item(index)
    change_color(normal_color, command_enabled?(index))
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
  #
  # 取得對齊方向
  #
  #
  def alignment
    return 0
  end
  #
  # 取得決定處理的有效狀態
  #
  #
  def ok_enabled?
    return true
  end
  #
  # 呼叫“確定”的處理方法
  #
  #
  def call_ok_handler
    if handle?(current_symbol)
      call_handler(current_symbol)
    elsif handle?(:ok)
      super
    else
      activate
    end
  end
  #
  # 重新整理
  #
  #
  def refresh
    clear_command_list
    make_command_list
    create_contents
    super
  end
end
