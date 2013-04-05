#encoding:utf-8
#
# 戰鬥畫面中，選擇“戰鬥／撤退”的視窗。
#

class Window_PartyCommand < Window_Command
  #
  # 初始化物件
  #
  #
  def initialize
    super(0, 0)
    self.openness = 0
    deactivate
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    return 128
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
    add_command(Vocab::fight,  :fight)
    add_command(Vocab::escape, :escape, BattleManager.can_escape?)
  end
  #
  # 設定
  #
  #
  def setup
    clear_command_list
    make_command_list
    refresh
    select(0)
    activate
    open
  end
end
