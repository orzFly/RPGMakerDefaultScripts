#
# 名称输入画面、编辑名称的窗口。
#

class Window_NameEdit < Window_Base
  #
  # 定义实例变量
  #
  #
  attr_reader   :name                     # 名称
  attr_reader   :index                    # 光标位置
  attr_reader   :max_char                 # 最大字数
  #
  # 初始化对像
  #
  # actor    : 角色
  # max_char : 最大字数
  #
  def initialize(actor, max_char)
    super(88, 20, 368, 128)
    @actor = actor
    @name = actor.name
    @max_char = max_char
    name_array = @name.split(//)[0...@max_char]   # 控制名字在最大字数以内
    @name = ""
    for i in 0...name_array.size
      @name += name_array[i]
    end
    @default_name = @name
    @index = name_array.size
    self.active = false
    refresh
    update_cursor
  end
  #
  # 还原为默认的名称
  #
  #
  def restore_default
    @name = @default_name
    @index = @name.split(//).size
    refresh
    update_cursor
  end
  #
  # 添加文字
  #
  # character : 要添加的文字
  #
  def add(character)
    if @index < @max_char and character != ""
      @name += character
      @index += 1
      refresh
      update_cursor
    end
  end
  #
  # 删除文字
  #
  #
  def back
    if @index > 0
      name_array = @name.split(//)          # 删除一个字
      @name = ""
      for i in 0...name_array.size-1
        @name += name_array[i]
      end
      @index -= 1
      refresh
      update_cursor
    end
  end
  #
  # 获取描画项目的矩形
  #
  # index : 项目编号
  #
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.x = 220 - (@max_char + 1) * 12 + index * 24
    rect.y = 36
    rect.width = 24
    rect.height = WLH
    return rect
  end
  #
  # 刷新
  #
  #
  def refresh
    self.contents.clear
    draw_actor_face(@actor, 0, 0)
    name_array = @name.split(//)
    for i in 0...@max_char
      c = name_array[i]
      c = '_' if c == nil
      self.contents.draw_text(item_rect(i), c, 1)
    end
  end
  #
  # 刷新光标
  #
  #
  def update_cursor
    self.cursor_rect = item_rect(@index)
  end
  #
  # 刷新画面
  #
  #
  def update
    super
    update_cursor
  end
end
