#
# 处理独立开关的类。编入的是类 Hash 的外壳。
# 这个类的实例请参考 $game_self_switches。
#

class Game_SelfSwitches
  #
  # 初始化对象
  #
  #
  def initialize
    @data = {}
  end
  #
  # 取得独立开关
  #
  # key : 键
  #
  def [](key)
    return @data[key] == true ? true : false
  end
  #
  # 设定独立开关
  #
  # key   : 键
  # value : ON (true) / OFF (false)
  #
  def []=(key, value)
    @data[key] = value
  end
end