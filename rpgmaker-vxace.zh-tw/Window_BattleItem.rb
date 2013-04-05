#encoding:utf-8
#
# 戰鬥畫面中，選擇“使用物品”的視窗。
#

class Window_BattleItem < Window_ItemList
  #
  # 初始化物件
  #
  # info_viewport : 訊息顯示用的顯示連接埠
  #
  def initialize(help_window, info_viewport)
    y = help_window.height
    super(0, y, Graphics.width, info_viewport.rect.y - y)
    self.visible = false
    @help_window = help_window
    @info_viewport = info_viewport
  end
  #
  # 查詢使用清單中是否含有此物品
  #
  #
  def include?(item)
    $game_party.usable?(item)
  end
  #
  # 顯示視窗
  #
  #
  def show
    select_last
    @help_window.show
    super
  end
  #
  # 隱藏視窗
  #
  #
  def hide
    @help_window.hide
    super
  end
end
