#
# 战斗结束时、显示获得的 EXP 及金钱的窗口。
#

class Window_BattleResult < Window_Base
  #
  # 初始化对像
  #
  # exp       : EXP
  # gold      : 金钱
  # treasures : 宝物
  #
  def initialize(exp, gold, treasures)
    @exp = exp
    @gold = gold
    @treasures = treasures
    super(160, 0, 320, @treasures.size * 32 + 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.y = 160 - height / 2
    self.back_opacity = 160
    self.visible = false
    refresh
  end
  #
  # 刷新
  #
  #
  def refresh
    self.contents.clear
    x = 4
    self.contents.font.color = normal_color
    cx = contents.text_size(@exp.to_s).width
    self.contents.draw_text(x, 0, cx, 32, @exp.to_s)
    x += cx + 4
    self.contents.font.color = system_color
    cx = contents.text_size("EXP").width
    self.contents.draw_text(x, 0, 64, 32, "EXP")
    x += cx + 16
    self.contents.font.color = normal_color
    cx = contents.text_size(@gold.to_s).width
    self.contents.draw_text(x, 0, cx, 32, @gold.to_s)
    x += cx + 4
    self.contents.font.color = system_color
    self.contents.draw_text(x, 0, 128, 32, $data_system.words.gold)
    y = 32
    for item in @treasures
      draw_item_name(item, 4, y)
      y += 32
    end
  end
end
