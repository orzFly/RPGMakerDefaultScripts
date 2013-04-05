#
# 处理公共事件的类。包含执行并行事件的功能。
# 本类在 Game_Map 类 ($game_map) 的内部使用。
#

class Game_CommonEvent
  #
  # 初始化对像
  #
  # common_event_id : 公共事件 ID
  #
  def initialize(common_event_id)
    @common_event_id = common_event_id
    @interpreter = nil
    refresh
  end
  #
  # 获取名称
  #
  #
  def name
    return $data_common_events[@common_event_id].name
  end
  #
  # 获取目标
  #
  #
  def trigger
    return $data_common_events[@common_event_id].trigger
  end
  #
  # 获取条件开关 ID
  #
  #
  def switch_id
    return $data_common_events[@common_event_id].switch_id
  end
  #
  # 获取执行内容
  #
  #
  def list
    return $data_common_events[@common_event_id].list
  end
  #
  # 刷新
  #
  #
  def refresh
    if self.trigger == 2 and $game_switches[self.switch_id] == true
      @interpreter = Game_Interpreter.new if @interpreter == nil
    else
      @interpreter = nil
    end
  end
  #
  # 刷新画面
  #
  #
  def update
    if @interpreter != nil                # 并行处理有效的情况下
      unless @interpreter.running?        # 不在执行中的场合的情况下
        @interpreter.setup(self.list)     # 设置事件
      end
      @interpreter.update                 # 更新解释器
    end
  end
end
