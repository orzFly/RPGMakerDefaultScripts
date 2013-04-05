#encoding:utf-8
#
# 在沒有存檔的情況下，處理臨時資料的類。本類的案例請參考 $game_temp 。
#

class Game_Temp
  #
  # 定義案例變量
  #
  #
  attr_reader   :common_event_id          # 公共事件ID
  attr_accessor :fade_type                # 場所搬移時的淡出類型
  #
  # 初始化物件
  #
  #
  def initialize
    @common_event_id = 0
    @fade_type = 0
  end
  #
  # 預定呼叫的公共事件
  #
  #
  def reserve_common_event(common_event_id)
    @common_event_id = common_event_id
  end
  #
  # 清除預定呼叫的公共事件
  #
  #
  def clear_common_event
    @common_event_id = 0
  end
  #
  # 判定是否存在預定呼叫的公共事件
  #
  #
  def common_event_reserved?
    @common_event_id > 0
  end
  #
  # 取得當前預定的公共事件
  #
  #
  def reserved_common_event
    $data_common_events[@common_event_id]
  end
end
