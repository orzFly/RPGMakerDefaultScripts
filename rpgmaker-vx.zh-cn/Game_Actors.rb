#
# 处理角色排列的类。
# 这个类的实例请参考$game_actors。
#

class Game_Actors
  #
  # 初始化对象
  #
  #
  def initialize
    @data = []
  end
  #
  # 取得角色
  #
  # actor_id : 角色 ID
  #
  def [](actor_id)
    if @data[actor_id] == nil and $data_actors[actor_id] != nil
      @data[actor_id] = Game_Actor.new(actor_id)
    end
    return @data[actor_id]
  end
end