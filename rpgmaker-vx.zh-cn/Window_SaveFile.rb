#
# 显示存档以及读档画面、保存文件的窗口。
#

class Window_SaveFile < Window_Base
  #
  # 定义实例变量
  #
  #
  attr_reader   :filename                 # 文件名
  attr_reader   :file_exist               # 文件存在标志
  attr_reader   :time_stamp               # 时间标记
  attr_reader   :selected                 # 选择状态
  #
  # 初始化对像
  #
  # file_index : 存档文件的索引 (0～3)
  # filename   : 文件名
  #
  def initialize(file_index, filename)
    super(0, 56 + file_index % 4 * 90, 544, 90)
    @file_index = file_index
    @filename = filename
    load_gamedata
    refresh
    @selected = false
  end
  #
  # 部分游戏数据。
  #
  # 开关和变量默认未使用 (地图名表示等扩张时使用) 。
  #
  def load_gamedata
    @time_stamp = Time.at(0)
    @file_exist = FileTest.exist?(@filename)
    if @file_exist
      file = File.open(@filename, "r")
      @time_stamp = file.mtime
      begin
        @characters     = Marshal.load(file)
        @frame_count    = Marshal.load(file)
        @last_bgm       = Marshal.load(file)
        @last_bgs       = Marshal.load(file)
        @game_system    = Marshal.load(file)
        @game_message   = Marshal.load(file)
        @game_switches  = Marshal.load(file)
        @game_variables = Marshal.load(file)
        @total_sec = @frame_count / Graphics.frame_rate
      rescue
        @file_exist = false
      ensure
        file.close
      end
    end
  end
  #
  # 刷新
  #
  #
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    name = Vocab::File + " #{@file_index + 1}"
    self.contents.draw_text(4, 0, 200, WLH, name)
    @name_width = contents.text_size(name).width
    if @file_exist
      draw_party_characters(152, 58)
      draw_playtime(0, 34, contents.width - 4, 2)
    end
  end
  #
  # 队伍角色的描画
  #
  # x : 描画目标 X 坐标
  # y : 描画目标 Y 坐标
  #
  def draw_party_characters(x, y)
    for i in 0...@characters.size
      name = @characters[i][0]
      index = @characters[i][1]
      draw_character(name, index, x + i * 48, y)
    end
  end
  #
  # 游戏时间的描画
  #
  # x : 描画目标 X 坐标
  # y : 描画目标 Y 坐标
  # width : 宽
  # align : 对齐方式
  #
  def draw_playtime(x, y, width, align)
    hour = @total_sec / 60 / 60
    min = @total_sec / 60 % 60
    sec = @total_sec % 60
    time_string = sprintf("%02d:%02d:%02d", hour, min, sec)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, width, WLH, time_string, 2)
  end
  #
  # 选择状态的设置
  #
  # selected : 新的选择状态 (true=选择 false=非选择)
  #
  def selected=(selected)
    @selected = selected
    update_cursor
  end
  #
  # 刷新光标
  #
  #
  def update_cursor
    if @selected
      self.cursor_rect.set(0, 0, @name_width + 8, WLH)
    else
      self.cursor_rect.empty
    end
  end
end
