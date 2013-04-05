#
# キャラクターを扱うクラスです。このクラスは Game_Player クラスと Game_Event
# クラスのスーパークラスとして使用されます。
#

class Game_Character
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :id                       # ID
  attr_reader   :x                        # マップ X 座標 (論理座標)
  attr_reader   :y                        # マップ Y 座標 (論理座標)
  attr_reader   :real_x                   # マップ X 座標 (実座標 * 256)
  attr_reader   :real_y                   # マップ Y 座標 (実座標 * 256)
  attr_reader   :tile_id                  # タイル ID  (0 なら無効)
  attr_reader   :character_name           # 歩行グラフィック ファイル名
  attr_reader   :character_index          # 歩行グラフィック インデックス
  attr_reader   :opacity                  # 不透明度
  attr_reader   :blend_type               # 合成方法
  attr_reader   :direction                # 向き
  attr_reader   :pattern                  # パターン
  attr_reader   :move_route_forcing       # 移動ルート強制フラグ
  attr_reader   :priority_type            # プライオリティタイプ
  attr_reader   :through                  # すり抜け
  attr_reader   :bush_depth               # 茂み深さ
  attr_accessor :animation_id             # アニメーション ID
  attr_accessor :balloon_id               # フキダシアイコン ID
  attr_accessor :transparent              # 透明状態
  #
  # オブジェクト初期化
  #
  #
  def initialize
    @id = 0
    @x = 0
    @y = 0
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    @character_name = ""
    @character_index = 0
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 1
    @move_route_forcing = false
    @priority_type = 1
    @through = false
    @bush_depth = 0
    @animation_id = 0
    @balloon_id = 0
    @transparent = false
    @original_direction = 2               # 元の向き
    @original_pattern = 1                 # 元のパターン
    @move_type = 0                        # 移動タイプ
    @move_speed = 4                       # 移動速度
    @move_frequency = 6                   # 移動頻度
    @move_route = nil                     # 移動ルート
    @move_route_index = 0                 # 移動ルートの実行位置
    @original_move_route = nil            # 元の移動ルート
    @original_move_route_index = 0        # 元の移動ルートの実行位置
    @walk_anime = true                    # 歩行アニメ
    @step_anime = false                   # 足踏みアニメ
    @direction_fix = false                # 向き固定
    @anime_count = 0                      # アニメカウント
    @stop_count = 0                       # 停止カウント
    @jump_count = 0                       # ジャンプカウント
    @jump_peak = 0                        # ジャンプの頂点のカウント
    @wait_count = 0                       # ウェイトカウント
    @locked = false                       # ロックフラグ
    @prelock_direction = 0                # ロック前の向き
    @move_failed = false                  # 移動失敗フラグ
  end
  #
  # 移動中判定
  #
  #
  def moving?
    return (@real_x != @x * 256 or @real_y != @y * 256)   # 論理座標と比較
  end
  #
  # ジャンプ中判定
  #
  #
  def jumping?
    return @jump_count > 0
  end
  #
  # 停止中判定
  #
  #
  def stopping?
    return (not (moving? or jumping?))
  end
  #
  # ダッシュ状態判定
  #
  #
  def dash?
    return false
  end
  #
  # デバッグすり抜け状態判定
  #
  #
  def debug_through?
    return false
  end
  #
  # 姿勢の矯正
  #
  #
  def straighten
    @pattern = 1 if @walk_anime or @step_anime
    @anime_count = 0
  end
  #
  # 移動ルートの強制
  #
  # move_route : 新しい移動ルート
  #
  def force_move_route(move_route)
    if @original_move_route == nil
      @original_move_route = @move_route
      @original_move_route_index = @move_route_index
    end
    @move_route = move_route
    @move_route_index = 0
    @move_route_forcing = true
    @prelock_direction = 0
    @wait_count = 0
    move_type_custom
  end
  #
  # 座標一致判定
  #
  # x : X 座標
  # y : Y 座標
  #
  def pos?(x, y)
    return (@x == x and @y == y)
  end
  #
  # 座標一致と「すり抜け OFF」判定 (nt = No Through)
  #
  # x : X 座標
  # y : Y 座標
  #
  def pos_nt?(x, y)
    return (pos?(x, y) and not @through)
  end
  #
  # 通行可能判定
  #
  # x : X 座標
  # y : Y 座標
  #
  def passable?(x, y)
    x = $game_map.round_x(x)                        # 横方向ループ補正
    y = $game_map.round_y(y)                        # 縦方向ループ補正
    return false unless $game_map.valid?(x, y)      # マップ外？
    return true if @through or debug_through?       # すり抜け ON？
    return false unless map_passable?(x, y)         # マップが通行不能？
    return false if collide_with_characters?(x, y)  # キャラクターに衝突？
    return true                                     # 通行可
  end
  #
  # マップ通行可能判定
  #
  # x : X 座標
  # y : Y 座標
  # 指定された座標のタイルが通行可能かを取得する。
  #
  def map_passable?(x, y)
    return $game_map.passable?(x, y)
  end
  #
  # キャラクター衝突判定
  #
  # x : X 座標
  # y : Y 座標
  # プレイヤーと乗り物を含め、通常キャラの衝突を検出する。
  #
  def collide_with_characters?(x, y)
    for event in $game_map.events_xy(x, y)          # イベントの座標と一致
      unless event.through                          # すり抜け OFF？
        return true if self.is_a?(Game_Event)       # 自分がイベント
        return true if event.priority_type == 1     # 相手が通常キャラ
      end
    end
    if @priority_type == 1                          # 自分が通常キャラ
      return true if $game_player.pos_nt?(x, y)     # プレイヤーの座標と一致
      return true if $game_map.boat.pos_nt?(x, y)   # 小型船の座標と一致
      return true if $game_map.ship.pos_nt?(x, y)   # 大型船の座標と一致
    end
    return false
  end
  #
  # ロック (実行中のイベントが立ち止まる処理)
  #
  #
  def lock
    unless @locked
      @prelock_direction = @direction
      turn_toward_player
      @locked = true
    end
  end
  #
  # ロック解除
  #
  #
  def unlock
    if @locked
      @locked = false
      set_direction(@prelock_direction)
    end
  end
  #
  # 指定位置に移動
  #
  # x : X 座標
  # y : Y 座標
  #
  def moveto(x, y)
    @x = x % $game_map.width
    @y = y % $game_map.height
    @real_x = @x * 256
    @real_y = @y * 256
    @prelock_direction = 0
    straighten
    update_bush_depth
  end
  #
  # 指定方向に向き変更
  #
  # direction : 向き
  #
  def set_direction(direction)
    if not @direction_fix and direction != 0
      @direction = direction
      @stop_count = 0
    end
  end
  #
  # オブジェクトタイプ判定
  #
  #
  def object?
    return (@tile_id > 0 or @character_name[0, 1] == '!')
  end
  #
  # 画面 X 座標の取得
  #
  #
  def screen_x
    return ($game_map.adjust_x(@real_x) + 8007) / 8 - 1000 + 16
  end
  #
  # 画面 Y 座標の取得
  #
  #
  def screen_y
    y = ($game_map.adjust_y(@real_y) + 8007) / 8 - 1000 + 32
    y -= 4 unless object?
    if @jump_count >= @jump_peak
      n = @jump_count - @jump_peak
    else
      n = @jump_peak - @jump_count
    end
    return y - (@jump_peak * @jump_peak - n * n) / 2
  end
  #
  # 画面 Z 座標の取得
  #
  #
  def screen_z
    if @priority_type == 2
      return 200
    elsif @priority_type == 0
      return 60
    elsif @tile_id > 0
      pass = $game_map.passages[@tile_id]
      if pass & 0x10 == 0x10    # [☆]
        return 160
      else
        return 40
      end
    else
      return 100
    end
  end
  #
  # フレーム更新
  #
  #
  def update
    if jumping?                 # ジャンプ中
      update_jump
    elsif moving?               # 移動中
      update_move
    else                        # 停止中
      update_stop
    end
    if @wait_count > 0          # ウェイト中
      @wait_count -= 1
    elsif @move_route_forcing   # 移動ルート強制中
      move_type_custom
    elsif not @locked           # ロック中以外
      update_self_movement
    end
    update_animation
  end
  #
  # ジャンプ時の更新
  #
  #
  def update_jump
    @jump_count -= 1
    @real_x = (@real_x * @jump_count + @x * 256) / (@jump_count + 1)
    @real_y = (@real_y * @jump_count + @y * 256) / (@jump_count + 1)
    update_bush_depth
  end
  #
  # 移動時の更新
  #
  #
  def update_move
    distance = 2 ** @move_speed   # 移動速度から移動距離に変換
    distance *= 2 if dash?        # ダッシュ状態ならさらに倍
    @real_x = [@real_x - distance, @x * 256].max if @x * 256 < @real_x
    @real_x = [@real_x + distance, @x * 256].min if @x * 256 > @real_x
    @real_y = [@real_y - distance, @y * 256].max if @y * 256 < @real_y
    @real_y = [@real_y + distance, @y * 256].min if @y * 256 > @real_y
    update_bush_depth unless moving?
    if @walk_anime
      @anime_count += 1.5
    elsif @step_anime
      @anime_count += 1
    end
  end
  #
  # 停止時の更新
  #
  #
  def update_stop
    if @step_anime
      @anime_count += 1
    elsif @pattern != @original_pattern
      @anime_count += 1.5
    end
    @stop_count += 1 unless @locked
  end
  #
  # 自律移動の更新
  #
  #
  def update_self_movement
    if @stop_count > 30 * (5 - @move_frequency)
      case @move_type
      when 1;  move_type_random
      when 2;  move_type_toward_player
      when 3;  move_type_custom
      end
    end
  end
  #
  # アニメカウントの更新
  #
  #
  def update_animation
    speed = @move_speed + (dash? ? 1 : 0)
    if @anime_count > 18 - speed * 2
      if not @step_anime and @stop_count > 0
        @pattern = @original_pattern
      else
        @pattern = (@pattern + 1) % 4
      end
      @anime_count = 0
    end
  end
  #
  # 茂み深さの更新
  #
  #
  def update_bush_depth
    if object? or @priority_type != 1 or @jump_count > 0
      @bush_depth = 0
    else
      bush = $game_map.bush?(@x, @y)
      if bush and not moving?
        @bush_depth = 8
      elsif not bush
        @bush_depth = 0
      end
    end
  end
  #
  # 移動タイプ : ランダム
  #
  #
  def move_type_random
    case rand(6)
    when 0..1;  move_random
    when 2..4;  move_forward
    when 5;     @stop_count = 0
    end
  end
  #
  # 移動タイプ : 近づく
  #
  #
  def move_type_toward_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    if sx.abs + sy.abs >= 20
      move_random
    else
      case rand(6)
      when 0..3;  move_toward_player
      when 4;     move_random
      when 5;     move_forward
      end
    end
  end
  #
  # 移動タイプ : カスタム
  #
  #
  def move_type_custom
    if stopping?
      command = @move_route.list[@move_route_index]   # 移動コマンドを取得
      @move_failed = false
      if command.code == 0                            # リストの最後
        if @move_route.repeat                         # [動作を繰り返す]
          @move_route_index = 0
        elsif @move_route_forcing                     # 移動ルート強制中
          @move_route_forcing = false                 # 強制を解除
          @move_route = @original_move_route          # オリジナルを復帰
          @move_route_index = @original_move_route_index
          @original_move_route = nil
        end
      else
        case command.code
        when 1    # 下に移動
          move_down
        when 2    # 左に移動
          move_left
        when 3    # 右に移動
          move_right
        when 4    # 上に移動
          move_up
        when 5    # 左下に移動
          move_lower_left
        when 6    # 右下に移動
          move_lower_right
        when 7    # 左上に移動
          move_upper_left
        when 8    # 右上に移動
          move_upper_right
        when 9    # ランダムに移動
          move_random
        when 10   # プレイヤーに近づく
          move_toward_player
        when 11   # プレイヤーから遠ざかる
          move_away_from_player
        when 12   # 一歩前進
          move_forward
        when 13   # 一歩後退
          move_backward
        when 14   # ジャンプ
          jump(command.parameters[0], command.parameters[1])
        when 15   # ウェイト
          @wait_count = command.parameters[0] - 1
        when 16   # 下を向く
          turn_down
        when 17   # 左を向く
          turn_left
        when 18   # 右を向く
          turn_right
        when 19   # 上を向く
          turn_up
        when 20   # 右に 90 度回転
          turn_right_90
        when 21   # 左に 90 度回転
          turn_left_90
        when 22   # 180 度回転
          turn_180
        when 23   # 右か左に 90 度回転
          turn_right_or_left_90
        when 24   # ランダムに方向転換
          turn_random
        when 25   # プレイヤーの方を向く
          turn_toward_player
        when 26   # プレイヤーの逆を向く
          turn_away_from_player
        when 27   # スイッチ ON
          $game_switches[command.parameters[0]] = true
          $game_map.need_refresh = true
        when 28   # スイッチ OFF
          $game_switches[command.parameters[0]] = false
          $game_map.need_refresh = true
        when 29   # 移動速度の変更
          @move_speed = command.parameters[0]
        when 30   # 移動頻度の変更
          @move_frequency = command.parameters[0]
        when 31   # 歩行アニメ ON
          @walk_anime = true
        when 32   # 歩行アニメ OFF
          @walk_anime = false
        when 33   # 足踏みアニメ ON
          @step_anime = true
        when 34   # 足踏みアニメ OFF
          @step_anime = false
        when 35   # 向き固定 ON
          @direction_fix = true
        when 36   # 向き固定 OFF
          @direction_fix = false
        when 37   # すり抜け ON
          @through = true
        when 38   # すり抜け OFF
          @through = false
        when 39   # 透明化 ON
          @transparent = true
        when 40   # 透明化 OFF
          @transparent = false
        when 41   # グラフィック変更
          set_graphic(command.parameters[0], command.parameters[1])
        when 42   # 不透明度の変更
          @opacity = command.parameters[0]
        when 43   # 合成方法の変更
          @blend_type = command.parameters[0]
        when 44   # SE の演奏
          command.parameters[0].play
        when 45   # スクリプト
          eval(command.parameters[0])
        end
        if not @move_route.skippable and @move_failed
          return  # [移動できない場合は無視] OFF & 移動失敗
        end
        @move_route_index += 1
      end
    end
  end
  #
  # 歩数増加
  #
  #
  def increase_steps
    @stop_count = 0
    update_bush_depth
  end
  #
  # プレイヤーからの X 距離計算
  #
  #
  def distance_x_from_player
    sx = @x - $game_player.x
    if $game_map.loop_horizontal?         # 横にループしているとき
      if sx.abs > $game_map.width / 2     # 絶対値がマップの半分より大きい？
        sx -= $game_map.width             # マップの幅を引く
      end
    end
    return sx
  end
  #
  # プレイヤーからの Y 距離計算
  #
  #
  def distance_y_from_player
    sy = @y - $game_player.y
    if $game_map.loop_vertical?           # 縦にループしているとき
      if sy.abs > $game_map.height / 2    # 絶対値がマップの半分より大きい？
        sy -= $game_map.height            # マップの高さを引く
      end
    end
    return sy
  end
  #
  # 下に移動
  #
  # turn_ok : その場での向き変更を許可
  #
  def move_down(turn_ok = true)
    if passable?(@x, @y+1)                  # 通行可能
      turn_down
      @y = $game_map.round_y(@y+1)
      @real_y = (@y-1)*256
      increase_steps
      @move_failed = false
    else                                    # 通行不可能
      turn_down if turn_ok
      check_event_trigger_touch(@x, @y+1)   # 接触イベントの起動判定
      @move_failed = true
    end
  end
  #
  # 左に移動
  #
  # turn_ok : その場での向き変更を許可
  #
  def move_left(turn_ok = true)
    if passable?(@x-1, @y)                  # 通行可能
      turn_left
      @x = $game_map.round_x(@x-1)
      @real_x = (@x+1)*256
      increase_steps
      @move_failed = false
    else                                    # 通行不可能
      turn_left if turn_ok
      check_event_trigger_touch(@x-1, @y)   # 接触イベントの起動判定
      @move_failed = true
    end
  end
  #
  # 右に移動
  #
  # turn_ok : その場での向き変更を許可
  #
  def move_right(turn_ok = true)
    if passable?(@x+1, @y)                  # 通行可能
      turn_right
      @x = $game_map.round_x(@x+1)
      @real_x = (@x-1)*256
      increase_steps
      @move_failed = false
    else                                    # 通行不可能
      turn_right if turn_ok
      check_event_trigger_touch(@x+1, @y)   # 接触イベントの起動判定
      @move_failed = true
    end
  end
  #
  # 上に移動
  #
  # turn_ok : その場での向き変更を許可
  #
  def move_up(turn_ok = true)
    if passable?(@x, @y-1)                  # 通行可能
      turn_up
      @y = $game_map.round_y(@y-1)
      @real_y = (@y+1)*256
      increase_steps
      @move_failed = false
    else                                    # 通行不可能
      turn_up if turn_ok
      check_event_trigger_touch(@x, @y-1)   # 接触イベントの起動判定
      @move_failed = true
    end
  end
  #
  # 左下に移動
  #
  #
  def move_lower_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)
    end
    if (passable?(@x, @y+1) and passable?(@x-1, @y+1)) or
       (passable?(@x-1, @y) and passable?(@x-1, @y+1))
      @x -= 1
      @y += 1
      increase_steps
      @move_failed = false
    else
      @move_failed = true
    end
  end
  #
  # 右下に移動
  #
  #
  def move_lower_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
    end
    if (passable?(@x, @y+1) and passable?(@x+1, @y+1)) or
       (passable?(@x+1, @y) and passable?(@x+1, @y+1))
      @x += 1
      @y += 1
      increase_steps
      @move_failed = false
    else
      @move_failed = true
    end
  end
  #
  # 左上に移動
  #
  #
  def move_upper_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
    end
    if (passable?(@x, @y-1) and passable?(@x-1, @y-1)) or
       (passable?(@x-1, @y) and passable?(@x-1, @y-1))
      @x -= 1
      @y -= 1
      increase_steps
      @move_failed = false
    else
      @move_failed = true
    end
  end
  #
  # 右上に移動
  #
  #
  def move_upper_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
    end
    if (passable?(@x, @y-1) and passable?(@x+1, @y-1)) or
       (passable?(@x+1, @y) and passable?(@x+1, @y-1))
      @x += 1
      @y -= 1
      increase_steps
      @move_failed = false
    else
      @move_failed = true
    end
  end
  #
  # ランダムに移動
  #
  #
  def move_random
    case rand(4)
    when 0;  move_down(false)
    when 1;  move_left(false)
    when 2;  move_right(false)
    when 3;  move_up(false)
    end
  end
  #
  # プレイヤーに近づく
  #
  #
  def move_toward_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx != 0 or sy != 0
      if sx.abs > sy.abs                  # 横の距離のほうが長い
        sx > 0 ? move_left : move_right   # 左右方向を優先
        if @move_failed and sy != 0
          sy > 0 ? move_up : move_down
        end
      else                                # 縦の距離のほうが長いか等しい
        sy > 0 ? move_up : move_down      # 上下方向を優先
        if @move_failed and sx != 0
          sx > 0 ? move_left : move_right
        end
      end
    end
  end
  #
  # プレイヤーから遠ざかる
  #
  #
  def move_away_from_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx != 0 or sy != 0
      if sx.abs > sy.abs                  # 横の距離のほうが長い
        sx > 0 ? move_right : move_left   # 左右方向を優先
        if @move_failed and sy != 0
          sy > 0 ? move_down : move_up
        end
      else                                # 縦の距離のほうが長いか等しい
        sy > 0 ? move_down : move_up      # 上下方向を優先
        if @move_failed and sx != 0
          sx > 0 ? move_right : move_left
        end
      end
    end
  end
  #
  # 一歩前進
  #
  #
  def move_forward
    case @direction
    when 2;  move_down(false)
    when 4;  move_left(false)
    when 6;  move_right(false)
    when 8;  move_up(false)
    end
  end
  #
  # 一歩後退
  #
  #
  def move_backward
    last_direction_fix = @direction_fix
    @direction_fix = true
    case @direction
    when 2;  move_up(false)
    when 4;  move_right(false)
    when 6;  move_left(false)
    when 8;  move_down(false)
    end
    @direction_fix = last_direction_fix
  end
  #
  # ジャンプ
  #
  # x_plus : X 座標加算値
  # y_plus : Y 座標加算値
  #
  def jump(x_plus, y_plus)
    if x_plus.abs > y_plus.abs            # 横の距離のほうが長い
      x_plus < 0 ? turn_left : turn_right
    elsif x_plus.abs > y_plus.abs         # 縦の距離のほうが長い
      y_plus < 0 ? turn_up : turn_down
    end
    @x += x_plus
    @y += y_plus
    distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
    @jump_peak = 10 + distance - @move_speed
    @jump_count = @jump_peak * 2
    @stop_count = 0
    straighten
  end
  #
  # 下を向く
  #
  #
  def turn_down
    set_direction(2)
  end
  #
  # 左を向く
  #
  #
  def turn_left
    set_direction(4)
  end
  #
  # 右を向く
  #
  #
  def turn_right
    set_direction(6)
  end
  #
  # 上を向く
  #
  #
  def turn_up
    set_direction(8)
  end
  #
  # 右に 90 度回転
  #
  #
  def turn_right_90
    case @direction
    when 2;  turn_left
    when 4;  turn_up
    when 6;  turn_down
    when 8;  turn_right
    end
  end
  #
  # 左に 90 度回転
  #
  #
  def turn_left_90
    case @direction
    when 2;  turn_right
    when 4;  turn_down
    when 6;  turn_up
    when 8;  turn_left
    end
  end
  #
  # 180 度回転
  #
  #
  def turn_180
    case @direction
    when 2;  turn_up
    when 4;  turn_right
    when 6;  turn_left
    when 8;  turn_down
    end
  end
  #
  # 右か左に 90 度回転
  #
  #
  def turn_right_or_left_90
    case rand(2)
    when 0;  turn_right_90
    when 1;  turn_left_90
    end
  end
  #
  # ランダムに方向転換
  #
  #
  def turn_random
    case rand(4)
    when 0;  turn_up
    when 1;  turn_right
    when 2;  turn_left
    when 3;  turn_down
    end
  end
  #
  # プレイヤーの方を向く
  #
  #
  def turn_toward_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx.abs > sy.abs                    # 横の距離のほうが長い
      sx > 0 ? turn_left : turn_right
    elsif sx.abs < sy.abs                 # 縦の距離のほうが長い
      sy > 0 ? turn_up : turn_down
    end
  end
  #
  # プレイヤーの逆を向く
  #
  #
  def turn_away_from_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx.abs > sy.abs                    # 横の距離のほうが長い
      sx > 0 ? turn_right : turn_left
    elsif sx.abs < sy.abs                 # 縦の距離のほうが長い
      sy > 0 ? turn_down : turn_up
    end
  end
  #
  # グラフィックの変更
  #
  # character_name  : 新しい歩行グラフィック ファイル名
  # character_index : 新しい歩行グラフィック インデックス
  #
  def set_graphic(character_name, character_index)
    @tile_id = 0
    @character_name = character_name
    @character_index = character_index
  end
end
