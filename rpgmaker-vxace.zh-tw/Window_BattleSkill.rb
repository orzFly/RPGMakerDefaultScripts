#encoding:utf-8
#
# 戰鬥畫面中，選擇“使用技能”的視窗。
#

class Window_BattleSkill < Window_SkillList
  #
  # 初始化物件
  #
  # info_viewport : 訊息顯示用顯示連接埠
  #
  def initialize(help_window, info_viewport)
    y = help_window.height
    super(0, y, Graphics.width, info_viewport.rect.y - y)
    self.visible = false
    @help_window = help_window
    @info_viewport = info_viewport
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
