#
# ピクチャ表示用のスプライトです。Game_Picture クラスのインスタンスを監視し、
# スプライトの状態を自動的に変化させます。
#

class Sprite_Picture < Sprite
  #
  # オブジェクト初期化
  #
  # viewport : ビューポート
  # picture  : ピクチャ (Game_Picture)
  #
  def initialize(viewport, picture)
    super(viewport)
    @picture = picture
    update
  end
  #
  # 解放
  #
  #
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
    end
    super
  end
  #
  # フレーム更新
  #
  #
  def update
    super
    if @picture_name != @picture.name
      @picture_name = @picture.name
      if @picture_name != ""
        self.bitmap = Cache.picture(@picture_name)
      end
    end
    if @picture_name == ""
      self.visible = false
    else
      self.visible = true
      if @picture.origin == 0
        self.ox = 0
        self.oy = 0
      else
        self.ox = self.bitmap.width / 2
        self.oy = self.bitmap.height / 2
      end
      self.x = @picture.x
      self.y = @picture.y
      self.z = 100 + @picture.number
      self.zoom_x = @picture.zoom_x / 100.0
      self.zoom_y = @picture.zoom_y / 100.0
      self.opacity = @picture.opacity
      self.blend_type = @picture.blend_type
      self.angle = @picture.angle
      self.tone = @picture.tone
    end
  end
end
