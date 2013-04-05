#
# 显示特技画面、特技使用者的窗口。
#

class Window_SkillStatus < Window_Base
  #
  # 初始化对像
  #
  # actor : 角色
  #
  def initialize(actor)
    super(0, 64, 640, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    refresh
  end
  #
  # 刷新
  #
  #
  def refresh
    self.contents.clear
    draw_actor_name(@actor, 4, 0)
    draw_actor_state(@actor, 140, 0)
    draw_actor_hp(@actor, 284, 0)
    draw_actor_sp(@actor, 460, 0)
  end
end
