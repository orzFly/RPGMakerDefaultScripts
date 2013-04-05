#
# マップを扱うクラスです。スクロールや通行可能判定などの機能を持っています。
# このクラスのインスタンスは $game_map で参照されます。
#

class Game_Map
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :screen                   # マップ画面の状態
  attr_reader   :interpreter              # マップイベント用インタプリタ
  attr_reader   :display_x                # 表示 X 座標 * 256
  attr_reader   :display_y                # 表示 Y 座標 * 256
  attr_reader   :parallax_name            # 遠景 ファイル名
  attr_reader   :passages                 # 通行 テーブル
  attr_reader   :events                   # イベント
  attr_reader   :vehicles                 # 乗り物
  attr_accessor :need_refresh             # リフレッシュ要求フラグ
  #
  # オブジェクト初期化
  #
  #
  def initialize
    @screen = Game_Screen.new
    @interpreter = Game_Interpreter.new(0, true)
    @map_id = 0
    @display_x = 0
    @display_y = 0
    create_vehicles
  end
  #
  # セットアップ
  #
  # map_id : マップ ID
  #
  def setup(map_id)
    @map_id = map_id
    @map = load_data(sprintf("Data/Map%03d.rvdata", @map_id))
    @display_x = 0
    @display_y = 0
    @passages = $data_system.passages
    referesh_vehicles
    setup_events
    setup_scroll
    setup_parallax
    @need_refresh = false
  end
  #
  # 乗り物の作成
  #
  #
  def create_vehicles
    @vehicles = []
    @vehicles[0] = Game_Vehicle.new(0)    # 小型船
    @vehicles[1] = Game_Vehicle.new(1)    # 大型船
    @vehicles[2] = Game_Vehicle.new(2)    # 飛行船
  end
  #
  # 乗り物のリフレッシュ
  #
  #
  def referesh_vehicles
    for vehicle in @vehicles
      vehicle.refresh
    end
  end
  #
  # 小型船の取得
  #
  #
  def boat
    return @vehicles[0]
  end
  #
  # 大型船の取得
  #
  #
  def ship
    return @vehicles[1]
  end
  #
  # 飛行船の取得
  #
  #
  def airship
    return @vehicles[2]
  end
  #
  # イベントのセットアップ
  #
  #
  def setup_events
    @events = {}          # マップイベント
    for i in @map.events.keys
      @events[i] = Game_Event.new(@map_id, @map.events[i])
    end
    @common_events = {}   # コモンイベント
    for i in 1...$data_common_events.size
      @common_events[i] = Game_CommonEvent.new(i)
    end
  end
  #
  # スクロールのセットアップ
  #
  #
  def setup_scroll
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
    @margin_x = (width - 17) * 256 / 2      # 画面非表示分の横幅 / 2
    @margin_y = (height - 13) * 256 / 2     # 画面非表示分の縦幅 / 2
  end
  #
  # 遠景のセットアップ
  #
  #
  def setup_parallax
    @parallax_name = @map.parallax_name
    @parallax_loop_x = @map.parallax_loop_x
    @parallax_loop_y = @map.parallax_loop_y
    @parallax_sx = @map.parallax_sx
    @parallax_sy = @map.parallax_sy
    @parallax_x = 0
    @parallax_y = 0
  end
  #
  # 表示位置の設定
  #
  # x : 新しい表示 X 座標 (*256)
  # y : 新しい表示 Y 座標 (*256)
  #
  def set_display_pos(x, y)
    @display_x = (x + @map.width * 256) % (@map.width * 256)
    @display_y = (y + @map.height * 256) % (@map.height * 256)
    @parallax_x = x
    @parallax_y = y
  end
  #
  # 遠景表示 X 座標の計算
  #
  # bitmap : 遠景ビットマップ
  #
  def calc_parallax_x(bitmap)
    if bitmap == nil
      return 0
    elsif @parallax_loop_x
      return @parallax_x / 16
    elsif loop_horizontal?
      return 0
    else
      w1 = bitmap.width - 544
      w2 = @map.width * 32 - 544
      if w1 <= 0 or w2 <= 0
        return 0
      else
        return @parallax_x * w1 / w2 / 8
      end
    end
  end
  #
  # 遠景表示 Y 座標の計算
  #
  # bitmap : 遠景ビットマップ
  #
  def calc_parallax_y(bitmap)
    if bitmap == nil
      return 0
    elsif @parallax_loop_y
      return @parallax_y / 16
    elsif loop_vertical?
      return 0
    else
      h1 = bitmap.height - 416
      h2 = @map.height * 32 - 416
      if h1 <= 0 or h2 <= 0
        return 0
      else
        return @parallax_y * h1 / h2 / 8
      end
    end
  end
  #
  # マップ ID の取得
  #
  #
  def map_id
    return @map_id
  end
  #
  # 幅の取得
  #
  #
  def width
    return @map.width
  end
  #
  # 高さの取得
  #
  #
  def height
    return @map.height
  end
  #
  # 横方向にループするか？
  #
  #
  def loop_horizontal?
    return (@map.scroll_type == 2 or @map.scroll_type == 3)
  end
  #
  # 縦方向にループするか？
  #
  #
  def loop_vertical?
    return (@map.scroll_type == 1 or @map.scroll_type == 3)
  end
  #
  # ダッシュ禁止か否かの取得
  #
  #
  def disable_dash?
    return @map.disable_dashing
  end
  #
  # エンカウントリストの取得
  #
  #
  def encounter_list
    return @map.encounter_list
  end
  #
  # エンカウント歩数の取得
  #
  #
  def encounter_step
    return @map.encounter_step
  end
  #
  # マップデータの取得
  #
  #
  def data
    return @map.data
  end
  #
  # 表示座標を差し引いた X 座標の計算
  #
  # x : X 座標
  #
  def adjust_x(x)
    if loop_horizontal? and x < @display_x - @margin_x
      return x - @display_x + @map.width * 256
    else
      return x - @display_x
    end
  end
  #
  # 表示座標を差し引いた Y 座標の計算
  #
  # y : Y 座標
  #
  def adjust_y(y)
    if loop_vertical? and y < @display_y - @margin_y
      return y - @display_y + @map.height * 256
    else
      return y - @display_y
    end
  end
  #
  # ループ補正後の X 座標計算
  #
  # x : X 座標
  #
  def round_x(x)
    if loop_horizontal?
      return (x + width) % width
    else
      return x
    end
  end
  #
  # ループ補正後の Y 座標計算
  #
  # y : Y 座標
  #
  def round_y(y)
    if loop_vertical?
      return (y + height) % height
    else
      return y
    end
  end
  #
  # 特定の方向に 1 マスずらした X 座標の計算
  #
  # x         : X 座標
  # direction : 方向 (2,4,6,8)
  #
  def x_with_direction(x, direction)
    return round_x(x + (direction == 6 ? 1 : direction == 4 ? -1 : 0))
  end
  #
  # 特定の方向に 1 マスずらした Y 座標の計算
  #
  # y         : Y 座標
  # direction : 方向 (2,4,6,8)
  #
  def y_with_direction(y, direction)
    return round_y(y + (direction == 2 ? 1 : direction == 8 ? -1 : 0))
  end
  #
  # 指定座標に存在するイベントの配列取得
  #
  # x : X 座標
  # y : Y 座標
  #
  def events_xy(x, y)
    result = []
    for event in $game_map.events.values
      result.push(event) if event.pos?(x, y)
    end
    return result
  end
  #
  # BGM / BGS 自動切り替え
  #
  #
  def autoplay
    @map.bgm.play if @map.autoplay_bgm
    @map.bgs.play if @map.autoplay_bgs
  end
  #
  # リフレッシュ
  #
  #
  def refresh
    if @map_id > 0
      for event in @events.values
        event.refresh
      end
      for common_event in @common_events.values
        common_event.refresh
      end
    end
    @need_refresh = false
  end
  #
  # 下にスクロール
  #
  # distance : スクロールする距離
  #
  def scroll_down(distance)
    if loop_vertical?
      @display_y += distance
      @display_y %= @map.height * 256
      @parallax_y += distance
    else
      last_y = @display_y
      @display_y = [@display_y + distance, (height - 13) * 256].min
      @parallax_y += @display_y - last_y
    end
  end
  #
  # 左にスクロール
  #
  # distance : スクロールする距離
  #
  def scroll_left(distance)
    if loop_horizontal?
      @display_x += @map.width * 256 - distance
      @display_x %= @map.width * 256
      @parallax_x -= distance
    else
      last_x = @display_x
      @display_x = [@display_x - distance, 0].max
      @parallax_x += @display_x - last_x
    end
  end
  #
  # 右にスクロール
  #
  # distance : スクロールする距離
  #
  def scroll_right(distance)
    if loop_horizontal?
      @display_x += distance
      @display_x %= @map.width * 256
      @parallax_x += distance
    else
      last_x = @display_x
      @display_x = [@display_x + distance, (width - 17) * 256].min
      @parallax_x += @display_x - last_x
    end
  end
  #
  # 上にスクロール
  #
  # distance : スクロールする距離
  #
  def scroll_up(distance)
    if loop_vertical?
      @display_y += @map.height * 256 - distance
      @display_y %= @map.height * 256
      @parallax_y -= distance
    else
      last_y = @display_y
      @display_y = [@display_y - distance, 0].max
      @parallax_y += @display_y - last_y
    end
  end
  #
  # 有効座標判定
  #
  # x : X 座標
  # y : Y 座標
  #
  def valid?(x, y)
    return (x >= 0 and x < width and y >= 0 and y < height)
  end
  #
  # 通行可能判定
  #
  # x    : X 座標
  # y    : Y 座標
  # flag : 調べる通行禁止ビット (通常 0x01、乗り物の場合のみ変更)
  #
  def passable?(x, y, flag = 0x01)
    for event in events_xy(x, y)            # 座標が一致するイベントを調べる
      next if event.tile_id == 0            # グラフィックがタイルではない
      next if event.priority_type > 0       # [通常キャラの下] ではない
      next if event.through                 # すり抜け状態
      pass = @passages[event.tile_id]       # 通行属性を取得
      next if pass & 0x10 == 0x10           # [☆] : 通行に影響しない
      return true if pass & flag == 0x00    # [○] : 通行可
      return false if pass & flag == flag   # [×] : 通行不可
    end
    for i in [2, 1, 0]                      # レイヤーの上から順に調べる
      tile_id = @map.data[x, y, i]          # タイル ID を取得
      return false if tile_id == nil        # タイル ID 取得失敗 : 通行不可
      pass = @passages[tile_id]             # 通行属性を取得
      next if pass & 0x10 == 0x10           # [☆] : 通行に影響しない
      return true if pass & flag == 0x00    # [○] : 通行可
      return false if pass & flag == flag   # [×] : 通行不可
    end
    return false                            # 通行不可
  end
  #
  # 小型船の通行可能判定
  #
  # x : X 座標
  # y : Y 座標
  #
  def boat_passable?(x, y)
    return passable?(x, y, 0x02)
  end
  #
  # 大型船の通行可能判定
  #
  # x : X 座標
  # y : Y 座標
  #
  def ship_passable?(x, y)
    return passable?(x, y, 0x04)
  end
  #
  # 飛行船の着陸可能判定
  #
  # x : X 座標
  # y : Y 座標
  #
  def airship_land_ok?(x, y)
    return passable?(x, y, 0x08)
  end
  #
  # 茂み判定
  #
  # x : X 座標
  # y : Y 座標
  #
  def bush?(x, y)
    return false unless valid?(x, y)
    return @passages[@map.data[x, y, 1]] & 0x40 == 0x40
  end
  #
  # カウンター判定
  #
  # x : X 座標
  # y : Y 座標
  #
  def counter?(x, y)
    return false unless valid?(x, y)
    return @passages[@map.data[x, y, 0]] & 0x80 == 0x80
  end
  #
  # スクロールの開始
  #
  # direction : スクロールする方向
  # distance  : スクロールする距離
  # speed     : スクロールする速度
  #
  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
    @scroll_rest = distance * 256
    @scroll_speed = speed
  end
  #
  # スクロール中判定
  #
  #
  def scrolling?
    return @scroll_rest > 0
  end
  #
  # フレーム更新
  #
  #
  def update
    refresh if $game_map.need_refresh
    update_scroll
    update_events
    update_vehicles
    update_parallax
    @screen.update
  end
  #
  # スクロールの更新
  #
  #
  def update_scroll
    if @scroll_rest > 0                 # スクロール中の場合
      distance = 2 ** @scroll_speed     # マップ座標系での距離に変換
      case @scroll_direction
      when 2  # 下
        scroll_down(distance)
      when 4  # 左
        scroll_left(distance)
      when 6  # 右
        scroll_right(distance)
      when 8  # 上
        scroll_up(distance)
      end
      @scroll_rest -= distance          # スクロールした距離を減算
    end
  end
  #
  # イベントの更新
  #
  #
  def update_events
    for event in @events.values
      event.update
    end
    for common_event in @common_events.values
      common_event.update
    end
  end
  #
  # 乗り物の更新
  #
  #
  def update_vehicles
    for vehicle in @vehicles
      vehicle.update
    end
  end
  #
  # 遠景の更新
  #
  #
  def update_parallax
    @parallax_x += @parallax_sx * 4 if @parallax_loop_x
    @parallax_y += @parallax_sy * 4 if @parallax_loop_y
  end
end
