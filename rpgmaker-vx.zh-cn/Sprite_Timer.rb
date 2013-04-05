#
# 显示计时器用的活动块。监视 $game_system 、活动块状态
# 自动变化。
#

class Sprite_Timer < Sprite
  #
  # 初始化对像
  #
  # viewport : 视口
  #
  def initialize(viewport)
    super(viewport)
    self.bitmap = Bitmap.new(88, 48)
    self.bitmap.font.name = "Arial"
    self.bitmap.font.size = 32
    self.x = 544 - self.bitmap.width
    self.y = 0
    self.z = 200
    update
  end
  #
  # 释放
  #
  #
  def dispose
    self.bitmap.dispose
    super
  end
  #
  # 刷新画面
  #
  #
  def update
    super
    self.visible = $game_system.timer_working
    if $game_system.timer / Graphics.frame_rate != @total_sec
      self.bitmap.clear
      @total_sec = $game_system.timer / Graphics.frame_rate
      min = @total_sec / 60
      sec = @total_sec % 60
      text = sprintf("%02d:%02d", min, sec)
      self.bitmap.font.color.set(255, 255, 255)
      self.bitmap.draw_text(self.bitmap.rect, text, 1)
    end
  end
end
