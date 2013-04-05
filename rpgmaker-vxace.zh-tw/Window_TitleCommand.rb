#encoding:utf-8
#
# 標題畫面中，選擇“開始游戲／繼續游戲”的視窗。
#

class Window_TitleCommand < Window_Command
  #
  # 初始化物件
  #
  #
  def initialize
    super(0, 0)
    update_placement
    select_symbol(:continue) if continue_enabled
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
    self.y = (Graphics.height * 1.6 - height) / 2
  end
  #
  # 生成指令清單
  #
  #
  def make_command_list
    add_command(Vocab::new_game, :new_game)
    add_command(Vocab::continue, :continue, continue_enabled)
    add_command(Vocab::shutdown, :shutdown)
  end
  #
  # 取得“繼續游戲”選項是否有效
  #
  #
  def continue_enabled
    DataManager.save_file_exists?
  end
end
