#encoding:utf-8
#
# 擁有游標搬移、卷動功能的視窗
#

class Window_Selectable < Window_Base
  #
  # 定義案例變量
  #
  #
  attr_reader   :index                    # 游標位置
  attr_reader   :help_window              # 說明視窗
  attr_accessor :cursor_fix               # 游標固定的標志
  attr_accessor :cursor_all               # 游標全選擇的標志
  #
  # 初始化物件
  #
  #
  def initialize(x, y, width, height)
    super
    @index = -1
    @handler = {}
    @cursor_fix = false
    @cursor_all = false
    update_padding
    deactivate
  end
  #
  # 取得列數
  #
  #
  def col_max
    return 1
  end
  #
  # 取得行間距的寬度
  #
  #
  def spacing
    return 32
  end
  #
  # 取得專案數
  #
  #
  def item_max
    return 0
  end
  #
  # 取得專案的寬度
  #
  #
  def item_width
    (width - standard_padding * 2 + spacing) / col_max - spacing
  end
  #
  # 取得專案的高度
  #
  #
  def item_height
    line_height
  end
  #
  # 取得行數
  #
  #
  def row_max
    [(item_max + col_max - 1) / col_max, 1].max
  end
  #
  # 計算視窗內容的高度
  #
  #
  def contents_height
    [super - super % item_height, row_max * item_height].max
  end
  #
  # 更新邊距
  #
  #
  def update_padding
    super
    update_padding_bottom
  end
  #
  # 更新下端邊距
  #
  #
  def update_padding_bottom
    surplus = (height - standard_padding * 2) % item_height
    self.padding_bottom = padding + surplus
  end
  #
  # 設定高度
  #
  #
  def height=(height)
    super
    update_padding
  end
  #
  # 變更啟用狀態
  #
  #
  def active=(active)
    super
    update_cursor
    call_update_help
  end
  #
  # 設定游標位置
  #
  #
  def index=(index)
    @index = index
    update_cursor
    call_update_help
  end
  #
  # 選擇專案
  #
  #
  def select(index)
    self.index = index if index
  end
  #
  # 解除專案的選擇
  #
  #
  def unselect
    self.index = -1
  end
  #
  # 取得當前行
  #
  #
  def row
    index / col_max
  end
  #
  # 取得頂行位置
  #
  #
  def top_row
    oy / item_height
  end
  #
  # 設定頂行位置
  #
  #
  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    self.oy = row * item_height
  end
  #
  # 取得一頁內顯示的行數
  #
  #
  def page_row_max
    (height - padding - padding_bottom) / item_height
  end
  #
  # 取得一頁內顯示的專案數
  #
  #
  def page_item_max
    page_row_max * col_max
  end
  #
  # 判定是否橫印選擇
  #
  #
  def horizontal?
    page_row_max == 1
  end
  #
  # 取得末行位置
  #
  #
  def bottom_row
    top_row + page_row_max - 1
  end
  #
  # 設定末行位置
  #
  #
  def bottom_row=(row)
    self.top_row = row - (page_row_max - 1)
  end
  #
  # 取得專案的繪制矩形
  #
  #
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing)
    rect.y = index / col_max * item_height
    rect
  end
  #
  # 取得專案的繪制矩形（內容用）
  #
  #
  def item_rect_for_text(index)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    rect
  end
  #
  # 設定說明視窗
  #
  #
  def help_window=(help_window)
    @help_window = help_window
    call_update_help
  end
  #
  # 設定動作對應的處理方法
  #
  # method : 設定的處理方法 (Method 案例)
  #
  def set_handler(symbol, method)
    @handler[symbol] = method
  end
  #
  # 確認處理方法是否存在
  #
  #
  def handle?(symbol)
    @handler.include?(symbol)
  end
  #
  # 呼叫處理方法
  #
  #
  def call_handler(symbol)
    @handler[symbol].call if handle?(symbol)
  end
  #
  # 判定游標是否可以搬移
  #
  #
  def cursor_movable?
    active && open? && !@cursor_fix && !@cursor_all && item_max > 0
  end
  #
  # 游標向下搬移
  #
  #
  def cursor_down(wrap = false)
    if index < item_max - col_max || (wrap && col_max == 1)
      select((index + col_max) % item_max)
    end
  end
  #
  # 游標向上搬移
  #
  #
  def cursor_up(wrap = false)
    if index >= col_max || (wrap && col_max == 1)
      select((index - col_max + item_max) % item_max)
    end
  end
  #
  # 游標向右搬移
  #
  #
  def cursor_right(wrap = false)
    if col_max >= 2 && (index < item_max - 1 || (wrap && horizontal?))
      select((index + 1) % item_max)
    end
  end
  #
  # 游標向左搬移
  #
  #
  def cursor_left(wrap = false)
    if col_max >= 2 && (index > 0 || (wrap && horizontal?))
      select((index - 1 + item_max) % item_max)
    end
  end
  #
  # 游標移至下一頁
  #
  #
  def cursor_pagedown
    if top_row + page_row_max < row_max
      self.top_row += page_row_max
      select([@index + page_item_max, item_max - 1].min)
    end
  end
  #
  # 游標移至上一頁
  #
  #
  def cursor_pageup
    if top_row > 0
      self.top_row -= page_row_max
      select([@index - page_item_max, 0].max)
    end
  end
  #
  # 更新畫面
  #
  #
  def update
    super
    process_cursor_move
    process_handling
  end
  #
  # 處理游標的搬移
  #
  #
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
  end
  #
  # “確定”和“取消”的處理
  #
  #
  def process_handling
    return unless open? && active
    return process_ok       if ok_enabled?        && Input.trigger?(:C)
    return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
    return process_pagedown if handle?(:pagedown) && Input.trigger?(:R)
    return process_pageup   if handle?(:pageup)   && Input.trigger?(:L)
  end
  #
  # 取得確定處理的有效狀態
  #
  #
  def ok_enabled?
    handle?(:ok)
  end
  #
  # 取得取消處理的有效狀態
  #
  #
  def cancel_enabled?
    handle?(:cancel)
  end
  #
  # 按下確定鍵時的處理
  #
  #
  def process_ok
    if current_item_enabled?
      Sound.play_ok
      Input.update
      deactivate
      call_ok_handler
    else
      Sound.play_buzzer
    end
  end
  #
  # 呼叫“確定”的處理方法
  #
  #
  def call_ok_handler
    call_handler(:ok)
  end
  #
  # 按下取消鍵時的處理
  #
  #
  def process_cancel
    Sound.play_cancel
    Input.update
    deactivate
    call_cancel_handler
  end
  #
  # 呼叫“取消”的處理方法
  #
  #
  def call_cancel_handler
    call_handler(:cancel)
  end
  #
  # 按下 L 鍵（PageUp）時的處理
  #
  #
  def process_pageup
    Sound.play_cursor
    Input.update
    deactivate
    call_handler(:pageup)
  end
  #
  # 按下 R 鍵（PageDown）時的處理
  #
  #
  def process_pagedown
    Sound.play_cursor
    Input.update
    deactivate
    call_handler(:pagedown)
  end
  #
  # 更新游標
  #
  #
  def update_cursor
    if @cursor_all
      cursor_rect.set(0, 0, contents.width, row_max * item_height)
      self.top_row = 0
    elsif @index < 0
      cursor_rect.empty
    else
      ensure_cursor_visible
      cursor_rect.set(item_rect(@index))
    end
  end
  #
  # 確保游標在畫面範圍內卷動
  #
  #
  def ensure_cursor_visible
    self.top_row = row if row < top_row
    self.bottom_row = row if row > bottom_row
  end
  #
  # 呼叫說明視窗的更新方法
  #
  #
  def call_update_help
    update_help if active && @help_window
  end
  #
  # 更新說明視窗
  #
  #
  def update_help
    @help_window.clear
  end
  #
  # 取得選擇專案的有效狀態
  #
  #
  def current_item_enabled?
    return true
  end
  #
  # 繪制所有專案
  #
  #
  def draw_all_items
    item_max.times {|i| draw_item(i) }
  end
  #
  # 繪制專案
  #
  #
  def draw_item(index)
  end
  #
  # 消除專案
  #
  #
  def clear_item(index)
    contents.clear_rect(item_rect(index))
  end
  #
  # 重繪專案
  #
  #
  def redraw_item(index)
    clear_item(index) if index >= 0
    draw_item(index)  if index >= 0
  end
  #
  # 重繪選擇專案
  #
  #
  def redraw_current_item
    redraw_item(@index)
  end
  #
  # 重新整理
  #
  #
  def refresh
    contents.clear
    draw_all_items
  end
end
