#encoding:utf-8
#
# 處理獨立開關的類。本質上是套了個殼的 Hash 。
# 本類的案例請參考 $game_self_switches 。
#

class Game_SelfSwitches
  #
  # 初始化物件
  #
  #
  def initialize
    @data = {}
  end
  #
  # 取得獨立開關
  #
  #
  def [](key)
    @data[key] == true
  end
  #
  # 設定獨立開關
  #
  # value : 開啟 (true) / 關閉 (false)
  #
  def []=(key, value)
    @data[key] = value
    on_change
  end
  #
  # 設定獨立開關時的處理
  #
  #
  def on_change
    $game_map.need_refresh = true
  end
end
