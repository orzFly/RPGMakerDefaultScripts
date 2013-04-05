#encoding:utf-8
#
# 游戲結束畫面中，選擇“返回標題／離開游戲”的視窗。
#

class Window_GameEnd < Window_Command
  #
  # 初始化物件
  #
  #
  def initialize
    super(0, 0)
    update_placement
    self.openness = 0
    open
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    return 160
  end
  #
  # 更新視窗的位置
  #
  #
  def update_placement
    self.x = (Graphics.width - width) / 2
    self.y = (Graphics.height - height) / 2
  end
  #
  # 生成指令清單
  #
  #
  def make_command_list
    add_command(Vocab::to_title, :to_title)
    add_command(Vocab::shutdown, :shutdown)
    add_command(Vocab::cancel,   :cancel)
  end
end
