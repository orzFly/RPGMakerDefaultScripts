#encoding:utf-8
#
# 技能畫面中，顯示技能使用者狀態的視窗。
#

class Window_SkillStatus < Window_Base
  #
  # 初始化物件
  #
  #
  def initialize(x, y)
    super(x, y, window_width, fitting_height(4))
    @actor = nil
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    Graphics.width - 160
  end
  #
  # 設定角色
  #
  #
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #
  # 重新整理
  #
  #
  def refresh
    contents.clear
    return unless @actor
    draw_actor_face(@actor, 0, 0)
    draw_actor_simple_status(@actor, 108, line_height / 2)
  end
end
