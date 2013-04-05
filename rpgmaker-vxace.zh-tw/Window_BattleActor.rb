#encoding:utf-8
#
# 戰鬥畫面中，選擇“隊友目的”的視窗。
#

class Window_BattleActor < Window_BattleStatus
  #
  # 初始化物件
  #
  # info_viewport : 訊息顯示用顯示連接埠
  #
  def initialize(info_viewport)
    super()
    self.y = info_viewport.rect.y
    self.visible = false
    self.openness = 255
    @info_viewport = info_viewport
  end
  #
  # 顯示視窗
  #
  #
  def show
    if @info_viewport
      width_remain = Graphics.width - width
      self.x = width_remain
      @info_viewport.rect.width = width_remain
      select(0)
    end
    super
  end
  #
  # 隱藏視窗
  #
  #
  def hide
    @info_viewport.rect.width = Graphics.width if @info_viewport
    super
  end
end
