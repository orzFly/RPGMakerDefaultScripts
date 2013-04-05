#
# バトル画面で、戦うか逃げるかを選択するウィンドウです。
#

class Window_PartyCommand < Window_Command
  #
  # オブジェクト初期化
  #
  #
  def initialize
    s1 = Vocab::fight
    s2 = Vocab::escape
    super(128, [s1, s2], 1, 4)
    draw_item(0, true)
    draw_item(1, $game_troop.can_escape)
    self.active = false
  end
end
