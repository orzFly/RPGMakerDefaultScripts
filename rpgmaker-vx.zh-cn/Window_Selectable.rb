#
# 拥有光标的移动以及滚动功能的窗口类。
#

class Window_Selectable < Window_Base
  #
  # 定义实例变量
  #
  #
  attr_reader   :item_max                 # 选项数
  attr_reader   :column_max               # 行数
  attr_reader   :index                    # 光标位置
  attr_reader   :help_window              # 帮助窗口
  #
  # 初始化对像
  #
  # x      : 窗口的 X 坐标
  # y      : 窗口的 Y 坐标
  # width  : 窗口的宽
  # height : 窗口的高
  # spacing : 选项横向排列时间隔空白宽度
  #
  def initialize(x, y, width, height, spacing = 32)
    @item_max = 1
    @column_max = 1
    @index = -1
    @spacing = spacing
    super(x, y, width, height)
  end
  #
  # 窗口内容生成
  #
  #
  def create_contents
    self.contents.dispose
    self.contents = Bitmap.new(width - 32, [height - 32, row_max * WLH].max)
  end
  #
  # 设置光标的位置
  #
  # index : 新的光标位置
  #
  def index=(index)
    @index = index
    update_cursor
    call_update_help
  end
  #
  # 获取行数
  #
  #
  def row_max
    return (@item_max + @column_max - 1) / @column_max
  end
  #
  # 获取开头行
  #
  #
  def top_row
    return self.oy / WLH
  end
  #
  # 设置开头行
  #
  # row : 显示开头的行
  #
  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    self.oy = row * WLH
  end
  #
  # 获取 1 页可以显示的行数
  #
  #
  def page_row_max
    return (self.height - 32) / WLH
  end
  #
  # 获取 1 页可以显示的项目数
  #
  #
  def page_item_max
    return page_row_max * @column_max
  end
  #
  # 获取末尾行
  #
  #
  def bottom_row
    return top_row + page_row_max - 1
  end
  #
  # 设置末尾行
  #
  # row : 显示末尾的行
  #
  def bottom_row=(row)
    self.top_row = row - (page_row_max - 1)
  end
  #
  # 获取项目描画矩形
  #
  # index : 项目编号
  #
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = WLH
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = index / @column_max * WLH
    return rect
  end
  #
  # 帮助窗口的设置
  #
  # help_window : 新的帮助窗口
  #
  def help_window=(help_window)
    @help_window = help_window
    call_update_help
  end
  #
  # 光标移动可能判定
  #
  #
  def cursor_movable?
    return false if (not visible or not active)
    return false if (index < 0 or index > @item_max or @item_max == 0)
    return false if (@opening or @closing)
    return true
  end
  #
  # 光标下移动
  #
  # wrap : 滚动移动许可
  #
  def cursor_down(wrap = false)
    if (@index < @item_max - @column_max) or (wrap and @column_max == 1)
      @index = (@index + @column_max) % @item_max
    end
  end
  #
  # 光标上移动
  #
  # wrap : 滚动移动许可
  #
  def cursor_up(wrap = false)
    if (@index >= @column_max) or (wrap and @column_max == 1)
      @index = (@index - @column_max + @item_max) % @item_max
    end
  end
  #
  # 光标右移动
  #
  # wrap : 滚动移动许可
  #
  def cursor_right(wrap = false)
    if (@column_max >= 2) and
       (@index < @item_max - 1 or (wrap and page_row_max == 1))
      @index = (@index + 1) % @item_max
    end
  end
  #
  # 光标左移动
  #
  # wrap : 滚动移动许可
  #
  def cursor_left(wrap = false)
    if (@column_max >= 2) and
       (@index > 0 or (wrap and page_row_max == 1))
      @index = (@index - 1 + @item_max) % @item_max
    end
  end
  #
  # 光标移动到1页后
  #
  #
  def cursor_pagedown
    if top_row + page_row_max < row_max
      @index = [@index + page_item_max, @item_max - 1].min
      self.top_row += page_row_max
    end
  end
  #
  # 光标移动到1页前
  #
  #
  def cursor_pageup
    if top_row > 0
      @index = [@index - page_item_max, 0].max
      self.top_row -= page_row_max
    end
  end
  #
  # 刷新画面
  #
  #
  def update
    super
    if cursor_movable?
      last_index = @index
      if Input.repeat?(Input::DOWN)
        cursor_down(Input.trigger?(Input::DOWN))
      end
      if Input.repeat?(Input::UP)
        cursor_up(Input.trigger?(Input::UP))
      end
      if Input.repeat?(Input::RIGHT)
        cursor_right(Input.trigger?(Input::RIGHT))
      end
      if Input.repeat?(Input::LEFT)
        cursor_left(Input.trigger?(Input::LEFT))
      end
      if Input.repeat?(Input::R)
        cursor_pagedown
      end
      if Input.repeat?(Input::L)
        cursor_pageup
      end
      if @index != last_index
        Sound.play_cursor
      end
    end
    update_cursor
    call_update_help
  end
  #
  # 更新光标矩形
  #
  #
  def update_cursor
    if @index < 0                   # 光标位置不满 0 的情况下
      self.cursor_rect.empty        # 光标无效
    else                            # 光标位 0 以上的情况下
      row = @index / @column_max    # 获取当前的行
      if row < top_row              # 当前行被显示开头行前面的情况下
        self.top_row = row          # 从当前行向开头行滚动
      end
      if row > bottom_row           # 当前行被显示末尾行之后的情况下
        self.bottom_row = row       # 从当前行向末尾滚动
      end
      rect = item_rect(@index)      # 获取选择项的矩形
      rect.y -= self.oy             # 矩形滚动的位置加起来
      self.cursor_rect = rect       # 更新光标矩形
    end
  end
  #
  # 呼出帮助窗口更新方法
  #
  #
  def call_update_help
    if self.active and @help_window != nil
       update_help
    end
  end
  #
  # 刷新帮助文本 (内容在继承处定义)
  #
  #
  def update_help
  end
end
