#
# スキル画面で、スキル使用者のステータスを表示するウィンドウです。
#

class Window_SkillStatus < Window_Base
  #
  # オブジェクト初期化
  #
  # x     : ウィンドウの X 座標
  # y     : ウィンドウの Y 座標
  # actor : アクター
  #
  def initialize(x, y, actor)
    super(x, y, 544, WLH + 32)
    @actor = actor
    refresh
  end
  #
  # リフレッシュ
  #
  #
  def refresh
    self.contents.clear
    draw_actor_name(@actor, 4, 0)
    draw_actor_level(@actor, 140, 0)
    draw_actor_hp(@actor, 240, 0)
    draw_actor_mp(@actor, 392, 0)
  end
end
