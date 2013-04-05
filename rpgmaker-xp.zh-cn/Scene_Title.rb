#
# 处理标题画面的类。
#

class Scene_Title
  #
  # 住处理
  #
  #
  def main
    # 战斗测试的情况下
    if $BTEST
      battle_test
      return
    end
    # 载入数据库
    $data_actors        = load_data("Data/Actors.rxdata")
    $data_classes       = load_data("Data/Classes.rxdata")
    $data_skills        = load_data("Data/Skills.rxdata")
    $data_items         = load_data("Data/Items.rxdata")
    $data_weapons       = load_data("Data/Weapons.rxdata")
    $data_armors        = load_data("Data/Armors.rxdata")
    $data_enemies       = load_data("Data/Enemies.rxdata")
    $data_troops        = load_data("Data/Troops.rxdata")
    $data_states        = load_data("Data/States.rxdata")
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
    # 生成系统对像
    $game_system = Game_System.new
    # 生成标题图形
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.title($data_system.title_name)
    # 生成命令窗口
    s1 = "新游戏"
    s2 = "继续"
    s3 = "退出"
    @command_window = Window_Command.new(192, [s1, s2, s3])
    @command_window.back_opacity = 160
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 288
    # 判定继续的有效性
    # 存档文件一个也不存在的时候也调查
    # 有効为 `@continue_enabled` 为 true、無効为 false
    @continue_enabled = false
    for i in 0..3
      if FileTest.exist?("Save#{i+1}.rxdata")
        @continue_enabled = true
      end
    end
    # 继续为有效的情况下、光标停止在继续上
    # 无效的情况下、继续的文字显示为灰色
    if @continue_enabled
      @command_window.index = 1
    else
      @command_window.disable_item(1)
    end
    # 演奏标题 BGM
    $game_system.bgm_play($data_system.title_bgm)
    # 停止演奏 ME、BGS
    Audio.me_stop
    Audio.bgs_stop
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面被切换就中断循环
      if $scene != self
        break
      end
    end
    # 装备过渡
    Graphics.freeze
    # 释放命令窗口
    @command_window.dispose
    # 释放标题图形
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  #
  # 刷新画面
  #
  #
  def update
    # 刷新命令窗口
    @command_window.update
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 命令窗口的光标位置的分支
      case @command_window.index
      when 0  # 新游戏
        command_new_game
      when 1  # 继续
        command_continue
      when 2  # 退出
        command_shutdown
      end
    end
  end
  #
  # 命令 : 新游戏
  #
  #
  def command_new_game
    # 演奏确定 SE
    $game_system.se_play($data_system.decision_se)
    # 停止 BGM
    Audio.bgm_stop
    # 重置测量游戏时间用的画面计数器
    Graphics.frame_count = 0
    # 生成各种游戏对像
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # 设置初期同伴位置
    $game_party.setup_starting_members
    # 设置初期位置的地图
    $game_map.setup($data_system.start_map_id)
    # 主角向初期位置移动
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    # 刷新主角
    $game_player.refresh
    # 执行地图设置的 BGM 与 BGS 的自动切换
    $game_map.autoplay
    # 刷新地图 (执行并行事件)
    $game_map.update
    # 切换地图画面
    $scene = Scene_Map.new
  end
  #
  # 命令 : 继续
  #
  #
  def command_continue
    # 继续无效的情况下
    unless @continue_enabled
      # 演奏无效 SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # 演奏确定 SE
    $game_system.se_play($data_system.decision_se)
    # 切换到读档画面
    $scene = Scene_Load.new
  end
  #
  # 命令 : 退出
  #
  #
  def command_shutdown
    # 演奏确定 SE
    $game_system.se_play($data_system.decision_se)
    # BGM、BGS、ME 的淡入淡出
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # 退出
    $scene = nil
  end
  #
  # 战斗测试
  #
  #
  def battle_test
    # 载入数据库 (战斗测试用)
    $data_actors        = load_data("Data/BT_Actors.rxdata")
    $data_classes       = load_data("Data/BT_Classes.rxdata")
    $data_skills        = load_data("Data/BT_Skills.rxdata")
    $data_items         = load_data("Data/BT_Items.rxdata")
    $data_weapons       = load_data("Data/BT_Weapons.rxdata")
    $data_armors        = load_data("Data/BT_Armors.rxdata")
    $data_enemies       = load_data("Data/BT_Enemies.rxdata")
    $data_troops        = load_data("Data/BT_Troops.rxdata")
    $data_states        = load_data("Data/BT_States.rxdata")
    $data_animations    = load_data("Data/BT_Animations.rxdata")
    $data_tilesets      = load_data("Data/BT_Tilesets.rxdata")
    $data_common_events = load_data("Data/BT_CommonEvents.rxdata")
    $data_system        = load_data("Data/BT_System.rxdata")
    # 重置测量游戏时间用的画面计数器
    Graphics.frame_count = 0
    # 生成各种游戏对像
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # 设置战斗测试用同伴
    $game_party.setup_battle_test_members
    # 设置队伍 ID、可以逃走标志、战斗背景
    $game_temp.battle_troop_id = $data_system.test_troop_id
    $game_temp.battle_can_escape = true
    $game_map.battleback_name = $data_system.battleback_name
    # 演奏战斗开始 BGM
    $game_system.se_play($data_system.battle_start_se)
    # 演奏战斗 BGM
    $game_system.bgm_play($game_system.battle_bgm)
    # 切换到战斗画面
    $scene = Scene_Battle.new
  end
end
