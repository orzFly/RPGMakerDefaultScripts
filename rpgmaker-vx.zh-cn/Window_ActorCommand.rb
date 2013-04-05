#
# 战斗画面显示角色指令的窗口。
#

class Window_ActorCommand < Window_Command
  #
  # 初始化对像
  #
  #
  def initialize
    super(128, [], 1, 4)
    self.active = false
  end
  #
  # 设置自定义特技指令名称
  #
  # actor :角色
  #
  def setup(actor)
    s1 = Vocab::attack
    s2 = Vocab::skill
    s3 = Vocab::guard
    s4 = Vocab::item
    if actor.class.skill_name_valid     # 特技指令名称有效？
      s2 = actor.class.skill_name       # 替换指令名
    end
    @commands = [s1, s2, s3, s4]
    @item_max = 4
    refresh
    self.index = 0
  end
end
