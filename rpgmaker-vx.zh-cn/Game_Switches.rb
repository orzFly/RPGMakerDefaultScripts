#
# 处理开关的类。编入的是类 Array 的外壳。
# 这个类的实例请参考 $game_switches。
#

class Game_Switches
  #
  # 初始化对象
  #
  #
  def initialize
    @data = []
  end
  #
  # 取得开关
  #
  # switch_id : 开关 ID
  #
  def [](switch_id)
    if @data[switch_id] == nil
      return false
    else
      return @data[switch_id]
    end
  end
  #
  # 设定开关
  #
  # switch_id : 开关 ID
  # value     : ON (true) / OFF (false)
  #
  def []=(switch_id, value)
    if switch_id <= 5000
      @data[switch_id] = value
    end
  end
end
