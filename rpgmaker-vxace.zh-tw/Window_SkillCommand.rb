#encoding:utf-8
#
# 技能畫面中，選擇指令（特技／魔法等）的視窗。
#

class Window_SkillCommand < Window_Command
  #
  # 定義案例變量
  #
  #
  attr_reader   :skill_window
  #
  # 初始化物件
  #
  #
  def initialize(x, y)
    super(x, y)
    @actor = nil
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    return 160
  end
  #
  # 設定角色
  #
  #
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
    select_last
  end
  #
  # 取得顯示行數
  #
  #
  def visible_line_number
    return 4
  end
  #
  # 生成指令清單
  #
  #
  def make_command_list
    return unless @actor
    @actor.added_skill_types.sort.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id)
    end
  end
  #
  # 更新畫面
  #
  #
  def update
    super
    @skill_window.stype_id = current_ext if @skill_window
  end
  #
  # 設定技能視窗
  #
  #
  def skill_window=(skill_window)
    @skill_window = skill_window
    update
  end
  #
  # 返回上一個選擇的位置
  #
  #
  def select_last
    skill = @actor.last_skill.object
    if skill
      select_ext(skill.stype_id)
    else
      select(0)
    end
  end
end
