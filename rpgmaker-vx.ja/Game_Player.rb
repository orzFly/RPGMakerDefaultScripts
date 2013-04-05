#
# プレイヤーを扱うクラスです。イベントの起動判定や、マップのスクロールなどの
# 機能を持っています。このクラスのインスタンスは $game_player で参照されます。
#

class Game_Player < Game_Character
  #
  # 定数
  #
  #
  CENTER_X = (544 / 2 - 16) * 8     # 画面中央の X 座標 * 8
  CENTER_Y = (416 / 2 - 16) * 8     # 画面中央の Y 座標 * 8
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :vehicle_type       # 現在乗っている乗り物の種類 (-1:なし)
  #
  # オブジェクト初期化
  #
  #
  def initialize
    super
    @vehicle_type = -1
    @vehicle_getting_on = false     # 乗る動作の途中フラグ
    @vehicle_getting_off = false    # 降りる動作の途中フラグ
    @transferring = false           # 場所移動フラグ
    @new_map_id = 0                 # 移動先 マップ ID
    @new_x = 0                      # 移動先 X 座標
    @new_y = 0                      # 移動先 Y 座標
    @new_direction = 0              # 移動後の向き
    @walking_bgm = nil              # 歩行時の BGM 記憶用
  end
  #
  # 停止中判定
  #
  #
  def stopping?
    return false if @vehicle_getting_on
    return false if @vehicle_getting_off
    return super
  end
  #
  # 場所移動の予約
  #
  # map_id    : マップ ID
  # x         : X 座標
  # y         : Y 座標
  # direction : 移動後の向き
  #
  def reserve_transfer(map_id, x, y, direction)
    @transferring = true
    @new_map_id = map_id
    @new_x = x
    @new_y = y
    @new_direction = direction
  end
  #
  # 場所移動の予約中判定
  #
  #
  def transfer?
    return @transferring
  end
  #
  # 場所移動の実行
  #
  #
  def perform_transfer
    return unless @transferring
    @transferring = false
    set_direction(@new_direction)
    if $game_map.map_id != @new_map_id
      $game_map.setup(@new_map_id)     # 別マップへ移動
    end
    moveto(@new_x, @new_y)
  end
  #
  # マップ通行可能判定
  #
  # x : X 座標
  # y : Y 座標
  #
  def map_passable?(x, y)
    case @vehicle_type
    when 0  # 小型船
      return $game_map.boat_passable?(x, y)
    when 1  # 大型船
      return $game_map.ship_passable?(x, y)
    when 2  # 飛行船
      return true
    else    # 徒歩
      return $game_map.passable?(x, y)
    end
  end
  #
  # 歩行可能判定
  #
  # x : X 座標
  # y : Y 座標
  #
  def can_walk?(x, y)
    last_vehicle_type = @vehicle_type   # 乗り物タイプを退避
    @vehicle_type = -1                  # 一時的に徒歩に設定
    result = passable?(x, y)            # 通行可能判定
    @vehicle_type = last_vehicle_type   # 乗り物タイプを復元
    return result
  end
  #
  # 飛行船の着陸可能判定
  #
  # x : X 座標
  # y : Y 座標
  #
  def airship_land_ok?(x, y)
    unless $game_map.airship_land_ok?(x, y)
      return false    # タイルの通行属性が着陸不能
    end
    unless $game_map.events_xy(x, y).empty?
      return false    # 何らかのイベントがある地点には着陸しない
    end
    return true       # 着陸可
  end
  #
  # 何らかの乗り物に乗っている状態判定
  #
  #
  def in_vehicle?
    return @vehicle_type >= 0
  end
  #
  # 飛行船に乗っている状態判定
  #
  #
  def in_airship?
    return @vehicle_type == 2
  end
  #
  # ダッシュ状態判定
  #
  #
  def dash?
    return false if @move_route_forcing
    return false if $game_map.disable_dash?
    return false if in_vehicle?
    return Input.press?(Input::A)
  end
  #
  # デバッグすり抜け状態判定
  #
  #
  def debug_through?
    return false unless $TEST
    return Input.press?(Input::CTRL)
  end
  #
  # 画面中央に来るようにマップの表示位置を設定
  #
  # x : X 座標
  # y : Y 座標
  #
  def center(x, y)
    display_x = x * 256 - CENTER_X                    # 座標を計算
    unless $game_map.loop_horizontal?                 # 横にループしない？
      max_x = ($game_map.width - 17) * 256            # 最大値を計算
      display_x = [0, [display_x, max_x].min].max     # 座標を修正
    end
    display_y = y * 256 - CENTER_Y                    # 座標を計算
    unless $game_map.loop_vertical?                   # 縦にループしない？
      max_y = ($game_map.height - 13) * 256           # 最大値を計算
      display_y = [0, [display_y, max_y].min].max     # 座標を修正
    end
    $game_map.set_display_pos(display_x, display_y)   # 表示位置変更
  end
  #
  # 指定位置に移動
  #
  # x : X 座標
  # y : Y 座標
  #
  def moveto(x, y)
    super
    center(x, y)                                      # センタリング
    make_encounter_count                              # エンカウント初期化
    if in_vehicle?                                    # 乗り物に乗っている
      vehicle = $game_map.vehicles[@vehicle_type]     # 乗り物を取得
      vehicle.refresh                                 # リフレッシュ
    end
  end
  #
  # 歩数増加
  #
  #
  def increase_steps
    super
    return if @move_route_forcing
    return if in_vehicle?
    $game_party.increase_steps
    $game_party.on_player_walk
  end
  #
  # エンカウント カウント取得
  #
  #
  def encounter_count
    return @encounter_count
  end
  #
  # エンカウント カウント作成
  #
  #
  def make_encounter_count
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = rand(n) + rand(n) + 1  # サイコロを 2 個振るイメージ
    end
  end
  #
  # エリア内判定
  #
  # area : エリアデータ (RPG::Area)
  #
  def in_area?(area)
    return false if area == nil
    return false if $game_map.map_id != area.map_id
    return false if @x < area.rect.x
    return false if @y < area.rect.y
    return false if @x >= area.rect.x + area.rect.width
    return false if @y >= area.rect.y + area.rect.height
    return true
  end
  #
  # エンカウントする敵グループの ID を作成
  #
  #
  def make_encounter_troop_id
    encounter_list = $game_map.encounter_list.clone
    for area in $data_areas.values
      encounter_list += area.encounter_list if in_area?(area)
    end
    if encounter_list.empty?
      make_encounter_count
      return 0
    end
    return encounter_list[rand(encounter_list.size)]
  end
  #
  # リフレッシュ
  #
  #
  def refresh
    if $game_party.members.size == 0
      @character_name = ""
      @character_index = 0
    else
      actor = $game_party.members[0]   # 先頭のアクターを取得
      @character_name = actor.character_name
      @character_index = actor.character_index
    end
  end
  #
  # 同位置のイベント起動判定
  #
  # triggers : トリガーの配列
  #
  def check_event_trigger_here(triggers)
    return false if $game_map.interpreter.running?
    result = false
    for event in $game_map.events_xy(@x, @y)
      if triggers.include?(event.trigger) and event.priority_type != 1
        event.start
        result = true if event.starting
      end
    end
    return result
  end
  #
  # 正面のイベント起動判定
  #
  # triggers : トリガーの配列
  #
  def check_event_trigger_there(triggers)
    return false if $game_map.interpreter.running?
    result = false
    front_x = $game_map.x_with_direction(@x, @direction)
    front_y = $game_map.y_with_direction(@y, @direction)
    for event in $game_map.events_xy(front_x, front_y)
      if triggers.include?(event.trigger) and event.priority_type == 1
        event.start
        result = true
      end
    end
    if result == false and $game_map.counter?(front_x, front_y)
      front_x = $game_map.x_with_direction(front_x, @direction)
      front_y = $game_map.y_with_direction(front_y, @direction)
      for event in $game_map.events_xy(front_x, front_y)
        if triggers.include?(event.trigger) and event.priority_type == 1
          event.start
          result = true
        end
      end
    end
    return result
  end
  #
  # 接触イベントの起動判定
  #
  # x : X 座標
  # y : Y 座標
  #
  def check_event_trigger_touch(x, y)
    return false if $game_map.interpreter.running?
    result = false
    for event in $game_map.events_xy(x, y)
      if [1,2].include?(event.trigger) and event.priority_type == 1
        event.start
        result = true
      end
    end
    return result
  end
  #
  # 方向ボタン入力による移動処理
  #
  #
  def move_by_input
    return unless movable?
    return if $game_map.interpreter.running?
    case Input.dir4
    when 2;  move_down
    when 4;  move_left
    when 6;  move_right
    when 8;  move_up
    end
  end
  #
  # 移動可能判定
  #
  #
  def movable?
    return false if moving?                     # 移動中
    return false if @move_route_forcing         # 移動ルート強制中
    return false if @vehicle_getting_on         # 乗る動作の途中
    return false if @vehicle_getting_off        # 降りる動作の途中
    return false if $game_message.visible       # メッセージ表示中
    return false if in_airship? and not $game_map.airship.movable?
    return true
  end
  #
  # フレーム更新
  #
  #
  def update
    last_real_x = @real_x
    last_real_y = @real_y
    last_moving = moving?
    move_by_input
    super
    update_scroll(last_real_x, last_real_y)
    update_vehicle
    update_nonmoving(last_moving)
  end
  #
  # スクロール処理
  #
  #
  def update_scroll(last_real_x, last_real_y)
    ax1 = $game_map.adjust_x(last_real_x)
    ay1 = $game_map.adjust_y(last_real_y)
    ax2 = $game_map.adjust_x(@real_x)
    ay2 = $game_map.adjust_y(@real_y)
    if ay2 > ay1 and ay2 > CENTER_Y
      $game_map.scroll_down(ay2 - ay1)
    end
    if ax2 < ax1 and ax2 < CENTER_X
      $game_map.scroll_left(ax1 - ax2)
    end
    if ax2 > ax1 and ax2 > CENTER_X
      $game_map.scroll_right(ax2 - ax1)
    end
    if ay2 < ay1 and ay2 < CENTER_Y
      $game_map.scroll_up(ay1 - ay2)
    end
  end
  #
  # 乗り物の処理
  #
  #
  def update_vehicle
    return unless in_vehicle?
    vehicle = $game_map.vehicles[@vehicle_type]
    if @vehicle_getting_on                    # 乗る途中？
      if not moving?
        @direction = vehicle.direction        # 向きを変更
        @move_speed = vehicle.speed           # 移動速度を変更
        @vehicle_getting_on = false           # 乗る動作終了
        @transparent = true                   # 透明化
      end
    elsif @vehicle_getting_off                # 降りる途中？
      if not moving? and vehicle.altitude == 0
        @vehicle_getting_off = false          # 降りる動作終了
        @vehicle_type = -1                    # 乗り物タイプ消去
        @transparent = false                  # 透明を解除
      end
    else                                      # 乗り物に乗っている
      vehicle.sync_with_player                # プレイヤーと同時に動かす
    end
  end
  #
  # 移動中でない場合の処理
  #
  # last_moving : 直前に移動中だったか
  #
  def update_nonmoving(last_moving)
    return if $game_map.interpreter.running?
    return if moving?
    return if check_touch_event if last_moving
    if not $game_message.visible and Input.trigger?(Input::C)
      return if get_on_off_vehicle
      return if check_action_event
    end
    update_encounter if last_moving
  end
  #
  # エンカウントの更新
  #
  #
  def update_encounter
    return if $TEST and Input.press?(Input::CTRL)   # テストプレイ中？
    return if in_vehicle?                           # 乗り物に乗っている？
    if $game_map.bush?(@x, @y)                      # 茂みなら
      @encounter_count -= 2                         # カウントを 2 減らす
    else                                            # 茂み以外なら
      @encounter_count -= 1                         # カウントを 1 減らす
    end
  end
  #
  # 接触（重なり）によるイベント起動判定
  #
  #
  def check_touch_event
    return false if in_airship?
    return check_event_trigger_here([1,2])
  end
  #
  # 決定ボタンによるイベント起動判定
  #
  #
  def check_action_event
    return false if in_airship?
    return true if check_event_trigger_here([0])
    return check_event_trigger_there([0,1,2])
  end
  #
  # 乗り物の乗降
  #
  #
  def get_on_off_vehicle
    return false unless movable?
    if in_vehicle?
      return get_off_vehicle
    else
      return get_on_vehicle
    end
  end
  #
  # 乗り物に乗る
  #
  # 現在乗り物に乗っていないことが前提。
  #
  def get_on_vehicle
    front_x = $game_map.x_with_direction(@x, @direction)
    front_y = $game_map.y_with_direction(@y, @direction)
    if $game_map.airship.pos?(@x, @y)             # 飛行船と重なっている？
      get_on_airship
      return true
    elsif $game_map.ship.pos?(front_x, front_y)   # 正面に大型船がある？
      get_on_ship
      return true
    elsif $game_map.boat.pos?(front_x, front_y)   # 正面に小型船がある？
      get_on_boat
      return true
    end
    return false
  end
  #
  # 小型船に乗る
  #
  #
  def get_on_boat
    @vehicle_getting_on = true        # 乗り込み中フラグ
    @vehicle_type = 0                 # 乗り物タイプ設定
    force_move_forward                # 一歩前進
    @walking_bgm = RPG::BGM::last     # 歩行時の BGM 記憶
    $game_map.boat.get_on             # 乗り込み処理
  end
  #
  # 大型船に乗る
  #
  #
  def get_on_ship
    @vehicle_getting_on = true        # 乗る
    @vehicle_type = 1                 # 乗り物タイプ設定
    force_move_forward                # 一歩前進
    @walking_bgm = RPG::BGM::last     # 歩行時の BGM 記憶
    $game_map.ship.get_on             # 乗り込み処理
  end
  #
  # 飛行船に乗る
  #
  #
  def get_on_airship
    @vehicle_getting_on = true        # 乗る動作の開始
    @vehicle_type = 2                 # 乗り物タイプ設定
    @through = true                   # すり抜け ON
    @walking_bgm = RPG::BGM::last     # 歩行時の BGM 記憶
    $game_map.airship.get_on          # 乗り込み処理
  end
  #
  # 乗り物から降りる
  #
  # 現在乗り物に乗っていることが前提。
  #
  def get_off_vehicle
    if in_airship?                                # 飛行船
      return unless airship_land_ok?(@x, @y)      # 着陸できない？
    else                                          # 小型船・大型船
      front_x = $game_map.x_with_direction(@x, @direction)
      front_y = $game_map.y_with_direction(@y, @direction)
      return unless can_walk?(front_x, front_y)   # 接岸できない？
    end
    $game_map.vehicles[@vehicle_type].get_off     # 降りる処理
    if in_airship?                                # 飛行船
      @direction = 2                              # 下を向く
    else                                          # 小型船・大型船
      force_move_forward                          # 一歩前進
      @transparent = false                        # 透明を解除
    end
    @vehicle_getting_off = true                   # 降りる動作の開始
    @move_speed = 4                               # 移動速度を戻す
    @through = false                              # すり抜け OFF
    @walking_bgm.play                             # 歩行時の BGM 復帰
    make_encounter_count                          # エンカウント初期化
  end
  #
  # 強制的に一歩前進
  #
  #
  def force_move_forward
    @through = true         # すり抜け ON
    move_forward            # 一歩前進
    @through = false        # すり抜け OFF
  end
end
