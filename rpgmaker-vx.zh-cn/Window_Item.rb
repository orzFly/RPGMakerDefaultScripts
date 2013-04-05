#
# 物品画面中、显示浏览物品的窗口。
#

class Window_Item < Window_Selectable
  #
  # 初始化对像
  #
  # x : 窗口的X坐标
  # y : 窗口的Y坐标
  # width  : 窗口的宽
  # height : 窗口的高
  #
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @column_max = 2
    self.index = 0
    refresh
  end
  #
  # 获取物品
  #
  #
  def item
    return @data[self.index]
  end
  #
  # 列表中是否包含某物品
  #
  # item : 物品
  #
  def include?(item)
    return false if item == nil
    if $game_temp.in_battle
      return false unless item.is_a?(RPG::Item)
    end
    return true
  end
  #
  # 是否允许使用判定
  #
  # item : 物品
  #
  def enable?(item)
    return $game_party.item_can_use?(item)
  end
  #
  # 刷新
  #
  #
  def refresh
    @data = []
    for item in $game_party.items
      next unless include?(item)
      @data.push(item)
      if item.is_a?(RPG::Item) and item.id == $game_party.last_item_id
        self.index = @data.size - 1
      end
    end
    @data.push(nil) if include?(nil)
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #
  # 描绘项目
  #
  # index : 项目编号
  #
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    if item != nil
      number = $game_party.item_number(item)
      enabled = enable?(item)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enabled)
      self.contents.draw_text(rect, sprintf(":%2d", number), 2)
    end
  end
  #
  # 刷新帮助文本
  #
  #
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
end
