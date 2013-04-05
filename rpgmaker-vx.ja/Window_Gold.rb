#
# ゴールドを表示するウィンドウです。
#

class Window_Gold < Window_Base
  #
  # オブジェクト初期化
  #
  # x : ウィンドウの X 座標
  # y : ウィンドウの Y 座標
  #
  def initialize(x, y)
    super(x, y, 160, WLH + 32)
    refresh
  end
  #
  # リフレッシュ
  #
  #
  def refresh
    self.contents.clear
    draw_currency_value($game_party.gold, 4, 0, 120)
  end
end
