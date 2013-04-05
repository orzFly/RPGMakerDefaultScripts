#
# 商店画面、浏览显示可以卖掉的商品的窗口。
#

class Window_ShopSell < Window_Selectable
  #
  # 初始化对像
  #
  #
  def initialize
    super(0, 128, 640, 352)
    @column_max = 2
    refresh
    self.index = 0
  end
  #
  # 获取物品
  #
  #
  def item
    return @data[self.index]
  end
  #
  # 刷新
  #
  #
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    for i in 1...$data_items.size
      if $game_party.item_number(i) > 0
        @data.push($data_items[i])
      end
    end
    for i in 1...$data_weapons.size
      if $game_party.weapon_number(i) > 0
        @data.push($data_weapons[i])
      end
    end
    for i in 1...$data_armors.size
      if $game_party.armor_number(i) > 0
        @data.push($data_armors[i])
      end
    end
    # 如果项目数不是 0 就生成位图、描绘全部项目
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
  #
  # 描绘项目
  #
  # index : 项目标号
  #
  def draw_item(index)
    item = @data[index]
    case item
    when RPG::Item
      number = $game_party.item_number(item.id)
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    # 可以卖掉的显示为普通文字颜色、除此之外设置成无效文字颜色
    if item.price > 0
      self.contents.font.color = normal_color
    else
      self.contents.font.color = disabled_color
    end
    x = 4 + index % 2 * (288 + 32)
    y = index / 2 * 32
    rect = Rect.new(x, y, self.width / @column_max - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(item.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.draw_text(x + 28, y, 212, 32, item.name, 0)
    self.contents.draw_text(x + 240, y, 16, 32, ":", 1)
    self.contents.draw_text(x + 256, y, 24, 32, number.to_s, 2)
  end
  #
  # 刷新帮助文本
  #
  #
  def update_help
    @help_window.set_text(self.item == nil ? "" : self.item.description)
  end
end
