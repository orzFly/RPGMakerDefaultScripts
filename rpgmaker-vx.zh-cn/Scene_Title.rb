#
# 处理标题画面的类。
#

class Scene_Title < Scene_Base
  #
  # 主处理
  #
  #
  def main
    if $BTEST                         # 战斗测试的情况
      battle_test                     # 开始处理战斗测试
    else                              # 一般处理
      super                           # 返回原来的主处理
    end
  end
  #
  # 开始处理
  #
  #
  def start
    super
    load_database                     # 读取数据库
    create_game_objects               # 生成游戏对象
    check_continue                    # 继续游戏的有效判定
    create_title_graphic              # 生成标题图像
    create_command_window             # 生成指令窗口
    play_title_music                  # 演奏标题音乐
  end
  #
  # 执行过渡
  #
  #
  def perform_transition
    Graphics.transition(20)
  end
  #
  # 开始后处理
  #
  #
  def post_start
    super
    open_command_window
  end
  #
  # 结束前处理
  #
  #
  def pre_terminate
    super
    close_command_window
  end
  #
  # 结束处理
  #
  #
  def terminate
    super
    dispose_command_window
    snapshot_for_background
    dispose_title_graphic
  end
  #
  # 刷新画面
  #
  #
  def update
    super
    @command_window.update
    if Input.trigger?(Input::C)
      case @command_window.index
      when 0    # 新的游戏
        command_new_game
      when 1    # 继续游戏
        command_continue
      when 2    # 离开游戏
        command_shutdown
      end
    end
  end
  #
  # 读取数据库
  #
  #
  def load_database
    $data_actors        = load_data("Data/Actors.rvdata")
    $data_classes       = load_data("Data/Classes.rvdata")
    $data_skills        = load_data("Data/Skills.rvdata")
    $data_items         = load_data("Data/Items.rvdata")
    $data_weapons       = load_data("Data/Weapons.rvdata")
    $data_armors        = load_data("Data/Armors.rvdata")
    $data_enemies       = load_data("Data/Enemies.rvdata")
    $data_troops        = load_data("Data/Troops.rvdata")
    $data_states        = load_data("Data/States.rvdata")
    $data_animations    = load_data("Data/Animations.rvdata")
    $data_common_events = load_data("Data/CommonEvents.rvdata")
    $data_system        = load_data("Data/System.rvdata")
    $data_areas         = load_data("Data/Areas.rvdata")
  end
  #
  # 战斗测试用的读取数据库
  #
  #
  def load_bt_database
    $data_actors        = load_data("Data/BT_Actors.rvdata")
    $data_classes       = load_data("Data/BT_Classes.rvdata")
    $data_skills        = load_data("Data/BT_Skills.rvdata")
    $data_items         = load_data("Data/BT_Items.rvdata")
    $data_weapons       = load_data("Data/BT_Weapons.rvdata")
    $data_armors        = load_data("Data/BT_Armors.rvdata")
    $data_enemies       = load_data("Data/BT_Enemies.rvdata")
    $data_troops        = load_data("Data/BT_Troops.rvdata")
    $data_states        = load_data("Data/BT_States.rvdata")
    $data_animations    = load_data("Data/BT_Animations.rvdata")
    $data_common_events = load_data("Data/BT_CommonEvents.rvdata")
    $data_system        = load_data("Data/BT_System.rvdata")
  end
  #
  # 做成各种游戏对象
  #
  #
  def create_game_objects
    $game_temp          = Game_Temp.new
    $game_message       = Game_Message.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
  end
  #
  # 继续游戏的有效判定
  #
  #
  def check_continue
    @continue_enabled = (Dir.glob('Save*.rvdata').size > 0)
  end
  #
  # 生成标题图像
  #
  #
  def create_title_graphic
    @sprite = Sprite.new
    @sprite.bitmap = Cache.system("Title")
  end
  #
  # 释放标题图像
  #
  #
  def dispose_title_graphic
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  #
  # 生成继续游戏窗口
  #
  #
  def create_command_window
    s1 = Vocab::new_game
    s2 = Vocab::continue
    s3 = Vocab::shutdown
    @command_window = Window_Command.new(172, [s1, s2, s3])
    @command_window.x = (544 - @command_window.width) / 2
    @command_window.y = 288
    if @continue_enabled                    # 继续游戏有效的场合
      @command_window.index = 1             # 继续为有效的情况下、光标停止在继续上
    else                                    # 无效的场合
      @command_window.draw_item(1, false)   # 指令半透明化
    end
    @command_window.openness = 0
    @command_window.open
  end
  #
  # 释放指令窗口
  #
  #
  def dispose_command_window
    @command_window.dispose
  end
  #
  # 打开指令窗口
  #
  #
  def open_command_window
    @command_window.open
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 255
  end
  #
  # 关闭指令窗口
  #
  #
  def close_command_window
    @command_window.close
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 0
  end
  #
  # 演奏标题画面
  #
  #
  def play_title_music
    $data_system.title_bgm.play
    RPG::BGS.stop
    RPG::ME.stop
  end
  #
  # 检查玩家的初期位置
  #
  #
  def confirm_player_location
    if $data_system.start_map_id == 0
      print "还没设置玩家的初期位置。"
      exit
    end
  end
  #
  # 指令 : 新的游戏
  #
  #
  def command_new_game
    confirm_player_location
    Sound.play_decision
    $game_party.setup_starting_members            # 初期队伍
    $game_map.setup($data_system.start_map_id)    # 初期位置的地图
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $scene = Scene_Map.new
    RPG::BGM.fade(1500)
    close_command_window
    Graphics.fadeout(60)
    Graphics.wait(40)
    Graphics.frame_count = 0
    RPG::BGM.stop
    $game_map.autoplay
  end
  #
  # 指令 : 继续游戏
  #
  #
  def command_continue
    if @continue_enabled
      Sound.play_decision
      $scene = Scene_File.new(false, true, false)
    else
      Sound.play_buzzer
    end
  end
  #
  # 指令 : 离开游戏
  #
  #
  def command_shutdown
    Sound.play_decision
    RPG::BGM.fade(800)
    RPG::BGS.fade(800)
    RPG::ME.fade(800)
    $scene = nil
  end
  #
  # 战斗测试
  #
  #
  def battle_test
    load_bt_database                  # 战斗测试用数据库读取
    create_game_objects               # 作成游戏对象
    Graphics.frame_count = 0          # 初期化游戏时间
    $game_party.setup_battle_test_members
    $game_troop.setup($data_system.test_troop_id)
    $game_troop.can_escape = true
    $game_system.battle_bgm.play
    snapshot_for_background
    $scene = Scene_Battle.new
  end
end
