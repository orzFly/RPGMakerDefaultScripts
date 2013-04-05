#
# 商店画面、浏览显示可以购买的商品的窗口。
#

class Window_ShopBuy < Window_Selectable
  #
  # 初始化对像
  #
  # x : 窗口的X坐标
  # y : 窗口的Y坐标
  #
  def initialize(x, y)
    super(x, y, 304, 304)
    @shop_goods = $game_temp.shop_goods
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
    @data = []
    for goods_item in @shop_goods
      case goods_item[0]
      when 0
        item = $data_items[goods_item[1]]
      when 1
        item = $data_weapons[goods_item[1]]
      when 2
        item = $data_armors[goods_item[1]]
      end
      if item != nil
        @data.push(item)
      end
    end
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
    item = @data[index]
    number = $game_party.item_number(item)
    enabled = (item.price <= $game_party.gold and number < 99)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    draw_item_name(item, rect.x, rect.y, enabled)
    rect.width -= 4
    self.contents.draw_text(rect, item.price, 2)
  end
  #
  # 刷新帮助文本
  #
  #
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
end
