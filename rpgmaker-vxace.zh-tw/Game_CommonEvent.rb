#encoding:utf-8
#
# 管理公共事件的類。擁有執行並行事件的功能。
# 本類在 Game_Map 類 ($game_map) 的內定使用。
#

class Game_CommonEvent
  #
  # 初始化物件
  #
  #
  def initialize(common_event_id)
    @event = $data_common_events[common_event_id]
    refresh
  end
  #
  # 重新整理
  #
  #
  def refresh
    if active?
      @interpreter ||= Game_Interpreter.new
    else
      @interpreter = nil
    end
  end
  #
  # 有效狀態判定
  #
  #
  def active?
    @event.parallel? && $game_switches[@event.switch_id]
  end
  #
  # 更新畫面
  #
  #
  def update
    if @interpreter
      @interpreter.setup(@event.list) unless @interpreter.running?
      @interpreter.update
    end
  end
end
