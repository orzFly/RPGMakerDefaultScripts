#
# 商店画面、输入买卖数量的窗口。
#

class Window_ShopNumber < Window_Base
  #
  # 初始化对像
  #
  # x : 窗口的X坐标
  # y : 窗口的Y坐标
  #
  def initialize(x, y)
    super(x, y, 304, 304)
    @item = nil
    @max = 1
    @price = 0
    @number = 1
  end
  #
  # 设置物品、最大个数、价格
  #
  #
  def set(item, max, price)
    @item = item
    @max = max
    @price = price
    @number = 1
    refresh
  end
  #
  # 被输入的个数设置
  #
  #
  def number
    return @number
  end
  #
  # 刷新
  #
  #
  def refresh
    y = 96
    self.contents.clear
    draw_item_name(@item, 0, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(212, y, 20, WLH, "×")
    self.contents.draw_text(248, y, 20, WLH, @number, 2)
    self.cursor_rect.set(244, y, 28, WLH)
    draw_currency_value(@price * @number, 4, y + WLH * 2, 264)
  end
  #
  # 刷新画面
  #
  #
  def update
    super
    if self.active
      last_number = @number
      if Input.repeat?(Input::RIGHT) and @number < @max
        @number += 1
      end
      if Input.repeat?(Input::LEFT) and @number > 1
        @number -= 1
      end
      if Input.repeat?(Input::UP) and @number < @max
        @number = [@number + 10, @max].min
      end
      if Input.repeat?(Input::DOWN) and @number > 1
        @number = [@number - 10, 1].max
      end
      if @number != last_number
        Sound.play_cursor
        refresh
      end
    end
  end
end
