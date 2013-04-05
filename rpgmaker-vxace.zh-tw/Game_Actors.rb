#encoding:utf-8
#
# 包裝角色數組的外殼。本類的案例請參考 $game_actors 。
#

class Game_Actors
  #
  # 初始化物件
  #
  #
  def initialize
    @data = []
  end
  #
  # 取得角色
  #
  #
  def [](actor_id)
    return nil unless $data_actors[actor_id]
    @data[actor_id] ||= Game_Actor.new(actor_id)
  end
end
