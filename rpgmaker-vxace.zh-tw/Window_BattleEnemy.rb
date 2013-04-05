#encoding:utf-8
#
# 戰鬥畫面中，選擇“敵人目的”的視窗。
#

class Window_BattleEnemy < Window_Selectable
  #
  # 初始化物件
  #
  # info_viewport : 訊息顯示用顯示連接埠
  #
  def initialize(info_viewport)
    super(0, info_viewport.rect.y, window_width, fitting_height(4))
    refresh
    self.visible = false
    @info_viewport = info_viewport
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    Graphics.width - 128
  end
  #
  # 取得列數
  #
  #
  def col_max
    return 2
  end
  #
  # 取得專案數
  #
  #
  def item_max
    $game_troop.alive_members.size
  end
  #
  # 取得敵人案例
  #
  #
  def enemy
    $game_troop.alive_members[@index]
  end
  #
  # 繪制專案
  #
  #
  def draw_item(index)
    change_color(normal_color)
    name = $game_troop.alive_members[index].name
    draw_text(item_rect_for_text(index), name)
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
