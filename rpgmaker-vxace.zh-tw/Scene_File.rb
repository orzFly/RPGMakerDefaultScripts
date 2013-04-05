#encoding:utf-8
#
# 存檔畫面和讀檔畫面共同的父類
#

class Scene_File < Scene_MenuBase
  #
  # 開始處理
  #
  #
  def start
    super
    create_help_window
    create_savefile_viewport
    create_savefile_windows
    init_selection
  end
  #
  # 結束處理
  #
  #
  def terminate
    super
    @savefile_viewport.dispose
    @savefile_windows.each {|window| window.dispose }
  end
  #
  # 更新畫面
  #
  #
  def update
    super
    @savefile_windows.each {|window| window.update }
    update_savefile_selection
  end
  #
  # 生成說明視窗
  #
  #
  def create_help_window
    @help_window = Window_Help.new(1)
    @help_window.set_text(help_window_text)
  end
  #
  # 取得說明視窗的文字
  #
  #
  def help_window_text
    return ""
  end
  #
  # 生成存檔檔案顯示連接埠
  #
  #
  def create_savefile_viewport
    @savefile_viewport = Viewport.new
    @savefile_viewport.rect.y = @help_window.height
    @savefile_viewport.rect.height -= @help_window.height
  end
  #
  # 生成存檔檔案視窗
  #
  #
  def create_savefile_windows
    @savefile_windows = Array.new(item_max) do |i|
      Window_SaveFile.new(savefile_height, i)
    end
    @savefile_windows.each {|window| window.viewport = @savefile_viewport }
  end
  #
  # 初始化選擇狀態
  #
  #
  def init_selection
    @index = first_savefile_index
    @savefile_windows[@index].selected = true
    self.top_index = @index - visible_max / 2
    ensure_cursor_visible
  end
  #
  # 取得專案數
  #
  #
  def item_max
    DataManager.savefile_max
  end
  #
  # 取得可顯示的存檔數目
  #
  #
  def visible_max
    return 4
  end
  #
  # 取得存檔檔案視窗的高度
  #
  #
  def savefile_height
    @savefile_viewport.rect.height / visible_max
  end
  #
  # 取得開始時檔案索引的位置
  #
  #
  def first_savefile_index
    return 0
  end
  #
  # 取得當前索引
  #
  #
  def index
    @index
  end
  #
  # 取得頂端索引
  #
  #
  def top_index
    @savefile_viewport.oy / savefile_height
  end
  #
  # 設定頂端索引
  #
  #
  def top_index=(index)
    index = 0 if index < 0
    index = item_max - visible_max if index > item_max - visible_max
    @savefile_viewport.oy = index * savefile_height
  end
  #
  # 取得末端索引
  #
  #
  def bottom_index
    top_index + visible_max - 1
  end
  #
  # 設定末端索引
  #
  #
  def bottom_index=(index)
    self.top_index = index - (visible_max - 1)
  end
  #
  # 更新存檔檔案選擇
  #
  #
  def update_savefile_selection
    return on_savefile_ok     if Input.trigger?(:C)
    return on_savefile_cancel if Input.trigger?(:B)
    update_cursor
  end
  #
  # 存檔檔案“確定”
  #
  #
  def on_savefile_ok
  end
  #
  # 存檔檔案“取消”
  #
  #
  def on_savefile_cancel
    Sound.play_cancel
    return_scene
  end
  #
  # 更新游標
  #
  #
  def update_cursor
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_pagedown   if Input.trigger?(:R)
    cursor_pageup     if Input.trigger?(:L)
    if @index != last_index
      Sound.play_cursor
      @savefile_windows[last_index].selected = false
      @savefile_windows[@index].selected = true
    end
  end
  #
  # 游標向下搬移
  #
  #
  def cursor_down(wrap)
    @index = (@index + 1) % item_max if @index < item_max - 1 || wrap
    ensure_cursor_visible
  end
  #
  # 游標向上搬移
  #
  #
  def cursor_up(wrap)
    @index = (@index - 1 + item_max) % item_max if @index > 0 || wrap
    ensure_cursor_visible
  end
  #
  # 游標移至下 1 頁
  #
  #
  def cursor_pagedown
    if top_index + visible_max < item_max
      self.top_index += visible_max
      @index = [@index + visible_max, item_max - 1].min
    end
  end
  #
  # 游標移至上 1 頁
  #
  #
  def cursor_pageup
    if top_index > 0
      self.top_index -= visible_max
      @index = [@index - visible_max, 0].max
    end
  end
  #
  # 確保游標在畫面範圍內卷動
  #
  #
  def ensure_cursor_visible
    self.top_index = index if index < top_index
    self.bottom_index = index if index > bottom_index
  end
end
