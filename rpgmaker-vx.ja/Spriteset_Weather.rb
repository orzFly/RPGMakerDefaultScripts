#
# 天候エフェクト (雨、嵐、雪) のクラスです。このクラスは Spriteset_Map クラ
# スの内部で使用されます。
#

class Spriteset_Weather
  #
  # 公開インスタンス変数
  #
  #
  attr_reader :type
  attr_reader :max
  attr_reader :ox
  attr_reader :oy
  #
  # オブジェクト初期化
  #
  #
  def initialize(viewport = nil)
    @type = 0
    @max = 0
    @ox = 0
    @oy = 0
    color1 = Color.new(255, 255, 255, 160)
    color2 = Color.new(255, 255, 255, 80)
    @rain_bitmap = Bitmap.new(7, 56)
    for i in 0..6
      @rain_bitmap.fill_rect(6-i, i*8, 1, 8, color1)
    end
    @storm_bitmap = Bitmap.new(34, 64)
    for i in 0..31
      @storm_bitmap.fill_rect(33-i, i*2, 1, 2, color2)
      @storm_bitmap.fill_rect(32-i, i*2, 1, 2, color1)
      @storm_bitmap.fill_rect(31-i, i*2, 1, 2, color2)
    end
    @snow_bitmap = Bitmap.new(6, 6)
    @snow_bitmap.fill_rect(0, 1, 6, 4, color2)
    @snow_bitmap.fill_rect(1, 0, 4, 6, color2)
    @snow_bitmap.fill_rect(1, 2, 4, 2, color1)
    @snow_bitmap.fill_rect(2, 1, 2, 4, color1)
    @sprites = []
    for i in 1..40
      sprite = Sprite.new(viewport)
      sprite.visible = false
      sprite.opacity = 0
      @sprites.push(sprite)
    end
  end
  #
  # 解放
  #
  #
  def dispose
    for sprite in @sprites
      sprite.dispose
    end
    @rain_bitmap.dispose
    @storm_bitmap.dispose
    @snow_bitmap.dispose
  end
  #
  # 天候タイプの設定
  #
  # type : 新しい天候タイプ
  #
  def type=(type)
    return if @type == type
    @type = type
    case @type
    when 1
      bitmap = @rain_bitmap
    when 2
      bitmap = @storm_bitmap
    when 3
      bitmap = @snow_bitmap
    else
      bitmap = nil
    end
    for i in 0...@sprites.size
      sprite = @sprites[i]
      sprite.visible = (i <= @max)
      sprite.bitmap = bitmap
    end
  end
  #
  # 原点 X 座標の設定
  #
  # ox : 原点 X 座標
  #
  def ox=(ox)
    return if @ox == ox;
    @ox = ox
    for sprite in @sprites
      sprite.ox = @ox
    end
  end
  #
  # 原点 Y 座標の設定
  #
  # oy : 原点 Y 座標
  #
  def oy=(oy)
    return if @oy == oy;
    @oy = oy
    for sprite in @sprites
      sprite.oy = @oy
    end
  end
  #
  # スプライト最大数の設定
  #
  # max : スプライト最大数
  #
  def max=(max)
    return if @max == max;
    @max = [[max, 0].max, 40].min
    for i in 1..40
      sprite = @sprites[i]
      sprite.visible = (i <= @max) if sprite != nil
    end
  end
  #
  # フレーム更新
  #
  #
  def update
    return if @type == 0
    for i in 1..@max
      sprite = @sprites[i]
      if sprite == nil
        break
      end
      if @type == 1
        sprite.x -= 2
        sprite.y += 16
        sprite.opacity -= 8
      end
      if @type == 2
        sprite.x -= 8
        sprite.y += 16
        sprite.opacity -= 12
      end
      if @type == 3
        sprite.x -= 2
        sprite.y += 8
        sprite.opacity -= 8
      end
      x = sprite.x - @ox
      y = sprite.y - @oy
      if sprite.opacity < 64
        sprite.x = rand(800) - 100 + @ox
        sprite.y = rand(600) - 200 + @oy
        sprite.opacity = 255
      end
    end
  end
end
