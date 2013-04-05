#
# 处理变量的类。编入的是类 Array 的外壳。
# 这个类的实例请参考 $game_variables。
#

class Game_Variables
  #
  # 初始化对象
  #
  #
  def initialize
    @data = []
  end
  #
  # 取得变量
  #
  # variable_id : 变量 ID
  #
  def [](variable_id)
    if @data[variable_id] == nil
      return 0
    else
      return @data[variable_id]
    end
  end
  #
  # 设定变量
  #
  # variable_id : 变量 ID
  # value       : 变量的值
  #
  def []=(variable_id, value)
    if variable_id <= 5000
      @data[variable_id] = value
    end
  end
end