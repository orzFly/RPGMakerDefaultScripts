#
# マップ画面のスプライトやタイルマップなどをまとめたクラスです。このクラスは
# Scene_Map クラスの内部で使用されます。
#

class Spriteset_Map
  #
  # オブジェクト初期化
  #
  #
  def initialize
    create_viewports
    create_tilemap
    create_parallax
    create_characters
    create_shadow
    create_weather
    create_pictures
    create_timer
    update
  end
  #
  # ビューポートの作成
  #
  #
  def create_viewports
    @viewport1 = Viewport.new(0, 0, 544, 416)
    @viewport2 = Viewport.new(0, 0, 544, 416)
    @viewport3 = Viewport.new(0, 0, 544, 416)
    @viewport2.z = 50
    @viewport3.z = 100
  end
  #
  # タイルマップの作成
  #
  #
  def create_tilemap
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.bitmaps[0] = Cache.system("TileA1")
    @tilemap.bitmaps[1] = Cache.system("TileA2")
    @tilemap.bitmaps[2] = Cache.system("TileA3")
    @tilemap.bitmaps[3] = Cache.system("TileA4")
    @tilemap.bitmaps[4] = Cache.system("TileA5")
    @tilemap.bitmaps[5] = Cache.system("TileB")
    @tilemap.bitmaps[6] = Cache.system("TileC")
    @tilemap.bitmaps[7] = Cache.system("TileD")
    @tilemap.bitmaps[8] = Cache.system("TileE")
    @tilemap.map_data = $game_map.data
    @tilemap.passages = $game_map.passages
  end
  #
  # 遠景の作成
  #
  #
  def create_parallax
    @parallax = Plane.new(@viewport1)
    @parallax.z = -100
  end
  #
  # キャラクタースプライトの作成
  #
  #
  def create_characters
    @character_sprites = []
    for i in $game_map.events.keys.sort
      sprite = Sprite_Character.new(@viewport1, $game_map.events[i])
      @character_sprites.push(sprite)
    end
    for vehicle in $game_map.vehicles
      sprite = Sprite_Character.new(@viewport1, vehicle)
      @character_sprites.push(sprite)
    end
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
  end
  #
  # 飛行船の影スプライトの作成
  #
  #
  def create_shadow
    @shadow_sprite = Sprite.new(@viewport1)
    @shadow_sprite.bitmap = Cache.system("Shadow")
    @shadow_sprite.ox = @shadow_sprite.bitmap.width / 2
    @shadow_sprite.oy = @shadow_sprite.bitmap.height
    @shadow_sprite.z = 180
  end
  #
  # 天候の作成
  #
  #
  def create_weather
    @weather = Spriteset_Weather.new(@viewport2)
  end
  #
  # ピクチャスプライトの作成
  #
  #
  def create_pictures
    @picture_sprites = []
    for i in 1..20
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_map.screen.pictures[i]))
    end
  end
  #
  # タイマースプライトの作成
  #
  #
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewport2)
  end
  #
  # 解放
  #
  #
  def dispose
    dispose_tilemap
    dispose_parallax
    dispose_characters
    dispose_shadow
    dispose_weather
    dispose_pictures
    dispose_timer
    dispose_viewports
  end
  #
  # タイルマップの解放
  #
  #
  def dispose_tilemap
    @tilemap.dispose
  end
  #
  # 遠景の解放
  #
  #
  def dispose_parallax
    @parallax.dispose
  end
  #
  # キャラクタースプライトの解放
  #
  #
  def dispose_characters
    for sprite in @character_sprites
      sprite.dispose
    end
  end
  #
  # 飛行船の影スプライトの解放
  #
  #
  def dispose_shadow
    @shadow_sprite.dispose
  end
  #
  # 天候の解放
  #
  #
  def dispose_weather
    @weather.dispose
  end
  #
  # ピクチャスプライトの解放
  #
  #
  def dispose_pictures
    for sprite in @picture_sprites
      sprite.dispose
    end
  end
  #
  # タイマースプライトの解放
  #
  #
  def dispose_timer
    @timer_sprite.dispose
  end
  #
  # ビューポートの解放
  #
  #
  def dispose_viewports
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  #
  # フレーム更新
  #
  #
  def update
    update_tilemap
    update_parallax
    update_characters
    update_shadow
    update_weather
    update_pictures
    update_timer
    update_viewports
  end
  #
  # タイルマップの更新
  #
  #
  def update_tilemap
    @tilemap.ox = $game_map.display_x / 8
    @tilemap.oy = $game_map.display_y / 8
    @tilemap.update
  end
  #
  # 遠景の更新
  #
  #
  def update_parallax
    if @parallax_name != $game_map.parallax_name
      @parallax_name = $game_map.parallax_name
      if @parallax.bitmap != nil
        @parallax.bitmap.dispose
        @parallax.bitmap = nil
      end
      if @parallax_name != ""
        @parallax.bitmap = Cache.parallax(@parallax_name)
      end
      Graphics.frame_reset
    end
    @parallax.ox = $game_map.calc_parallax_x(@parallax.bitmap)
    @parallax.oy = $game_map.calc_parallax_y(@parallax.bitmap)
  end
  #
  # キャラクタースプライトの更新
  #
  #
  def update_characters
    for sprite in @character_sprites
      sprite.update
    end
  end
  #
  # 飛行船の影スプライトの更新
  #
  #
  def update_shadow
    airship = $game_map.airship
    @shadow_sprite.x = airship.screen_x
    @shadow_sprite.y = airship.screen_y + airship.altitude
    @shadow_sprite.opacity = airship.altitude * 8
    @shadow_sprite.update
  end
  #
  # 天候の更新
  #
  #
  def update_weather
    @weather.type = $game_map.screen.weather_type
    @weather.max = $game_map.screen.weather_max
    @weather.ox = $game_map.display_x / 8
    @weather.oy = $game_map.display_y / 8
    @weather.update
  end
  #
  # ピクチャスプライトの更新
  #
  #
  def update_pictures
    for sprite in @picture_sprites
      sprite.update
    end
  end
  #
  # タイマースプライトの更新
  #
  #
  def update_timer
    @timer_sprite.update
  end
  #
  # ビューポートの更新
  #
  #
  def update_viewports
    @viewport1.tone = $game_map.screen.tone
    @viewport1.ox = $game_map.screen.shake
    @viewport2.color = $game_map.screen.flash_color
    @viewport3.color.set(0, 0, 0, 255 - $game_map.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
end
