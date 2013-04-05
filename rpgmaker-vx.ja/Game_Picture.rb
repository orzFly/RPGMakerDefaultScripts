#
# ピクチャを扱うクラスです。このクラスは Game_Screen クラスの内部で使用され
# ます。マップ画面のピクチャとバトル画面のピクチャは別々に扱われます。
#

class Game_Picture
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :number                   # ピクチャ番号
  attr_reader   :name                     # ファイル名
  attr_reader   :origin                   # 原点
  attr_reader   :x                        # X 座標
  attr_reader   :y                        # Y 座標
  attr_reader   :zoom_x                   # X 方向拡大率
  attr_reader   :zoom_y                   # Y 方向拡大率
  attr_reader   :opacity                  # 不透明度
  attr_reader   :blend_type               # ブレンド方法
  attr_reader   :tone                     # 色調
  attr_reader   :angle                    # 回転角度
  #
  # オブジェクト初期化
  #
  # number : ピクチャ番号
  #
  def initialize(number)
    @number = number
    @name = ""
    @origin = 0
    @x = 0.0
    @y = 0.0
    @zoom_x = 100.0
    @zoom_y = 100.0
    @opacity = 255.0
    @blend_type = 1
    @duration = 0
    @target_x = @x
    @target_y = @y
    @target_zoom_x = @zoom_x
    @target_zoom_y = @zoom_y
    @target_opacity = @opacity
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @angle = 0
    @rotate_speed = 0
  end
  #
  # ピクチャの表示
  #
  # name         : ファイル名
  # origin       : 原点
  # x            : X 座標
  # y            : Y 座標
  # zoom_x       : X 方向拡大率
  # zoom_y       : Y 方向拡大率
  # opacity      : 不透明度
  # blend_type   : ブレンド方法
  #
  def show(name, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    @name = name
    @origin = origin
    @x = x.to_f
    @y = y.to_f
    @zoom_x = zoom_x.to_f
    @zoom_y = zoom_y.to_f
    @opacity = opacity.to_f
    @blend_type = blend_type
    @duration = 0
    @target_x = @x
    @target_y = @y
    @target_zoom_x = @zoom_x
    @target_zoom_y = @zoom_y
    @target_opacity = @opacity
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @angle = 0
    @rotate_speed = 0
  end
  #
  # ピクチャの移動
  #
  # origin       : 原点
  # x            : X 座標
  # y            : Y 座標
  # zoom_x       : X 方向拡大率
  # zoom_y       : Y 方向拡大率
  # opacity      : 不透明度
  # blend_type   : ブレンド方法
  # duration     : 時間
  #
  def move(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)
    @origin = origin
    @target_x = x.to_f
    @target_y = y.to_f
    @target_zoom_x = zoom_x.to_f
    @target_zoom_y = zoom_y.to_f
    @target_opacity = opacity.to_f
    @blend_type = blend_type
    @duration = duration
  end
  #
  # 回転速度の変更
  #
  # speed : 回転速度
  #
  def rotate(speed)
    @rotate_speed = speed
  end
  #
  # 色調変更の開始
  #
  # tone     : 色調
  # duration : 時間
  #
  def start_tone_change(tone, duration)
    @tone_target = tone.clone
    @tone_duration = duration
    if @tone_duration == 0
      @tone = @tone_target.clone
    end
  end
  #
  # ピクチャの消去
  #
  #
  def erase
    @name = ""
  end
  #
  # フレーム更新
  #
  #
  def update
    if @duration >= 1
      d = @duration
      @x = (@x * (d - 1) + @target_x) / d
      @y = (@y * (d - 1) + @target_y) / d
      @zoom_x = (@zoom_x * (d - 1) + @target_zoom_x) / d
      @zoom_y = (@zoom_y * (d - 1) + @target_zoom_y) / d
      @opacity = (@opacity * (d - 1) + @target_opacity) / d
      @duration -= 1
    end
    if @tone_duration >= 1
      d = @tone_duration
      @tone.red = (@tone.red * (d - 1) + @tone_target.red) / d
      @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
      @tone.blue = (@tone.blue * (d - 1) + @tone_target.blue) / d
      @tone.gray = (@tone.gray * (d - 1) + @tone_target.gray) / d
      @tone_duration -= 1
    end
    if @rotate_speed != 0
      @angle += @rotate_speed / 2.0
      while @angle < 0
        @angle += 360
      end
      @angle %= 360
    end
  end
end
