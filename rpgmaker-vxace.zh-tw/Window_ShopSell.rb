#encoding:utf-8
#
# 商店畫面中，賣出時顯示持有物品的視窗。
#

class Window_ShopSell < Window_ItemList
  #
  # 初始化物件
  #
  #
  def initialize(x, y, width, height)
    super(x, y, width, height)
  end
  #
  # 取得選擇專案的有效狀態
  #
  #
  def current_item_enabled?
    enable?(@data[index])
  end
  #
  # 查詢物品是否可賣
  #
  #
  def enable?(item)
    item && item.price > 0
  end
end
