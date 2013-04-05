#
# ショップ画面で、売却のために所持アイテムの一覧を表示するウィンドウです。
#

class Window_ShopSell < Window_Item
  #
  # オブジェクト初期化
  #
  # x      : ウィンドウの X 座標
  # y      : ウィンドウの Y 座標
  # width  : ウィンドウの幅
  # height : ウィンドウの高さ
  #
  def initialize(x, y, width, height)
    super(x, y, width, height)
  end
  #
  # アイテムをリストに含めるかどうか
  #
  # item : アイテム
  #
  def include?(item)
    return item != nil
  end
  #
  # アイテムを許可状態で表示するかどうか
  #
  # item : アイテム
  #
  def enable?(item)
    return (item.price > 0)
  end
end
