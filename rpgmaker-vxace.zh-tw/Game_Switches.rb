#encoding:utf-8
#
# 處理開關的類。本質上是套了個殼的 Array 。本類的案例請參考 $game_switches 。
#

class Game_Switches
  #
  # 初始化物件
  #
  #
  def initialize
    @data = []
  end
  #
  # 取得開關
  #
  #
  def [](switch_id)
    @data[switch_id] || false
  end
  #
  # 設定開關
  #
  # value : 開啟 (true) / 關閉 (false)
  #
  def []=(switch_id, value)
    @data[switch_id] = value
    on_change
  end
  #
  # 設定開關時的處理
  #
  #
  def on_change
    $game_map.need_refresh = true
  end
end
