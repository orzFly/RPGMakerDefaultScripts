#
# 处理战斗画面的活动块的类。本类在 Scene_Battle 类
# 的内部使用。
#

class Spriteset_Battle
  #
  # 初始化对像
  #
  #
  def initialize
    create_viewports
    create_battleback
    create_battlefloor
    create_enemies
    create_actors
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
  # 生成战斗背景位图
  #
  #
  def create_battleback
    source = $game_temp.background_bitmap
    bitmap = Bitmap.new(640, 480)
    bitmap.stretch_blt(bitmap.rect, source, source.rect)
    bitmap.radial_blur(90, 12)
    @battleback_sprite = Sprite.new(@viewport1)
    @battleback_sprite.bitmap = bitmap
    @battleback_sprite.ox = 320
    @battleback_sprite.oy = 240
    @battleback_sprite.x = 272
    @battleback_sprite.y = 176
    @battleback_sprite.wave_amp = 8
    @battleback_sprite.wave_length = 240
    @battleback_sprite.wave_speed = 120
  end
  #
  # 生成战斗场所活动块
  #
  #
  def create_battlefloor
    @battlefloor_sprite = Sprite.new(@viewport1)
    @battlefloor_sprite.bitmap = Cache.system("BattleFloor")
    @battlefloor_sprite.x = 0
    @battlefloor_sprite.y = 192
    @battlefloor_sprite.z = 1
    @battlefloor_sprite.opacity = 128
  end
  #
  # 生成敌人活动块
  #
  #
  def create_enemies
    @enemy_sprites = []
    for enemy in $game_troop.members.reverse
      @enemy_sprites.push(Sprite_Battler.new(@viewport1, enemy))
    end
  end
  #
  # 生成角色活动块
  #
  # 默认不显示角色图形，不过，为了方便、己方生成与敌人同样的精灵。
  #
  def create_actors
    @actor_sprites = []
    @actor_sprites.push(Sprite_Battler.new(@viewport1))
    @actor_sprites.push(Sprite_Battler.new(@viewport1))
    @actor_sprites.push(Sprite_Battler.new(@viewport1))
    @actor_sprites.push(Sprite_Battler.new(@viewport1))
  end
  #
  # 生成图片活动块
  #
  #
  def create_pictures
    @picture_sprites = []
    for i in 1..20
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_troop.screen.pictures[i]))
    end
  end
  # #
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
    dispose_battleback_bitmap
    dispose_battleback
    dispose_battlefloor
    dispose_enemies
    dispose_actors
    dispose_pictures
    dispose_timer
    dispose_viewports
  end
  #
  # 战斗背景位图释放
  #
  #
  def dispose_battleback_bitmap
    @battleback_sprite.bitmap.dispose
  end
  #
  # 战斗背景活动块释放
  #
  #
  def dispose_battleback
    @battleback_sprite.dispose
  end
  #
  # 战斗场所活动块释放
  #
  #
  def dispose_battlefloor
    @battlefloor_sprite.dispose
  end
  #
  # 敌人活动块释放
  #
  #
  def dispose_enemies
    for sprite in @enemy_sprites
      sprite.dispose
    end
  end
  #
  # 角色活动块释放
  #
  #
  def dispose_actors
    for sprite in @actor_sprites
      sprite.dispose
    end
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
    update_battleback
    update_battlefloor
    update_enemies
    update_actors
    update_pictures
    update_timer
    update_viewports
  end
  #
  # 刷新战斗背景活动块
  #
  #
  def update_battleback
    @battleback_sprite.update
  end
  #
  # 刷新战斗场所活动块
  #
  #
  def update_battlefloor
    @battlefloor_sprite.update
  end
  #
  # 刷新敌人活动块
  #
  #
  def update_enemies
    for sprite in @enemy_sprites
      sprite.update
    end
  end
  #
  # 刷新角色活动块
  #
  #
  def update_actors
    @actor_sprites[0].battler = $game_party.members[0]
    @actor_sprites[1].battler = $game_party.members[1]
    @actor_sprites[2].battler = $game_party.members[2]
    @actor_sprites[3].battler = $game_party.members[3]
    for sprite in @actor_sprites
      sprite.update
    end
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
    @viewport1.tone = $game_troop.screen.tone
    @viewport1.ox = $game_troop.screen.shake
    @viewport2.color = $game_troop.screen.flash_color
    @viewport3.color.set(0, 0, 0, 255 - $game_troop.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
  #
  # 动画显示中判定
  #
  #
  def animation?
    for sprite in @enemy_sprites + @actor_sprites
      return true if sprite.animation?
    end
    return false
  end
end
