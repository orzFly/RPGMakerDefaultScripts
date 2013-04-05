#
# 处理文件的类。
#

class Scene_File < Scene_Base
  #
  # 对象初始化
  #
  # saving     : SAVE标签 (false 的话则是读取画面)
  # from_title : 从开始画面的「继续游戏」中呼叫的标签
  # from_event : 从事件的「打开存档画面」中呼叫的标签
  #
  def initialize(saving, from_title, from_event)
    @saving = saving
    @from_title = from_title
    @from_event = from_event
  end
  #
  # 开始处理
  #
  #
  def start
    super
    create_menu_background
    @help_window = Window_Help.new
    create_savefile_windows
    if @saving
      @index = $game_temp.last_file_index
      @help_window.set_text(Vocab::SaveMessage)
    else
      @index = self.latest_file_index
      @help_window.set_text(Vocab::LoadMessage)
    end
    @savefile_windows[@index].selected = true
  end
  #
  # 结束处理
  #
  #
  def terminate
    super
    dispose_menu_background
    @help_window.dispose
    dispose_item_windows
  end
  #
  # 返回前一个画面
  #
  #
  def return_scene
    if @from_title
      $scene = Scene_Title.new
    elsif @from_event
      $scene = Scene_Map.new
    else
      $scene = Scene_Menu.new(4)
    end
  end
  #
  # 刷新画面
  #
  #
  def update
    super
    update_menu_background
    @help_window.update
    update_savefile_windows
    update_savefile_selection
  end
  #
  # 生成存档文件窗口
  #
  #
  def create_savefile_windows
    @savefile_windows = []
    for i in 0..3
      @savefile_windows.push(Window_SaveFile.new(i, make_filename(i)))
    end
    @item_max = 4
  end
  #
  # 释放存档文件窗口
  #
  #
  def dispose_item_windows
    for window in @savefile_windows
      window.dispose
    end
  end
  #
  # 刷新存档文件窗口
  #
  #
  def update_savefile_windows
    for window in @savefile_windows
      window.update
    end
  end
  #
  # 刷新存档文件选项
  #
  #
  def update_savefile_selection
    if Input.trigger?(Input::C)
      determine_savefile
    elsif Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    else
      last_index = @index
      if Input.repeat?(Input::DOWN)
        cursor_down(Input.trigger?(Input::DOWN))
      end
      if Input.repeat?(Input::UP)
        cursor_up(Input.trigger?(Input::UP))
      end
      if @index != last_index
        Sound.play_cursor
        @savefile_windows[last_index].selected = false
        @savefile_windows[@index].selected = true
      end
    end
  end
  #
  # 决定存档文件
  #
  #
  def determine_savefile
    if @saving
      Sound.play_save
      do_save
    else
      if @savefile_windows[@index].file_exist
        Sound.play_load
        do_load
      else
        Sound.play_buzzer
        return
      end
    end
    $game_temp.last_file_index = @index
  end
  #
  # 光标向下移动
  #
  # wrap : 滚动移动许可
  #
  def cursor_down(wrap)
    if @index < @item_max - 1 or wrap
      @index = (@index + 1) % @item_max
    end
  end
  #
  # 光标向上移动
  #
  # wrap : 滚动移动许可
  #
  def cursor_up(wrap)
    if @index > 0 or wrap
      @index = (@index - 1 + @item_max) % @item_max
    end
  end
  #
  # 生成文件名
  #
  # file_index : 存档文件的Index (0～3)
  #
  def make_filename(file_index)
    return "Save#{file_index + 1}.rvdata"
  end
  #
  # 时间标记内最新选择的文件
  #
  #
  def latest_file_index
    index = 0
    latest_time = Time.at(0)
    for i in 0...@savefile_windows.size
      if @savefile_windows[i].time_stamp > latest_time
        latest_time = @savefile_windows[i].time_stamp
        index = i
      end
    end
    return index
  end
  #
  # 执行保存
  #
  #
  def do_save
    file = File.open(@savefile_windows[@index].filename, "wb")
    write_save_data(file)
    file.close
    return_scene
  end
  #
  # 执行读取
  #
  #
  def do_load
    file = File.open(@savefile_windows[@index].filename, "rb")
    read_save_data(file)
    file.close
    $scene = Scene_Map.new
    RPG::BGM.fade(1500)
    Graphics.fadeout(60)
    Graphics.wait(40)
    @last_bgm.play
    @last_bgs.play
  end
  #
  # 存档数据的写入
  #
  # file : 写入用文件对象 (已打开)
  #
  def write_save_data(file)
    characters = []
    for actor in $game_party.members
      characters.push([actor.character_name, actor.character_index])
    end
    $game_system.save_count += 1
    $game_system.version_id = $data_system.version_id
    @last_bgm = RPG::BGM::last
    @last_bgs = RPG::BGS::last
    Marshal.dump(characters,           file)
    Marshal.dump(Graphics.frame_count, file)
    Marshal.dump(@last_bgm,            file)
    Marshal.dump(@last_bgs,            file)
    Marshal.dump($game_system,         file)
    Marshal.dump($game_message,        file)
    Marshal.dump($game_switches,       file)
    Marshal.dump($game_variables,      file)
    Marshal.dump($game_self_switches,  file)
    Marshal.dump($game_actors,         file)
    Marshal.dump($game_party,          file)
    Marshal.dump($game_troop,          file)
    Marshal.dump($game_map,            file)
    Marshal.dump($game_player,         file)
  end
  #
  # 存档数据的读取
  #
  # file : 读取用文件对象 (已打开)
  #
  def read_save_data(file)
    characters           = Marshal.load(file)
    Graphics.frame_count = Marshal.load(file)
    @last_bgm            = Marshal.load(file)
    @last_bgs            = Marshal.load(file)
    $game_system         = Marshal.load(file)
    $game_message        = Marshal.load(file)
    $game_switches       = Marshal.load(file)
    $game_variables      = Marshal.load(file)
    $game_self_switches  = Marshal.load(file)
    $game_actors         = Marshal.load(file)
    $game_party          = Marshal.load(file)
    $game_troop          = Marshal.load(file)
    $game_map            = Marshal.load(file)
    $game_player         = Marshal.load(file)
    if $game_system.version_id != $data_system.version_id
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
    end
  end
end
