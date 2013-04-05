#
# 商店画面、浏览显示可以卖掉的商品的窗口。
#

class Window_ShopSell < Window_Item
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
  end
  #
  # 列表中是否包含某物品
  #
  # item : 物品
  #
  def include?(item)
    return item != nil
  end
  #
  # 是否允许使用判定
  #
  # item : 物品
  #
  def enable?(item)
    return (item.price > 0)
  end
end
