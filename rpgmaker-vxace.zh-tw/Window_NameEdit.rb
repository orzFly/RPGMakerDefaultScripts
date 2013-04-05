#encoding:utf-8
#
# 名字輸入畫面中，編輯名字的視窗。
#

class Window_NameEdit < Window_Base
  #
  # 定義案例變量
  #
  #
  attr_reader   :name                     # 名字
  attr_reader   :index                    # 游標位置
  attr_reader   :max_char                 # 最大文字數
  #
  # 初始化物件
  #
  #
  def initialize(actor, max_char)
    x = (Graphics.width - 360) / 2
    y = (Graphics.height - (fitting_height(4) + fitting_height(9) + 8)) / 2
    super(x, y, 360, fitting_height(4))
    @actor = actor
    @max_char = max_char
    @default_name = @name = actor.name[0, @max_char]
    @index = @name.size
    deactivate
    refresh
  end
  #
  # 還原預設的名字
  #
  #
  def restore_default
    @name = @default_name
    @index = @name.size
    refresh
    return !@name.empty?
  end
  #
  # 加入文字
  #
  # ch : 加入的文字
  #
  def add(ch)
    return false if @index >= @max_char
    @name += ch
    @index += 1
    refresh
    return true
  end
  #
  # 後退一個字元
  #
  #
  def back
    return false if @index == 0
    @index -= 1
    @name = @name[0, @index]
    refresh
    return true
  end
  #
  # 取得肖像的寬度
  #
  #
  def face_width
    return 96
  end
  #
  # 取得文字的寬度
  #
  #
  def char_width
    text_size("中").width
  end
  #
  # 取得名字繪制的左端坐標
  #
  #
  def left
    name_center = (contents_width + face_width) / 2
    name_width = (@max_char + 1) * char_width
    return [name_center - name_width / 2, contents_width - name_width].min
  end
  #
  # 取得專案的繪制矩形
  #
  #
  def item_rect(index)
    Rect.new(left + index * char_width, 36, char_width, line_height)
  end
  #
  # 取得下劃線的矩形
  #
  #
  def underline_rect(index)
    rect = item_rect(index)
    rect.x += 1
    rect.y += rect.height - 4
    rect.width -= 2
    rect.height = 2
    rect
  end
  #
  # 取得下劃線的顏色
  #
  #
  def underline_color
    color = normal_color
    color.alpha = 48
    color
  end
  #
  # 繪制下劃線
  #
  #
  def draw_underline(index)
    contents.fill_rect(underline_rect(index), underline_color)
  end
  #
  # 繪制文字
  #
  #
  def draw_char(index)
    rect = item_rect(index)
    rect.x -= 1
    rect.width += 4
    change_color(normal_color)
    draw_text(rect, @name[index] || "")
  end
  #
  # 重新整理
  #
  #
  def refresh
    contents.clear
    draw_actor_face(@actor, 0, 0)
    @max_char.times {|i| draw_underline(i) }
    @name.size.times {|i| draw_char(i) }
    cursor_rect.set(item_rect(@index))
  end
end
