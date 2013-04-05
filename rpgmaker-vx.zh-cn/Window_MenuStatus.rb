#
# 显示菜单画面和同伴状态的窗口。
#

class Window_MenuStatus < Window_Selectable
  #
  # 初始化目标
  #
  # x : 窗口的X坐标
  # y : 窗口的Y坐标
  #
  def initialize(x, y)
    super(x, y, 384, 416)
    refresh
    self.active = false
    self.index = -1
  end
  #
  # 刷新
  #
  #
  def refresh
    self.contents.clear
    @item_max = $game_party.members.size
    for actor in $game_party.members
      draw_actor_face(actor, 2, actor.index * 96 + 2, 92)
      x = 104
      y = actor.index * 96 + WLH / 2
      draw_actor_name(actor, x, y)
      draw_actor_class(actor, x + 120, y)
      draw_actor_level(actor, x, y + WLH * 1)
      draw_actor_state(actor, x, y + WLH * 2)
      draw_actor_hp(actor, x + 120, y + WLH * 1)
      draw_actor_mp(actor, x + 120, y + WLH * 2)
    end
  end
  #
  # 刷新光标矩形
  #
  #
  def update_cursor
    if @index < 0               # 没有光标
      self.cursor_rect.empty
    elsif @index < @item_max    # 通常
      self.cursor_rect.set(0, @index * 96, contents.width, 96)
    elsif @index >= 100         # 自己
      self.cursor_rect.set(0, (@index - 100) * 96, contents.width, 96)
    else                        # 全体
      self.cursor_rect.set(0, 0, contents.width, @item_max * 96)
    end
  end
end
