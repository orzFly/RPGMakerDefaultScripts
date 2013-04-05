#encoding:utf-8
#
# 處理變量的類。本質上是套了個殼的 Array 。本類的案例請參考 $game_variables 。
#

class Game_Variables
  #
  # 初始化物件
  #
  #
  def initialize
    @data = []
  end
  #
  # 取得變量
  #
  #
  def [](variable_id)
    @data[variable_id] || 0
  end
  #
  # 設定變量
  #
  #
  def []=(variable_id, value)
    @data[variable_id] = value
    on_change
  end
  #
  # 設定變量時的處理
  #
  #
  def on_change
    $game_map.need_refresh = true
  end
end
