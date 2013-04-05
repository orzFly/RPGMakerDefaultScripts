#encoding:utf-8
#
# 商店畫面中，買入時顯示所有商品的視窗。
#

class Window_ShopBuy < Window_Selectable
  #
  # 定義案例變量
  #
  #
  attr_reader   :status_window            # 狀態視窗
  #
  # 初始化物件
  #
  #
  def initialize(x, y, height, shop_goods)
    super(x, y, window_width, height)
    @shop_goods = shop_goods
    @money = 0
    refresh
    select(0)
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    return 304
  end
  #
  # 取得專案數
  #
  #
  def item_max
    @data ? @data.size : 1
  end
  #
  # 取得商品
  #
  #
  def item
    @data[index]
  end
  #
  # 設定持有金錢
  #
  #
  def money=(money)
    @money = money
    refresh
  end
  #
  # 取得選擇專案的有效狀態
  #
  #
  def current_item_enabled?
    enable?(@data[index])
  end
  #
  # 取得商品價格
  #
  #
  def price(item)
    @price[item]
  end
  #
  # 查詢商品是否可買
  #
  #
  def enable?(item)
    item && price(item) <= @money && !$game_party.item_max?(item)
  end
  #
  # 重新整理
  #
  #
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  #
  # 生成商品清單
  #
  #
  def make_item_list
    @data = []
    @price = {}
    @shop_goods.each do |goods|
      case goods[0]
      when 0;  item = $data_items[goods[1]]
      when 1;  item = $data_weapons[goods[1]]
      when 2;  item = $data_armors[goods[1]]
      end
      if item
        @data.push(item)
        @price[item] = goods[2] == 0 ? item.price : goods[3]
      end
    end
  end
  #
  # 繪制專案
  #
  #
  def draw_item(index)
    item = @data[index]
    rect = item_rect(index)
    draw_item_name(item, rect.x, rect.y, enable?(item))
    rect.width -= 4
    draw_text(rect, price(item), 2)
  end
  #
  # 設定狀態視窗
  #
  #
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  #
  # 更新說明內容
  #
  #
  def update_help
    @help_window.set_item(item) if @help_window
    @status_window.item = item if @status_window
  end
end
