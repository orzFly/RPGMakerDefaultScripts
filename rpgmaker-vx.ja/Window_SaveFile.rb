#
# セーブ画面およびロード画面で表示する、セーブファイルのウィンドウです。
#

class Window_SaveFile < Window_Base
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :filename                 # ファイル名
  attr_reader   :file_exist               # ファイル存在フラグ
  attr_reader   :time_stamp               # タイムスタンプ
  attr_reader   :selected                 # 選択状態
  #
  # オブジェクト初期化
  #
  # file_index : セーブファイルのインデックス (0～3)
  # filename   : ファイル名
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
  # ゲームデータの一部をロード
  #
  # スイッチや変数はデフォルトでは未使用 (地名表示などの拡張用) 。
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
  # リフレッシュ
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
  # パーティキャラの描画
  #
  # x : 描画先 X 座標
  # y : 描画先 Y 座標
  #
  def draw_party_characters(x, y)
    for i in 0...@characters.size
      name = @characters[i][0]
      index = @characters[i][1]
      draw_character(name, index, x + i * 48, y)
    end
  end
  #
  # プレイ時間の描画
  #
  # x     : 描画先 X 座標
  # y     : 描画先 Y 座標
  # width : 幅
  # align : 配置
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
  # 選択状態の設定
  #
  # selected : 新しい選択状態 (true=選択 false=非選択)
  #
  def selected=(selected)
    @selected = selected
    update_cursor
  end
  #
  # カーソルの更新
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
