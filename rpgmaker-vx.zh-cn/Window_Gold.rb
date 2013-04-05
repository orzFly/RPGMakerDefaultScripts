#
# 显示金钱的窗口。
#

class Window_Gold < Window_Base
  #
  # 初始化窗口
  #
  # x : 窗口的X坐标
  # y : 窗口的Y坐标
  #
  def initialize(x, y)
    super(x, y, 160, WLH + 32)
    refresh
  end
  #
  # 刷新
  #
  #
  def refresh
    self.contents.clear
    draw_currency_value($game_party.gold, 4, 0, 120)
  end
end
