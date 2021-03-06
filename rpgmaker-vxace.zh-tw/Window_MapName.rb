#encoding:utf-8
#
# 顯示地圖名稱的視窗。
#

class Window_MapName < Window_Base
  #
  # 初始化物件
  #
  #
  def initialize
    super(0, 0, window_width, fitting_height(1))
    self.opacity = 0
    self.contents_opacity = 0
    @show_count = 0
    refresh
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    return 240
  end
  #
  # 更新畫面
  #
  #
  def update
    super
    if @show_count > 0 && $game_map.name_display
      update_fadein
      @show_count -= 1
    else
      update_fadeout
    end
  end
  #
  # 更新淡入
  #
  #
  def update_fadein
    self.contents_opacity += 16
  end
  #
  # 更新淡出
  #
  #
  def update_fadeout
    self.contents_opacity -= 16
  end
  #
  # 開啟視窗
  #
  #
  def open
    refresh
    @show_count = 150
    self.contents_opacity = 0
    self
  end
  #
  # 關閉視窗
  #
  #
  def close
    @show_count = 0
    self
  end
  #
  # 重新整理
  #
  #
  def refresh
    contents.clear
    unless $game_map.display_name.empty?
      draw_background(contents.rect)
      draw_text(contents.rect, $game_map.display_name, 1)
    end
  end
  #
  # 繪制背景
  #
  #
  def draw_background(rect)
    temp_rect = rect.clone
    temp_rect.width /= 2
    contents.gradient_fill_rect(temp_rect, back_color2, back_color1)
    temp_rect.x = temp_rect.width
    contents.gradient_fill_rect(temp_rect, back_color1, back_color2)
  end
  #
  # 取得背景色 1
  #
  #
  def back_color1
    Color.new(0, 0, 0, 192)
  end
  #
  # 取得背景色 2
  #
  #
  def back_color2
    Color.new(0, 0, 0, 0)
  end
end
