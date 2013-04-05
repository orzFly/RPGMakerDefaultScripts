#
# 特技画面中、显示可以使用的特技浏览的窗口
#

class Window_Skill < Window_Selectable
  #
  # 初始化对像
  #
  # x : 窗口的X坐标
  # y : 窗口的Y坐标
  # width  : 窗口的宽
  # height : 窗口的高
  # actor  : 角色
  #
  def initialize(x, y, width, height, actor)
    super(x, y, width, height)
    @actor = actor
    @column_max = 2
    self.index = 0
    refresh
  end
  #
  # 获取特技
  #
  #
  def skill
    return @data[self.index]
  end
  #
  # 刷新
  #
  #
  def refresh
    @data = []
    for skill in @actor.skills
      @data.push(skill)
      if skill.id == @actor.last_skill_id
        self.index = @data.size - 1
      end
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #
  # 描绘项目
  #
  # index : 项目编号
  #
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    skill = @data[index]
    if skill != nil
      rect.width -= 4
      enabled = @actor.skill_can_use?(skill)
      draw_item_name(skill, rect.x, rect.y, enabled)
      self.contents.draw_text(rect, @actor.calc_mp_cost(skill), 2)
    end
  end
  #
  # 刷新帮助文本
  #
  #
  def update_help
    @help_window.set_text(skill == nil ? "" : skill.description)
  end
end
