#
# メッセージウィンドウの内部で使用する、数値入力用のウィンドウです。
#

class Window_NumberInput < Window_Base
  #
  # オブジェクト初期化
  #
  # digits_max : 桁数
  #
  def initialize
    super(0, 0, 544, 64)
    @number = 0
    @digits_max = 6
    @index = 0
    self.opacity = 0
    self.active = false
    self.z += 9999
    refresh
    update_cursor
  end
  #
  # 数値の取得
  #
  #
  def number
    return @number
  end
  #
  # 数値の設定
  #
  # number : 新しい数値
  #
  def number=(number)
    @number = [[number, 0].max, 10 ** @digits_max - 1].min
    @index = 0
    refresh
  end
  #
  # 桁数の取得
  #
  #
  def digits_max
    return @digits_max
  end
  #
  # 桁数の設定
  #
  # digits_max : 新しい桁数
  #
  def digits_max=(digits_max)
    @digits_max = digits_max
    refresh
  end
  #
  # カーソルを右に移動
  #
  # wrap : ラップアラウンド許可
  #
  def cursor_right(wrap)
    if @index < @digits_max - 1 or wrap
      @index = (@index + 1) % @digits_max
    end
  end
  #
  # カーソルを左に移動
  #
  # wrap : ラップアラウンド許可
  #
  def cursor_left(wrap)
    if @index > 0 or wrap
      @index = (@index + @digits_max - 1) % @digits_max
    end
  end
  #
  # フレーム更新
  #
  #
  def update
    super
    if self.active
      if Input.repeat?(Input::UP) or Input.repeat?(Input::DOWN)
        Sound.play_cursor
        place = 10 ** (@digits_max - 1 - @index)
        n = @number / place % 10
        @number -= n * place
        n = (n + 1) % 10 if Input.repeat?(Input::UP)
        n = (n + 9) % 10 if Input.repeat?(Input::DOWN)
        @number += n * place
        refresh
      end
      last_index = @index
      if Input.repeat?(Input::RIGHT)
        cursor_right(Input.trigger?(Input::RIGHT))
      end
      if Input.repeat?(Input::LEFT)
        cursor_left(Input.trigger?(Input::LEFT))
      end
      if @index != last_index
        Sound.play_cursor
      end
      update_cursor
    end
  end
  #
  # リフレッシュ
  #
  #
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    s = sprintf("%0*d", @digits_max, @number)
    for i in 0...@digits_max
      self.contents.draw_text(24 + i * 16, 0, 16, WLH, s[i,1], 1)
    end
  end
  #
  # カーソルの更新
  #
  #
  def update_cursor
    self.cursor_rect.set(24 + @index * 16, 0, 16, WLH)
  end
end
