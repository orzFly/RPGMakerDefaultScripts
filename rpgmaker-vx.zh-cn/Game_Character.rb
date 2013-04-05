#
# 处理角色的类。本类作为 Game_Player 类与 Game_Event
# 类的超级类使用。
#

class Game_Character
  #
  # 定义实例变量
  #
  #
  attr_reader   :id                       # ID
  attr_reader   :x                        # 地图 X 坐标 (理论坐标)
  attr_reader   :y                        # 地图 Y 坐标 (理论坐标)
  attr_reader   :real_x                   # 地图 X 坐标 (实际坐标 * 256)
  attr_reader   :real_y                   # 地图 Y 坐标 (实际坐标 * 256)
  attr_reader   :tile_id                  # 元件 ID  (0 为无效)
  attr_reader   :character_name           # 行走图文件名
  attr_reader   :character_index          # 行走图索引
  attr_reader   :opacity                  # 不透明度
  attr_reader   :blend_type               # 合成方式
  attr_reader   :direction                # 朝向
  attr_reader   :pattern                  # 图案
  attr_reader   :move_route_forcing       # 移动路线强制标志
  attr_reader   :priority_type            # 优先类型
  attr_reader   :through                  # 穿透
  attr_reader   :bush_depth               # 草木繁茂深度
  attr_accessor :animation_id             # 动画 ID
  attr_accessor :balloon_id               # 表情图标 ID
  attr_accessor :transparent              # 透明状态
  #
  # 初始化对像
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
    @original_direction = 2               # 原来的方向
    @original_pattern = 1                 # 原来的图案
    @move_type = 0                        # 移动类型
    @move_speed = 4                       # 移动速度
    @move_frequency = 6                   # 移动频度
    @move_route = nil                     # 移动路线
    @move_route_index = 0                 # 移动路线的执行位置
    @original_move_route = nil            # 原来的移动路线
    @original_move_route_index = 0        # 原来的移动路线的执行位置
    @walk_anime = true                    # 步行动画
    @step_anime = false                   # 踏步动画
    @direction_fix = false                # 固定朝向
    @anime_count = 0                      # 动画计数
    @stop_count = 0                       # 停止计数
    @jump_count = 0                       # 跳跃计数
    @jump_peak = 0                        # 跳跃定点计数
    @wait_count = 0                       # 等待计数
    @locked = false                       # 锁定标记
    @prelock_direction = 0                # 锁定前朝向
    @move_failed = false                  # 移动失败标记
  end
  #
  # 移动中判定
  #
  #
  def moving?
    return (@real_x != @x * 256 or @real_y != @y * 256)   # 与理论坐标比较
  end
  #
  # 跳跃中判定
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
  # 跑动状态判定
  #
  #
  def dash?
    return false
  end
  #
  # debug穿透状态判定
  #
  #
  def debug_through?
    return false
  end
  #
  # 矫正姿势
  #
  #
  def straighten
    @pattern = 1 if @walk_anime or @step_anime
    @anime_count = 0
  end
  #
  # 强制移动路线
  #
  # move_route : 新移动路线
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
  # 坐标一致判定
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def pos?(x, y)
    return (@x == x and @y == y)
  end
  #
  # 坐标一致 与「穿透 OFF」判定 (nt = No Through)
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def pos_nt?(x, y)
    return (pos?(x, y) and not @through)
  end
  #
  # 通行可能判定
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def passable?(x, y)
    x = $game_map.round_x(x)                        # 横方向循环补正
    y = $game_map.round_y(y)                        # 纵方向循环补正
    return false unless $game_map.valid?(x, y)      # 地图外？
    return true if @through or debug_through?       # 穿透 ON？
    return false unless map_passable?(x, y)         # 地图通行不能？
    return false if collide_with_characters?(x, y)  # 与角色冲突？
    return true                                     # 可通行
  end
  #
  # 地图通行可能判定
  #
  # x : X 坐标
  # y : Y 坐标
  # 获取指定位置元件通行可能。
  #
  def map_passable?(x, y)
    return $game_map.passable?(x, y)
  end
  #
  # 角色冲突判定
  #
  # x : X 坐标
  # y : Y 坐标
  # 包含主角与交通工具、可以检查出普通造型的冲突。
  #
  def collide_with_characters?(x, y)
    for event in $game_map.events_xy(x, y)          # 与事件坐标相同
      unless event.through                          # 穿透 OFF？
        return true if self.is_a?(Game_Event)       # 自己是事件
        return true if event.priority_type == 1     # 对方是通常造型
      end
    end
    if @priority_type == 1                          # 自己是通常造型
      return true if $game_player.pos_nt?(x, y)     # 与主角坐标相同
      return true if $game_map.boat.pos_nt?(x, y)   # 与小型船坐标相同
      return true if $game_map.ship.pos_nt?(x, y)   # 与大型船坐标相同
    end
    return false
  end
  #
  # 锁定 (执行中的事件立即停止处理)
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
  # 解除锁定
  #
  #
  def unlock
    if @locked
      @locked = false
      set_direction(@prelock_direction)
    end
  end
  #
  # 移动到指定位置
  #
  # x : X 坐标
  # y : Y 坐标
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
  # 变更至指定方向
  #
  # direction :朝向
  #
  def set_direction(direction)
    if not @direction_fix and direction != 0
      @direction = direction
      @stop_count = 0
    end
  end
  #
  # 对象类型判定
  #
  #
  def object?
    return (@tile_id > 0 or @character_name[0, 1] == '!')
  end
  #
  # 获取画面 X 坐标
  #
  #
  def screen_x
    return ($game_map.adjust_x(@real_x) + 8007) / 8 - 1000 + 16
  end
  #
  # 获取画面 Y 坐标
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
  # 获取画面 Z 坐标
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
  # 刷新画面
  #
  #
  def update
    if jumping?                 # 跳跃中
      update_jump
    elsif moving?               # 移动中
      update_move
    else                        # 停止中
      update_stop
    end
    if @wait_count > 0          # 等待中
      @wait_count -= 1
    elsif @move_route_forcing   # 强制移动中
      move_type_custom
    elsif not @locked           # 没有锁定的情况下
      update_self_movement
    end
    update_animation
  end
  #
  # 刷新跳跃状态
  #
  #
  def update_jump
    @jump_count -= 1
    @real_x = (@real_x * @jump_count + @x * 256) / (@jump_count + 1)
    @real_y = (@real_y * @jump_count + @y * 256) / (@jump_count + 1)
    update_bush_depth
  end
  #
  # 刷新移动状态
  #
  #
  def update_move
    distance = 2 ** @move_speed   # 根据移动速度变更移动距离
    distance *= 2 if dash?        # 跑动状态增至二倍
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
  # 刷新停止状态
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
  # 刷新自定义移动
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
  # 刷新动画计数
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
  # 刷新繁茂深度
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
  # 移动类型 : 随机
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
  # 移动类型 : 接近
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
  # 移动类型 : 自定义
  #
  #
  def move_type_custom
    if stopping?
      command = @move_route.list[@move_route_index]   # 获取移动指令
      @move_failed = false
      if command.code == 0                            # 列表最后的情况
        if @move_route.repeat                         # 选项 [反复动作] 为 ON 的情况下 
          @move_route_index = 0
        elsif @move_route_forcing                     # 强制移动的情况下
          @move_route_forcing = false                 # 强制解除移动路线
          @move_route = @original_move_route          # 还原为原来的移动路线
          @move_route_index = @original_move_route_index
          @original_move_route = nil
        end
      else
        case command.code
        when 1    # 向下移动
          move_down
        when 2    # 向左移动
          move_left
        when 3    # 向右移动
          move_right
        when 4    # 向上移动
          move_up
        when 5    # 向左下移动
          move_lower_left
        when 6    # 向右下移动
          move_lower_right
        when 7    # 向左上移动
          move_upper_left
        when 8    # 向右上移动
          move_upper_right
        when 9    # 随机移动
          move_random
        when 10   # 接近主角
          move_toward_player
        when 11   # 远离主角
          move_away_from_player
        when 12   # 前进一步
          move_forward
        when 13   # 后退一步
          move_backward
        when 14   # 跳跃
          jump(command.parameters[0], command.parameters[1])
        when 15   # 等待
          @wait_count = command.parameters[0] - 1
        when 16   # 面向下
          turn_down
        when 17   # 面向左
          turn_left
        when 18   # 面向右
          turn_right
        when 19   # 面向上
          turn_up
        when 20   # 向右转 90 度
          turn_right_90
        when 21   # 向左转 90 度
          turn_left_90
        when 22   # 旋转 180 度
          turn_180
        when 23   # 从右向左转 90 度
          turn_right_or_left_90
        when 24   # 随机变换方向
          turn_random
        when 25   # 面向主角的方向
          turn_toward_player
        when 26   # 背向主角的方向
          turn_away_from_player
        when 27   # 开关 ON
          $game_switches[command.parameters[0]] = true
          $game_map.need_refresh = true
        when 28   # 开关 OFF
          $game_switches[command.parameters[0]] = false
          $game_map.need_refresh = true
        when 29   # 更改移动速度
          @move_speed = command.parameters[0]
        when 30   # 更改移动频度
          @move_frequency = command.parameters[0]
        when 31   # 移动时动画 ON
          @walk_anime = true
        when 32   # 移动时动画 OFF
          @walk_anime = false
        when 33   # 踏步动画 ON
          @step_anime = true
        when 34   # 踏步动画 OFF
          @step_anime = false
        when 35   # 朝向固定 ON
          @direction_fix = true
        when 36   # 朝向固定 OFF
          @direction_fix = false
        when 37   # 穿透 ON
          @through = true
        when 38   # 穿透 OFF
          @through = false
        when 39   # 透明化 ON
          @transparent = true
        when 40   # 透明化 OFF
          @transparent = false
        when 41   # 更改图形
          set_graphic(command.parameters[0], command.parameters[1])
        when 42   # 更改不透明度
          @opacity = command.parameters[0]
        when 43   # 更改合成方式
          @blend_type = command.parameters[0]
        when 44   # 演奏SE
          command.parameters[0].play
        when 45   # 脚本
          eval(command.parameters[0])
        end
        if not @move_route.skippable and @move_failed
          return  # [忽略不能移动的情况] OFF & 移动失败
        end
        @move_route_index += 1
      end
    end
  end
  #
  # 增加步数
  #
  #
  def increase_steps
    @stop_count = 0
    update_bush_depth
  end
  #
  # 计算与主角的 X 距离
  #
  #
  def distance_x_from_player
    sx = @x - $game_player.x
    if $game_map.loop_horizontal?         # 横向循环时
      if sx.abs > $game_map.width / 2     # 绝对值为地图宽的一半？
        sx -= $game_map.width             # 拉动地图宽
      end
    end
    return sx
  end
  #
  # 计算与主角的 Y 距离
  #
  #
  def distance_y_from_player
    sy = @y - $game_player.y
    if $game_map.loop_vertical?           # 纵向循环时
      if sy.abs > $game_map.height / 2    # 绝对值为地图高的一半？
        sy -= $game_map.height            # 拉动地图高
      end
    end
    return sy
  end
  #
  # 向下移动
  #
  # turn_ok : 本场地朝行变更许可标志
  #
  def move_down(turn_ok = true)
    if passable?(@x, @y+1)                  # 可通行
      turn_down
      @y = $game_map.round_y(@y+1)
      @real_y = (@y-1)*256
      increase_steps
      @move_failed = false
    else                                    # 不可通行
      turn_down if turn_ok
      check_event_trigger_touch(@x, @y+1)   # 接触事件的启动判定
      @move_failed = true
    end
  end
  #
  # 向左移动
  #
  # turn_ok : 本场地朝行变更许可标志
  #
  def move_left(turn_ok = true)
    if passable?(@x-1, @y)                  # 可通行
      turn_left
      @x = $game_map.round_x(@x-1)
      @real_x = (@x+1)*256
      increase_steps
      @move_failed = false
    else                                    # 不可通行
      turn_left if turn_ok
      check_event_trigger_touch(@x-1, @y)   # 接触事件的启动判定
      @move_failed = true
    end
  end
  #
  # 向右移动
  #
  # turn_ok : 本场地朝行变更许可标志
  #
  def move_right(turn_ok = true)
    if passable?(@x+1, @y)                  # 可通行
      turn_right
      @x = $game_map.round_x(@x+1)
      @real_x = (@x-1)*256
      increase_steps
      @move_failed = false
    else                                    # 不可通行
      turn_right if turn_ok
      check_event_trigger_touch(@x+1, @y)   # 接触事件的启动判定
      @move_failed = true
    end
  end
  #
  # 向上移动
  #
  # turn_ok : 本场地朝行变更许可标志
  #
  def move_up(turn_ok = true)
    if passable?(@x, @y-1)                  # 可通行
      turn_up
      @y = $game_map.round_y(@y-1)
      @real_y = (@y+1)*256
      increase_steps
      @move_failed = false
    else                                    # 不可通行
      turn_up if turn_ok
      check_event_trigger_touch(@x, @y-1)   # 接触事件的启动判定
      @move_failed = true
    end
  end
  #
  # 向左下移动
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
  # 向右下移动
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
  # 向左上移动
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
  # 向右上移动
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
  # 随机移动
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
  # 接近主角
  #
  #
  def move_toward_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx != 0 or sy != 0
      if sx.abs > sy.abs                  # 横向距离长
        sx > 0 ? move_left : move_right   # 左右方向优先
        if @move_failed and sy != 0
          sy > 0 ? move_up : move_down
        end
      else                                # 纵向距离长或相等
        sy > 0 ? move_up : move_down      # 上下方向优先
        if @move_failed and sx != 0
          sx > 0 ? move_left : move_right
        end
      end
    end
  end
  #
  # 远离主角
  #
  #
  def move_away_from_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx != 0 or sy != 0
      if sx.abs > sy.abs                  # 横向距离长
        sx > 0 ? move_right : move_left   # 左右方向优先
        if @move_failed and sy != 0
          sy > 0 ? move_down : move_up
        end
      else                                # 纵向距离长或相等
        sy > 0 ? move_down : move_up      # 上下方向优先
        if @move_failed and sx != 0
          sx > 0 ? move_right : move_left
        end
      end
    end
  end
  #
  # 前进一步
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
  # 后退一步
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
  # 跳跃
  #
  # x_plus : X 坐标增加值
  # y_plus : Y 坐标增加值
  #
  def jump(x_plus, y_plus)
    if x_plus.abs > y_plus.abs            # 横向距离长
      x_plus < 0 ? turn_left : turn_right
    elsif x_plus.abs > y_plus.abs         # 纵向距离长
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
  # 面向向下
  #
  #
  def turn_down
    set_direction(2)
  end
  #
  # 面向向左
  #
  #
  def turn_left
    set_direction(4)
  end
  #
  # 面向向右
  #
  #
  def turn_right
    set_direction(6)
  end
  #
  # 面向向上
  #
  #
  def turn_up
    set_direction(8)
  end
  #
  # 向右旋转 90 度
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
  # 向左旋转 90 度
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
  # 旋转 180 度
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
  # 从右向左旋转 90 度
  #
  #
  def turn_right_or_left_90
    case rand(2)
    when 0;  turn_right_90
    when 1;  turn_left_90
    end
  end
  #
  # 随机变换方向
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
  # 接近主角的方向
  #
  #
  def turn_toward_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx.abs > sy.abs                    # 横向距离长
      sx > 0 ? turn_left : turn_right
    elsif sx.abs < sy.abs                 # 纵向距离长
      sy > 0 ? turn_up : turn_down
    end
  end
  #
  # 背向主角的方向
  #
  #
  def turn_away_from_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx.abs > sy.abs                    # 横向距离长
      sx > 0 ? turn_right : turn_left
    elsif sx.abs < sy.abs                 # 纵向距离长
      sy > 0 ? turn_down : turn_up
    end
  end
  #
  # 更改图形
  #
  # character_name  : 新行走图 文件名
  # character_index : 新行走图 索引
  #
  def set_graphic(character_name, character_index)
    @tile_id = 0
    @character_name = character_name
    @character_index = character_index
  end
end
