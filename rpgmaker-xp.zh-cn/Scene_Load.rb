#
# 处理读档画面的类。
#

class Scene_Load < Scene_File
  #
  # 初始化对像
  #
  #
  def initialize
    # 再生成临时对像
    $game_temp = Game_Temp.new
    # 选择存档时间最新的文件
    $game_temp.last_file_index = 0
    latest_time = Time.at(0)
    for i in 0..3
      filename = make_filename(i)
      if FileTest.exist?(filename)
        file = File.open(filename, "r")
        if file.mtime > latest_time
          latest_time = file.mtime
          $game_temp.last_file_index = i
        end
        file.close
      end
    end
    super("要载入哪个文件？")
  end
  #
  # 确定时的处理
  #
  #
  def on_decision(filename)
    # 文件不存在的情况下
    unless FileTest.exist?(filename)
      # 演奏冻结 SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # 演奏读档 SE
    $game_system.se_play($data_system.load_se)
    # 写入存档数据
    file = File.open(filename, "rb")
    read_save_data(file)
    file.close
    # 还原 BGM、BGS
    $game_system.bgm_play($game_system.playing_bgm)
    $game_system.bgs_play($game_system.playing_bgs)
    # 刷新地图 (执行并行事件)
    $game_map.update
    # 切换到地图画面
    $scene = Scene_Map.new
  end
  #
  # 取消时的处理
  #
  #
  def on_cancel
    # 演奏取消 SE
    $game_system.se_play($data_system.cancel_se)
    # 切换到标题画面
    $scene = Scene_Title.new
  end
  #
  # 读取存档数据
  #
  # file : 读取用文件对像 (已经打开)
  #
  def read_save_data(file)
    # 读取描绘存档文件用的角色数据
    characters = Marshal.load(file)
    # 读取测量游戏时间用画面计数
    Graphics.frame_count = Marshal.load(file)
    # 读取各种游戏对像
    $game_system        = Marshal.load(file)
    $game_switches      = Marshal.load(file)
    $game_variables     = Marshal.load(file)
    $game_self_switches = Marshal.load(file)
    $game_screen        = Marshal.load(file)
    $game_actors        = Marshal.load(file)
    $game_party         = Marshal.load(file)
    $game_troop         = Marshal.load(file)
    $game_map           = Marshal.load(file)
    $game_player        = Marshal.load(file)
    # 魔法编号与保存时有差异的情况下
    # (加入编辑器的编辑过的数据)
    if $game_system.magic_number != $data_system.magic_number
      # 重新装载地图
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
    end
    # 刷新同伴成员
    $game_party.refresh
  end
end
