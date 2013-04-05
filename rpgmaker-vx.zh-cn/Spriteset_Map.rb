#
# 处理地图画面活动块和元件的类。本类在
# Scene_Map 类的内部使用。
#

class Spriteset_Map
  #
  # 初始化对像
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
  # 生成视口
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
  # 生成地图元件
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
  # 生成远景
  #
  #
  def create_parallax
    @parallax = Plane.new(@viewport1)
    @parallax.z = -100
  end
  #
  # 生成角色活动块
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
  # 生成飞行船影子活动块
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
  # 生成天气
  #
  #
  def create_weather
    @weather = Spriteset_Weather.new(@viewport2)
  end
  #
  # 生成图片活动块
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
  # 生成计时器活动块
  #
  #
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewport2)
  end
  #
  # 释放
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
  # 地图元件释放
  #
  #
  def dispose_tilemap
    @tilemap.dispose
  end
  #
  # 远景释放
  #
  #
  def dispose_parallax
    @parallax.dispose
  end
  #
  # 角色活动块释放
  #
  #
  def dispose_characters
    for sprite in @character_sprites
      sprite.dispose
    end
  end
  #
  # 飞行船影子活动块释放
  #
  #
  def dispose_shadow
    @shadow_sprite.dispose
  end
  #
  # 天气释放
  #
  #
  def dispose_weather
    @weather.dispose
  end
  #
  # 图片活动块释放
  #
  #
  def dispose_pictures
    for sprite in @picture_sprites
      sprite.dispose
    end
  end
  #
  # 计时器活动块释放
  #
  #
  def dispose_timer
    @timer_sprite.dispose
  end
  #
  # 视口释放
  #
  #
  def dispose_viewports
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  #
  # 刷新画面
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
  # 刷新地图元件
  #
  #
  def update_tilemap
    @tilemap.ox = $game_map.display_x / 8
    @tilemap.oy = $game_map.display_y / 8
    @tilemap.update
  end
  #
  # 刷新远景
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
  # 刷新角色活动块
  #
  #
  def update_characters
    for sprite in @character_sprites
      sprite.update
    end
  end
  #
  # 刷新飞行船影子活动块
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
  # 刷新天气
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
  # 刷新图片活动块
  #
  #
  def update_pictures
    for sprite in @picture_sprites
      sprite.update
    end
  end
  #
  # 刷新计时器活动块
  #
  #
  def update_timer
    @timer_sprite.update
  end
  #
  # 刷新视口
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
