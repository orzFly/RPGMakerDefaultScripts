#
# 显示特技画面、特技使用者的窗口。
#

class Window_SkillStatus < Window_Base
  #
  # 初始化对像
  #
  # x : 窗口的X坐标
  # y : 窗口的Y坐标
  # actor  : 角色
  #
  def initialize(x, y, actor)
    super(x, y, 544, WLH + 32)
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
    draw_actor_level(@actor, 140, 0)
    draw_actor_hp(@actor, 240, 0)
    draw_actor_mp(@actor, 392, 0)
  end
end
