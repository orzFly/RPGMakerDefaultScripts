#
# ショップ画面で、購入できる商品の一覧を表示するウィンドウです。
#

class Window_ShopBuy < Window_Selectable
  #
  # オブジェクト初期化
  #
  # x : ウィンドウの X 座標
  # y : ウィンドウの Y 座標
  #
  def initialize(x, y)
    super(x, y, 304, 304)
    @shop_goods = $game_temp.shop_goods
    refresh
    self.index = 0
  end
  #
  # アイテムの取得
  #
  #
  def item
    return @data[self.index]
  end
  #
  # リフレッシュ
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
  # 項目の描画
  #
  # index : 項目番号
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
  # ヘルプテキスト更新
  #
  #
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
end
