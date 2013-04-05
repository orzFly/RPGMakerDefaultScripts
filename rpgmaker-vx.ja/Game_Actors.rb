#
# アクターの配列を扱うクラスです。このクラスのインスタンスは $game_actors で
# 参照されます。
#

class Game_Actors
  #
  # オブジェクト初期化
  #
  #
  def initialize
    @data = []
  end
  #
  # アクターの取得
  #
  # actor_id : アクター ID
  #
  def [](actor_id)
    if @data[actor_id] == nil and $data_actors[actor_id] != nil
      @data[actor_id] = Game_Actor.new(actor_id)
    end
    return @data[actor_id]
  end
end
