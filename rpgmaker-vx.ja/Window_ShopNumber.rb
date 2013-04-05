#
# ショップ画面で、購入または売却するアイテムの個数を入力するウィンドウです。
#

class Window_ShopNumber < Window_Base
  #
  # オブジェクト初期化
  #
  # x : ウィンドウの X 座標
  # y : ウィンドウの Y 座標
  #
  def initialize(x, y)
    super(x, y, 304, 304)
    @item = nil
    @max = 1
    @price = 0
    @number = 1
  end
  #
  # アイテム、最大個数、価格の設定
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
  # 入力された個数の設定
  #
  #
  def number
    return @number
  end
  #
  # リフレッシュ
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
  # フレーム更新
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
