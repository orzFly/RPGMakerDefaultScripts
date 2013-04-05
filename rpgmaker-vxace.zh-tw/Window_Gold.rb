#encoding:utf-8
#
# 顯示持有金錢的視窗
#

class Window_Gold < Window_Base
  #
  # 初始化物件
  #
  #
  def initialize
    super(0, 0, window_width, fitting_height(1))
    refresh
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    return 160
  end
  #
  # 重新整理
  #
  #
  def refresh
    contents.clear
    draw_currency_value(value, currency_unit, 4, 0, contents.width - 8)
  end
  #
  # 取得持有金錢
  #
  #
  def value
    $game_party.gold
  end
  #
  # 取得貨幣單位
  #
  #
  def currency_unit
    Vocab::currency_unit
  end
  #
  # 開啟視窗
  #
  #
  def open
    refresh
    super
  end
end
