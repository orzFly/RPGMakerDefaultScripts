#
# 处理菜单画面的类。
#

class Scene_Map < Scene_Base
  #
  # 开始处理
  #
  #
  def start
    super
    $game_map.refresh
    @spriteset = Spriteset_Map.new
    @message_window = Window_Message.new
  end
  #
  # 执行过渡
  #
  #
  def perform_transition
    if Graphics.brightness == 0       # 战斗后，直接显示
      fadein(30)
    else                              # 恢复菜单
      Graphics.transition(15)
    end
  end
  #
  # 終了処理
  #
  #
  def terminate
    super
    if $scene.is_a?(Scene_Battle)     # 切换战斗画面的情况
      @spriteset.dispose_characters   # 为了生成背景遮蔽角色
    end
    snapshot_for_background
    @spriteset.dispose
    @message_window.dispose
    if $scene.is_a?(Scene_Battle)     # 切换到战斗画面的情况
      perform_battle_transition       # 执行战斗前过渡
    end
  end
  #
  # 基本更新处理
  #
  #
  def update_basic
    Graphics.update                   # 刷新游戏画面
    Input.update                      # 刷新输入信息
    $game_map.update                  # 刷新地图
    @spriteset.update                 # 刷新Spriteset
  end
  #
  # 刷新画面
  #
  #
  def update
    super
    $game_map.interpreter.update      # 刷新解释器
    $game_map.update                  # 刷新地图
    $game_player.update               # 刷新玩家
    $game_system.update               # 刷新计时器
    @spriteset.update                 # 刷新Spriteset
    @message_window.update            # 刷新文章窗口
    unless $game_message.visible      # 不是显示文章的情况
      update_transfer_player
      update_encounter
      update_call_menu
      update_call_debug
      update_scene_change
    end
  end
  #
  # 画面的淡入
  #
  # duration : 时间
  # 在地图画面中，Graphics.fadeout不适合天气效果
  # 和远景的滚动等移动画面渐现。
  #
  def fadein(duration)
    Graphics.transition(0)
    for i in 0..duration-1
      Graphics.brightness = 255 * i / duration
      update_basic
    end
    Graphics.brightness = 255
  end
  #
  # 画面的淡出
  #
  # duration : 时间
  # 与淡入相同，Graphics.fadein 不直接使用。
  #
  def fadeout(duration)
    Graphics.transition(0)
    for i in 0..duration-1
      Graphics.brightness = 255 - 255 * i / duration
      update_basic
    end
    Graphics.brightness = 0
  end
  #
  # 场所移动的处理
  #
  #
  def update_transfer_player
    return unless $game_player.transfer?
    fade = (Graphics.brightness > 0)
    fadeout(30) if fade
    @spriteset.dispose              # 释放spriteset
    $game_player.perform_transfer   # 执行场所移动
    $game_map.autoplay              # BGM 和 BGS 自动切换
    $game_map.update
    Graphics.wait(15)
    @spriteset = Spriteset_Map.new  # Spriteset再生成
    fadein(30) if fade
    Input.update
  end
  #
  # 遇敌处理
  #
  #
  def update_encounter
    return if $game_player.encounter_count > 0        # 遭遇步数未满？
    return if $game_map.interpreter.running?          # 时间执行中？
    return if $game_system.encounter_disabled         # 遇敌禁止中？
    troop_id = $game_player.make_encounter_troop_id   # 确定敌人队伍
    return if $data_troops[troop_id] == nil           # 敌人队伍无效？
    $game_troop.setup(troop_id)
    $game_troop.can_escape = true
    $game_temp.battle_proc = nil
    $game_temp.next_scene = "battle"
    preemptive_or_surprise
  end
  #
  # 先制攻击和不意打的概率判定
  #
  #
  def preemptive_or_surprise
    actors_agi = $game_party.average_agi
    enemies_agi = $game_troop.average_agi
    if actors_agi >= enemies_agi
      percent_preemptive = 5
      percent_surprise = 3
    else
      percent_preemptive = 3
      percent_surprise = 5
    end
    if rand(100) < percent_preemptive
      $game_troop.preemptive = true
    elsif rand(100) < percent_surprise
      $game_troop.surprise = true
    end
  end
  #
  # 按取消按钮的菜单呼叫判定
  #
  #
  def update_call_menu
    if Input.trigger?(Input::B)
      return if $game_map.interpreter.running?        # 事件执行中？
      return if $game_system.menu_disabled            # 菜单禁止中？
      $game_temp.menu_beep = true                     # SE 演奏标志设定
      $game_temp.next_scene = "menu"
    end
  end
  #
  # F9键的Debug窗口呼叫判定
  #
  #
  def update_call_debug
    if $TEST and Input.press?(Input::F9)    # 在测试游戏中按F9
      $game_temp.next_scene = "debug"
    end
  end
  #
  # 执行画面切换
  #
  #
  def update_scene_change
    return if $game_player.moving?    # 玩家移动中？
    case $game_temp.next_scene
    when "battle"
      call_battle
    when "shop"
      call_shop
    when "name"
      call_name
    when "menu"
      call_menu
    when "save"
      call_save
    when "debug"
      call_debug
    when "gameover"
      call_gameover
    when "title"
      call_title
    else
      $game_temp.next_scene = nil
    end
  end
  #
  # 切换战斗画面
  #
  #
  def call_battle
    @spriteset.update
    Graphics.update
    $game_player.make_encounter_count
    $game_player.straighten
    $game_temp.map_bgm = RPG::BGM.last
    $game_temp.map_bgs = RPG::BGS.last
    RPG::BGM.stop
    RPG::BGS.stop
    Sound.play_battle_start
    $game_system.battle_bgm.play
    $game_temp.next_scene = nil
    $scene = Scene_Battle.new
  end
  #
  # 切换商店画面
  #
  #
  def call_shop
    $game_temp.next_scene = nil
    $scene = Scene_Shop.new
  end
  #
  # 切换姓名输入界面
  #
  #
  def call_name
    $game_temp.next_scene = nil
    $scene = Scene_Name.new
  end
  #
  # 切换菜单画面
  #
  #
  def call_menu
    if $game_temp.menu_beep
      Sound.play_decision
      $game_temp.menu_beep = false
    end
    $game_temp.next_scene = nil
    $scene = Scene_Menu.new
  end
  #
  # 切换保存画面
  #
  #
  def call_save
    $game_temp.next_scene = nil
    $scene = Scene_File.new(true, false, true)
  end
  #
  # 切换Debug界面
  #
  #
  def call_debug
    Sound.play_decision
    $game_temp.next_scene = nil
    $scene = Scene_Debug.new
  end
  #
  # 切换游戏结束画面
  #
  #
  def call_gameover
    $game_temp.next_scene = nil
    $scene = Scene_Gameover.new
  end
  #
  # 切换标题画面
  #
  #
  def call_title
    $game_temp.next_scene = nil
    $scene = Scene_Title.new
    fadeout(60)
  end
  #
  # 执行战斗前过渡
  #
  #
  def perform_battle_transition
    Graphics.transition(80, "Graphics/System/BattleStart", 80)
    Graphics.freeze
  end
end
