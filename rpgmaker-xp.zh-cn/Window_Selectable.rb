#
# 拥有光标的移动以及滚动功能的窗口类。
#

class Window_Selectable < Window_Base
  #
  # 定义实例变量
  #
  #
  attr_reader   :index                    # 光标位置
  attr_reader   :help_window              # 帮助窗口
  #
  # 初始画对像
  #
  # x      : 窗口的 X 坐标
  # y      : 窗口的 Y 坐标
  # width  : 窗口的宽
  # height : 窗口的高
  #
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item_max = 1
    @column_max = 1
    @index = -1
  end
  #
  # 设置光标的位置
  #
  # index : 新的光标位置
  #
  def index=(index)
    @index = index
    # 刷新帮助文本 (update_help 定义了继承目标)
    if self.active and @help_window != nil
      update_help
    end
    # 刷新光标矩形
    update_cursor_rect
  end
  #
  # 获取行数
  #
  #
  def row_max
    # 由项目数和列数计算出行数
    return (@item_max + @column_max - 1) / @column_max
  end
  #
  # 获取开头行
  #
  #
  def top_row
    # 将窗口内容的传送源 Y 坐标、1 行的高 32 等分
    return self.oy / 32
  end
  #
  # 设置开头行
  #
  # row : 显示开头的行
  #
  def top_row=(row)
    # row 未满 0 的场合更正为 0
    if row < 0
      row = 0
    end
    # row 超过 row_max - 1 的情况下更正为 row_max - 1 
    if row > row_max - 1
      row = row_max - 1
    end
    # row 1 行高的 32 倍、窗口内容的传送源 Y 坐标
    self.oy = row * 32
  end
  #
  # 获取 1 页可以显示的行数
  #
  #
  def page_row_max
    # 窗口的高度，设置画面的高度减去 32 ，除以 1 行的高度 32 
    return (self.height - 32) / 32
  end
  #
  # 获取 1 页可以显示的项目数
  #
  #
  def page_item_max
    # 将行数 page_row_max 乘上列数 @column_max
    return page_row_max * @column_max
  end
  #
  # 帮助窗口的设置
  #
  # help_window : 新的帮助窗口
  #
  def help_window=(help_window)
    @help_window = help_window
    # 刷新帮助文本 (update_help 定义了继承目标)
    if self.active and @help_window != nil
      update_help
    end
  end
  #
  # 更新光标举行
  #
  #
  def update_cursor_rect
    # 光标位置不满 0 的情况下
    if @index < 0
      self.cursor_rect.empty
      return
    end
    # 获取当前的行
    row = @index / @column_max
    # 当前行被显示开头行前面的情况下
    if row < self.top_row
      # 从当前行向开头行滚动
      self.top_row = row
    end
    # 当前行被显示末尾行之后的情况下
    if row > self.top_row + (self.page_row_max - 1)
      # 从当前行向末尾滚动
      self.top_row = row - (self.page_row_max - 1)
    end
    # 计算光标的宽
    cursor_width = self.width / @column_max - 32
    # 计算光标坐标
    x = @index % @column_max * (cursor_width + 32)
    y = @index / @column_max * 32 - self.oy
    # 更新国标矩形
    self.cursor_rect.set(x, y, cursor_width, 32)
  end
  #
  # 刷新画面
  #
  #
  def update
    super
    # 可以移动光标的情况下
    if self.active and @item_max > 0 and @index >= 0
      # 方向键下被按下的情况下
      if Input.repeat?(Input::DOWN)
        # 列数不是 1 并且方向键的下的按下状态不是重复的情况、
        # 或光标位置在(项目数-列数)之前的情况下
        if (@column_max == 1 and Input.trigger?(Input::DOWN)) or
           @index < @item_max - @column_max
          # 光标向下移动
          $game_system.se_play($data_system.cursor_se)
          @index = (@index + @column_max) % @item_max
        end
      end
      # 方向键上被按下的情况下
      if Input.repeat?(Input::UP)
        # 列数不是 1 并且方向键的下的按下状态不是重复的情况、
        # 或光标位置在列之后的情况下
        if (@column_max == 1 and Input.trigger?(Input::UP)) or
           @index >= @column_max
          # 光标向上移动
          $game_system.se_play($data_system.cursor_se)
          @index = (@index - @column_max + @item_max) % @item_max
        end
      end
      # 方向键右被按下的情况下
      if Input.repeat?(Input::RIGHT)
        # 列数为 2 以上并且、光标位置在(项目数 - 1)之前的情况下
        if @column_max >= 2 and @index < @item_max - 1
          # 光标向右移动
          $game_system.se_play($data_system.cursor_se)
          @index += 1
        end
      end
      # 方向键左被按下的情况下
      if Input.repeat?(Input::LEFT)
        # 列数为 2 以上并且、光标位置在 0 之后的情况下
        if @column_max >= 2 and @index > 0
          # 光标向左移动
          $game_system.se_play($data_system.cursor_se)
          @index -= 1
        end
      end
      # R 键被按下的情况下
      if Input.repeat?(Input::R)
        # 显示的最后行在数据中最后行上方的情况下
        if self.top_row + (self.page_row_max - 1) < (self.row_max - 1)
          # 光标向后移动一页
          $game_system.se_play($data_system.cursor_se)
          @index = [@index + self.page_item_max, @item_max - 1].min
          self.top_row += self.page_row_max
        end
      end
      # L 键被按下的情况下
      if Input.repeat?(Input::L)
        # 显示的开头行在位置 0 之后的情况下
        if self.top_row > 0
          # 光标向前移动一页
          $game_system.se_play($data_system.cursor_se)
          @index = [@index - self.page_item_max, 0].max
          self.top_row -= self.page_row_max
        end
      end
    end
    # 刷新帮助文本 (update_help 定义了继承目标)
    if self.active and @help_window != nil
      update_help
    end
    # 刷新光标矩形
    update_cursor_rect
  end
end
