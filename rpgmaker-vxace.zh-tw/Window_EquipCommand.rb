#encoding:utf-8
#
# 技能畫面中，選擇指令（更換裝備／最強裝備／全部卸下）的視窗。
#

class Window_EquipCommand < Window_HorzCommand
  #
  # 初始化物件
  #
  #
  def initialize(x, y, width)
    @window_width = width
    super(x, y)
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    @window_width
  end
  #
  # 取得列數
  #
  #
  def col_max
    return 3
  end
  #
  # 生成指令清單
  #
  #
  def make_command_list
    add_command(Vocab::equip2,   :equip)
    add_command(Vocab::optimize, :optimize)
    add_command(Vocab::clear,    :clear)
  end
end
