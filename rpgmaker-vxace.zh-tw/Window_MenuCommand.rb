#encoding:utf-8
#
# 選單畫面中顯示指令的視窗
#

class Window_MenuCommand < Window_Command
  #
  # 初始化指令選擇位置（類方法）
  #
  #
  def self.init_command_position
    @@last_command_symbol = nil
  end
  #
  # 初始化物件
  #
  #
  def initialize
    super(0, 0)
    select_last
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    return 160
  end
  #
  # 取得顯示行數
  #
  #
  def visible_line_number
    item_max
  end
  #
  # 生成指令清單
  #
  #
  def make_command_list
    add_main_commands
    add_formation_command
    add_original_commands
    add_save_command
    add_game_end_command
  end
  #
  # 向指令清單加入主要的指令
  #
  #
  def add_main_commands
    add_command(Vocab::item,   :item,   main_commands_enabled)
    add_command(Vocab::skill,  :skill,  main_commands_enabled)
    add_command(Vocab::equip,  :equip,  main_commands_enabled)
    add_command(Vocab::status, :status, main_commands_enabled)
  end
  #
  # 加入整隊指令
  #
  #
  def add_formation_command
    add_command(Vocab::formation, :formation, formation_enabled)
  end
  #
  # 獨自加入指令用
  #
  #
  def add_original_commands
  end
  #
  # 加入存檔指令
  #
  #
  def add_save_command
    add_command(Vocab::save, :save, save_enabled)
  end
  #
  # 加入游戲結束指令
  #
  #
  def add_game_end_command
    add_command(Vocab::game_end, :game_end)
  end
  #
  # 取得主要指令的有效狀態
  #
  #
  def main_commands_enabled
    $game_party.exists
  end
  #
  # 取得整隊的有效狀態
  #
  #
  def formation_enabled
    $game_party.members.size >= 2 && !$game_system.formation_disabled
  end
  #
  # 取得存檔的有效狀態
  #
  #
  def save_enabled
    !$game_system.save_disabled
  end
  #
  # 按下確定鍵時的處理
  #
  #
  def process_ok
    @@last_command_symbol = current_symbol
    super
  end
  #
  # 返回最後一個選項的位置
  #
  #
  def select_last
    select_symbol(@@last_command_symbol)
  end
end
