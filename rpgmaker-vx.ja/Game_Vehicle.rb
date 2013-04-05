#
# 乗り物を扱うクラスです。このクラスは Game_Map クラスの内部で使用されます。
# 現在のマップに乗り物がないときは、マップ座標 (-1,-1) に設定されます。
#

class Game_Vehicle < Game_Character
  #
  # 定数
  #
  #
  MAX_ALTITUDE = 32                       # 飛行船が飛ぶ高さ
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :type                     # 乗り物タイプ (0..2)
  attr_reader   :altitude                 # 高さ (飛行船用)
  attr_reader   :driving                  # 運転中フラグ
  #
  # オブジェクト初期化
  #
  # type : 乗り物タイプ (0:小型船 1:大型船 2:飛行船)
  #
  def initialize(type)
    super()
    @type = type
    @altitude = 0
    @driving = false
    @direction = 4
    @walk_anime = false
    @step_anime = false
    load_system_settings
  end
  #
  # システム設定のロード
  #
  #
  def load_system_settings
    case @type
    when 0;  sys_vehicle = $data_system.boat
    when 1;  sys_vehicle = $data_system.ship
    when 2;  sys_vehicle = $data_system.airship
    else;    sys_vehicle = nil
    end
    if sys_vehicle != nil
      @character_name = sys_vehicle.character_name
      @character_index = sys_vehicle.character_index
      @bgm = sys_vehicle.bgm
      @map_id = sys_vehicle.start_map_id
      @x = sys_vehicle.start_x
      @y = sys_vehicle.start_y
    end
  end
  #
  # リフレッシュ
  #
  #
  def refresh
    if @driving
      @map_id = $game_map.map_id
      sync_with_player
    elsif @map_id == $game_map.map_id
      moveto(@x, @y)
    end
    case @type
    when 0;
      @priority_type = 1
      @move_speed = 4
    when 1;
      @priority_type = 1
      @move_speed = 5
    when 2;
      @priority_type = @driving ? 2 : 0
      @move_speed = 6
    end
    @walk_anime = @driving
    @step_anime = @driving
  end
  #
  # 位置の変更
  #
  # map_id : マップ ID
  # x      : X 座標
  # y      : Y 座標
  #
  def set_location(map_id, x, y)
    @map_id = map_id
    @x = x
    @y = y
    refresh
  end
  #
  # 座標一致判定
  #
  # x : X 座標
  # y : Y 座標
  #
  def pos?(x, y)
    return (@map_id == $game_map.map_id and super(x, y))
  end
  #
  # 透明判定
  #
  #
  def transparent
    return (@map_id != $game_map.map_id or super)
  end
  #
  # 乗り物に乗る
  #
  #
  def get_on
    @driving = true
    @walk_anime = true
    @step_anime = true
    if @type == 2               # 飛行船の場合
      @priority_type = 2        # プライオリティを「通常キャラの上」に変更
    end
    @bgm.play                   # BGM 開始
  end
  #
  # 乗り物から降りる
  #
  #
  def get_off
    @driving = false
    @walk_anime = false
    @step_anime = false
    @direction = 4
  end
  #
  # プレイヤーとの同期
  #
  #
  def sync_with_player
    @x = $game_player.x
    @y = $game_player.y
    @real_x = $game_player.real_x
    @real_y = $game_player.real_y
    @direction = $game_player.direction
    update_bush_depth
  end
  #
  # 速度の取得
  #
  #
  def speed
    return @move_speed
  end
  #
  # 画面 Y 座標の取得
  #
  #
  def screen_y
    return super - altitude
  end
  #
  # 移動可能判定
  #
  #
  def movable?
    return false if (@type == 2 and @altitude < MAX_ALTITUDE)
    return (not moving?)
  end
  #
  # フレーム更新
  #
  #
  def update
    super
    if @type == 2               # 飛行船の場合
      if @driving
        if @altitude < MAX_ALTITUDE
          @altitude += 1        # 高度を上げる
        end
      elsif @altitude > 0
        @altitude -= 1          # 高度を下げる
        if @altitude == 0
          @priority_type = 0    # プライオリティを「通常キャラの下」に戻す
        end
      end
    end
  end
end
