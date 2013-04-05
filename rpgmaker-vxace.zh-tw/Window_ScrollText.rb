#encoding:utf-8
#
# 顯示卷動文字的視窗。
# 這類視窗沒有邊框，歸類為視窗只是為了方便。
# 視窗開啟時角色不能搬移。
#

class Window_ScrollText < Window_Base
  #
  # 初始化物件
  #
  #
  def initialize
    super(0, 0, Graphics.width, Graphics.height)
    self.opacity = 0
    self.arrows_visible = false
    hide
  end
  #
  # 更新畫面
  #
  #
  def update
    super
    if $game_message.scroll_mode
      update_message if @text
      start_message if !@text && $game_message.has_text?
    end
  end
  #
  # 開始訊息的顯示
  #
  #
  def start_message
    @text = $game_message.all_text
    refresh
    show
  end
  #
  # 重新整理
  #
  #
  def refresh
    reset_font_settings
    update_all_text_height
    create_contents
    draw_text_ex(4, 0, @text)
    self.oy = @scroll_pos = -height
  end
  #
  # 更新繪制所有內容所需的高度
  #
  #
  def update_all_text_height
    @all_text_height = 1
    convert_escape_characters(@text).each_line do |line|
      @all_text_height += calc_line_height(line, false)
    end
    reset_font_settings
  end
  #
  # 計算視窗內容的高度
  #
  #
  def contents_height
    @all_text_height ? @all_text_height : super
  end
  #
  # 更新訊息
  #
  #
  def update_message
    @scroll_pos += scroll_speed
    self.oy = @scroll_pos
    terminate_message if @scroll_pos >= contents.height
  end
  #
  # 取得卷動速度
  #
  #
  def scroll_speed
    $game_message.scroll_speed * (show_fast? ? 1.0 : 0.5)
  end
  #
  # 快進判定
  #
  #
  def show_fast?
    !$game_message.scroll_no_fast && (Input.press?(:A) || Input.press?(:C))
  end
  #
  # 結束訊息的顯示
  #
  #
  def terminate_message
    @text = nil
    $game_message.clear
    hide
  end
end
