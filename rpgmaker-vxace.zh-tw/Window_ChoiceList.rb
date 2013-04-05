#encoding:utf-8
#
# 此視窗使用於事件指令中的“顯示選項”的功能。
#

class Window_ChoiceList < Window_Command
  #
  # 初始化物件
  #
  #
  def initialize(message_window)
    @message_window = message_window
    super(0, 0)
    self.openness = 0
    deactivate
  end
  #
  # 開始輸入的處理
  #
  #
  def start
    update_placement
    refresh
    select(0)
    open
    activate
  end
  #
  # 更新視窗的位置
  #
  #
  def update_placement
    self.width = [max_choice_width + 12, 96].max + padding * 2
    self.width = [width, Graphics.width].min
    self.height = fitting_height($game_message.choices.size)
    self.x = Graphics.width - width
    if @message_window.y >= Graphics.height / 2
      self.y = @message_window.y - height
    else
      self.y = @message_window.y + @message_window.height
    end
  end
  #
  # 取得選項的最大寬度
  #
  #
  def max_choice_width
    $game_message.choices.collect {|s| text_size(s).width }.max
  end
  #
  # 計算視窗內容的高度
  #
  #
  def contents_height
    item_max * item_height
  end
  #
  # 生成指令清單
  #
  #
  def make_command_list
    $game_message.choices.each do |choice|
      add_command(choice, :choice)
    end
  end
  #
  # 繪制專案
  #
  #
  def draw_item(index)
    rect = item_rect_for_text(index)
    draw_text_ex(rect.x, rect.y, command_name(index))
  end
  #
  # 取得“取消處理”的有效狀態
  #
  #
  def cancel_enabled?
    $game_message.choice_cancel_type > 0
  end
  #
  # 呼叫“確定”的處理方法
  #
  #
  def call_ok_handler
    $game_message.choice_proc.call(index)
    close
  end
  #
  # 呼叫“取消”的處理方法
  #
  #
  def call_cancel_handler
    $game_message.choice_proc.call($game_message.choice_cancel_type - 1)
    close
  end
end
