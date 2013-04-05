#
# バトル画面でパーティメンバーのステータスを表示するウィンドウです。
#

class Window_BattleStatus < Window_Selectable
  #
  # オブジェクト初期化
  #
  #
  def initialize
    super(0, 0, 416, 128)
    refresh
    self.active = false
  end
  #
  # 解放
  #
  #
  def dispose
    super
  end
  #
  # リフレッシュ
  #
  #
  def refresh
    self.contents.clear
    @item_max = $game_party.members.size
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #
  # 項目の描画
  #
  # index   : 項目番号
  #
  def draw_item(index)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    actor = $game_party.members[index]
    draw_actor_name(actor, 4, rect.y)
    draw_actor_state(actor, 114, rect.y, 48)
    draw_actor_hp(actor, 174, rect.y, 120)
    draw_actor_mp(actor, 310, rect.y, 70)
  end
end
