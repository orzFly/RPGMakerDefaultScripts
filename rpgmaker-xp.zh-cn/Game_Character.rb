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
  attr_reader   :real_x                   # 地图 X 坐标 (实际坐标 * 128)
  attr_reader   :real_y                   # 地图 Y 坐标 (实际坐标 * 128)
  attr_reader   :tile_id                  # 元件 ID  (0 为无效)
  attr_reader   :character_name           # 角色 文件名
  attr_reader   :character_hue            # 角色 色相
  attr_reader   :opacity                  # 不透明度
  attr_reader   :blend_type               # 合成方式
  attr_reader   :direction                # 朝向
  attr_reader   :pattern                  # 图案
  attr_reader   :move_route_forcing       # 移动路线强制标志
  attr_reader   :through                  # 穿透
  attr_accessor :animation_id             # 动画 ID
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
    @character_hue = 0
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 0
    @move_route_forcing = false
    @through = false
    @animation_id = 0
    @transparent = false
    @original_direction = 2
    @original_pattern = 0
    @move_type = 0
    @move_speed = 4
    @move_frequency = 6
    @move_route = nil
    @move_route_index = 0
    @original_move_route = nil
    @original_move_route_index = 0
    @walk_anime = true
    @step_anime = false
    @direction_fix = false
    @always_on_top = false
    @anime_count = 0
    @stop_count = 0
    @jump_count = 0
    @jump_peak = 0
    @wait_count = 0
    @locked = false
    @prelock_direction = 0
  end
  #
  # 移动中判定
  #
  #
  def moving?
    # 如果在移动中理论坐标与实际坐标不同
    return (@real_x != @x * 128 or @real_y != @y * 128)
  end
  #
  # 跳跃中判定
  #
  #
  def jumping?
    # 如果跳跃中跳跃点数比 0 大
    return @jump_count > 0
  end
  #
  # 矫正姿势
  #
  #
  def straighten
    # 移动时动画以及停止动画为 ON 的情况下
    if @walk_anime or @step_anime
      # 设置图形为 0
      @pattern = 0
    end
    # 清除动画计数
    @anime_count = 0
    # 清除被锁定的向前朝向
    @prelock_direction = 0
  end
  #
  # 强制移动路线
  #
  # move_route : 新的移动路线
  #
  def force_move_route(move_route)
    # 保存原来的移动路线
    if @original_move_route == nil
      @original_move_route = @move_route
      @original_move_route_index = @move_route_index
    end
    # 更改移动路线
    @move_route = move_route
    @move_route_index = 0
    # 设置强制移动路线标志
    @move_route_forcing = true
    # 清除被锁定的向前朝向
    @prelock_direction = 0
    # 清除等待计数
    @wait_count = 0
    # 自定义移动
    move_type_custom
  end
  #
  # 可以通行判定
  #
  # x : X 坐标
  # y : Y 坐标
  # d : 方向 (0,2,4,6,8)  ※ 0 = 全方向不能通行的情况判定 (跳跃用)
  #
  def passable?(x, y, d)
    # 求得新的坐标
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # 坐标在地图以外的情况
    unless $game_map.valid?(new_x, new_y)
      # 不能通行
      return false
    end
    # 穿透是 ON 的情况下
    if @through
      # 可以通行
      return true
    end
    # 移动者的元件无法来到指定方向的情况下
    unless $game_map.passable?(x, y, d, self)
      # 通行不可
      return false
    end
    # 从指定方向不能进入到移动处的元件的情况下
    unless $game_map.passable?(new_x, new_y, 10 - d)
      # 不能通行
      return false
    end
    # 循环全部事件
    for event in $game_map.events.values
      # 事件坐标于移动目标坐标一致的情况下
      if event.x == new_x and event.y == new_y
        # 穿透为 ON
        unless event.through
          # 自己就是事件的情况下
          if self != $game_player
            # 不能通行
            return false
          end
          # 自己是主角、对方的图形是角色的情况下
          if event.character_name != ""
            # 不能通行
            return false
          end
        end
      end
    end
    # 主角的坐标与移动目标坐标一致的情况下
    if $game_player.x == new_x and $game_player.y == new_y
      # 穿透为 ON
      unless $game_player.through
        # 自己的图形是角色的情况下
        if @character_name != ""
          # 不能通行
          return false
        end
      end
    end
    # 可以通行
    return true
  end
  #
  # 锁定
  #
  #
  def lock
    # 如果已经被锁定的情况下
    if @locked
      # 过程结束
      return
    end
    # 保存锁定前的朝向
    @prelock_direction = @direction
    # 保存主角的朝向
    turn_toward_player
    # 设置锁定中标志
    @locked = true
  end
  #
  # 锁定中判定
  #
  #
  def lock?
    return @locked
  end
  #
  # 解除锁定
  #
  #
  def unlock
    # 没有锁定的情况下
    unless @locked
      # 过程结束
      return
    end
    # 清除锁定中标志
    @locked = false
    # 没有固定朝向的情况下
    unless @direction_fix
      # 如果保存了锁定前的方向
      if @prelock_direction != 0
        # 还原为锁定前的方向
        @direction = @prelock_direction
      end
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
    @real_x = @x * 128
    @real_y = @y * 128
    @prelock_direction = 0
  end
  #
  # 获取画面 X 坐标
  #
  #
  def screen_x
    # 通过实际坐标和地图的显示位置来求得画面坐标
    return (@real_x - $game_map.display_x + 3) / 4 + 16
  end
  #
  # 获取画面 Y 坐标
  #
  #
  def screen_y
    # 通过实际坐标和地图的显示位置来求得画面坐标
    y = (@real_y - $game_map.display_y + 3) / 4 + 32
    # 取跳跃计数小的 Y 坐标
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
  # height : 角色的高度
  #
  def screen_z(height = 0)
    # 在最前显示的标志为 ON 的情况下
    if @always_on_top
      # 无条件设置为 999
      return 999
    end
    # 通过实际坐标和地图的显示位置来求得画面坐标
    z = (@real_y - $game_map.display_y + 3) / 4 + 32
    # 元件的情况下
    if @tile_id > 0
      # 元件的优先不足 * 32 
      return z + $game_map.priorities[@tile_id] * 32
    # 角色的场合
    else
      # 如果高度超过 32 就判定为满足 31
      return z + ((height > 32) ? 31 : 0)
    end
  end
  #
  # 取得茂密
  #
  #
  def bush_depth
    # 是元件、并且在最前显示为 ON 的情况下
    if @tile_id > 0 or @always_on_top
      return 0
    end
    # 以跳跃中以外要是繁茂处属性的元件为 12，除此之外为 0
    if @jump_count == 0 and $game_map.bush?(@x, @y)
      return 12
    else
      return 0
    end
  end
  #
  # 取得地形标记
  #
  #
  def terrain_tag
    return $game_map.terrain_tag(@x, @y)
  end
end


#
# 处理角色的类。本类作为 Game_Player 类与 Game_Event
# 类的超级类使用。
#

class Game_Character
  #
  # 刷新画面
  #
  #
  def update
    # 跳跃中、移动中、停止中的分支
    if jumping?
      update_jump
    elsif moving?
      update_move
    else
      update_stop
    end
    # 动画计数超过最大值的情况下
    # ※最大值等于基本值减去移动速度 * 1 的值
    if @anime_count > 18 - @move_speed * 2
      # 停止动画为 OFF 并且在停止中的情况下
      if not @step_anime and @stop_count > 0
        # 还原为原来的图形
        @pattern = @original_pattern
      # 停止动画为 ON 并且在移动中的情况下
      else
        # 更新图形
        @pattern = (@pattern + 1) % 4
      end
      # 清除动画计数
      @anime_count = 0
    end
    # 等待中的情况下
    if @wait_count > 0
      # 减少等待计数
      @wait_count -= 1
      return
    end
    # 强制移动路线的场合
    if @move_route_forcing
      # 自定义移动
      move_type_custom
      return
    end
    # 事件执行待机中并且为锁定状态的情况下
    if @starting or lock?
      # 不做规则移动
      return
    end
    # 如果停止计数超过了一定的值(由移动频度算出)
    if @stop_count > (40 - @move_frequency * 2) * (6 - @move_frequency)
      # 移动类型分支
      case @move_type
      when 1  # 随机
        move_type_random
      when 2  # 接近
        move_type_toward_player
      when 3  # 自定义
        move_type_custom
      end
    end
  end
  #
  # 更新画面 (跳跃)
  #
  #
  def update_jump
    # 跳跃计数减 1
    @jump_count -= 1
    # 计算新坐标
    @real_x = (@real_x * @jump_count + @x * 128) / (@jump_count + 1)
    @real_y = (@real_y * @jump_count + @y * 128) / (@jump_count + 1)
  end
  #
  # 更新画面 (移动)
  #
  #
  def update_move
    # 移动速度转换为地图坐标系的移动距离
    distance = 2 ** @move_speed
    # 理论坐标在实际坐标下方的情况下
    if @y * 128 > @real_y
      # 向下移动
      @real_y = [@real_y + distance, @y * 128].min
    end
    # 理论坐标在实际坐标左方的情况下
    if @x * 128 < @real_x
      # 向左移动
      @real_x = [@real_x - distance, @x * 128].max
    end
    # 理论坐标在实际坐标右方的情况下
    if @x * 128 > @real_x
      # 向右移动
      @real_x = [@real_x + distance, @x * 128].min
    end
    # 理论坐标在实际坐标上方的情况下
    if @y * 128 < @real_y
      # 向上移动
      @real_y = [@real_y - distance, @y * 128].max
    end
    # 移动时动画为 ON 的情况下
    if @walk_anime
      # 动画计数增加 1.5
      @anime_count += 1.5
    # 移动时动画为 OFF、停止时动画为 ON 的情况下
    elsif @step_anime
      # 动画计数增加 1
      @anime_count += 1
    end
  end
  #
  # 更新画面 (停止)
  #
  #
  def update_stop
    # 停止时动画为 ON 的情况下
    if @step_anime
      # 动画计数增加 1
      @anime_count += 1
    # 停止时动画为 OFF 并且、现在的图像与原来的不同的情况下
    elsif @pattern != @original_pattern
      # 动画计数增加 1.5
      @anime_count += 1.5
    end
    # 事件执行待机中并且不是锁定状态的情况下
    # ※缩定、处理成立刻停止执行中的事件
    unless @starting or lock?
      # 停止计数增加 1
      @stop_count += 1
    end
  end
  #
  # 移动类型 : 随机
  #
  #
  def move_type_random
    # 随机 0～5 的分支
    case rand(6)
    when 0..3  # 随机
      move_random
    when 4  # 前进一步
      move_forward
    when 5  # 暂时停止
      @stop_count = 0
    end
  end
  #
  # 移动类型 : 接近
  #
  #
  def move_type_toward_player
    # 求得与主角坐标的差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 求得差的绝对值
    abs_sx = sx > 0 ? sx : -sx
    abs_sy = sy > 0 ? sy : -sy
    # 如果纵横共计离开 20 个元件
    if sx + sy >= 20
      # 随机
      move_random
      return
    end
    # 随机 0～5 的分支
    case rand(6)
    when 0..3  # 接近主角
      move_toward_player
    when 4  # 随机
      move_random
    when 5  # 前进一步
      move_forward
    end
  end
  #
  # 移动类型 : 自定义
  #
  #
  def move_type_custom
    # 如果不是停止中就中断
    if jumping? or moving?
      return
    end
    # 如果在移动指令列表最后结束还没到达就循环执行
    while @move_route_index < @move_route.list.size
      # 获取移动指令
      command = @move_route.list[@move_route_index]
      # 指令编号 0 号 (列表最后) 的情况下
      if command.code == 0
        # 选项 [反复动作] 为 ON 的情况下
        if @move_route.repeat
          # 还原为移动路线的最初索引
          @move_route_index = 0
        end
        # 选项 [反复动作] 为 OFF 的情况下
        unless @move_route.repeat
          # 强制移动路线的场合
          if @move_route_forcing and not @move_route.repeat
            # 强制解除移动路线
            @move_route_forcing = false
            # 还原为原始的移动路线
            @move_route = @original_move_route
            @move_route_index = @original_move_route_index
            @original_move_route = nil
          end
          # 清除停止计数
          @stop_count = 0
        end
        return
      end
      # 移动系指令 (向下移动～跳跃) 的情况下
      if command.code <= 14
        # 命令编号分支
        case command.code
        when 1  # 向下移动
          move_down
        when 2  # 向左移动
          move_left
        when 3  # 向右移动
          move_right
        when 4  # 向上移动
          move_up
        when 5  # 向左下移动
          move_lower_left
        when 6  # 向右下移动
          move_lower_right
        when 7  # 向左上移动
          move_upper_left
        when 8  # 向右上
          move_upper_right
        when 9  # 随机移动
          move_random
        when 10  # 接近主角
          move_toward_player
        when 11  # 远离主角
          move_away_from_player
        when 12  # 前进一步
          move_forward
        when 13  # 后退一步
          move_backward
        when 14  # 跳跃
          jump(command.parameters[0], command.parameters[1])
        end
        # 选项 [无视无法移动的情况] 为 OFF 、移动失败的情况下
        if not @move_route.skippable and not moving? and not jumping?
          return
        end
        @move_route_index += 1
        return
      end
      # 等待的情况下
      if command.code == 15
        # 设置等待计数
        @wait_count = command.parameters[0] * 2 - 1
        @move_route_index += 1
        return
      end
      # 朝向变更系指令的情况下
      if command.code >= 16 and command.code <= 26
        # 命令编号分支
        case command.code
        when 16  # 面向下
          turn_down
        when 17  # 面向左
          turn_left
        when 18  # 面向右
          turn_right
        when 19  # 面向上
          turn_up
        when 20  # 向右转 90 度
          turn_right_90
        when 21  # 向左转 90 度
          turn_left_90
        when 22  # 旋转 180 度
          turn_180
        when 23  # 从右向左转 90 度
          turn_right_or_left_90
        when 24  # 随机变换方向
          turn_random
        when 25  # 面向主角的方向
          turn_toward_player
        when 26  # 背向主角的方向
          turn_away_from_player
        end
        @move_route_index += 1
        return
      end
      # 其它指令的场合
      if command.code >= 27
        # 命令编号分支
        case command.code
        when 27  # 开关 ON
          $game_switches[command.parameters[0]] = true
          $game_map.need_refresh = true
        when 28  # 开关 OFF
          $game_switches[command.parameters[0]] = false
          $game_map.need_refresh = true
        when 29  # 更改移动速度
          @move_speed = command.parameters[0]
        when 30  # 更改移动频度
          @move_frequency = command.parameters[0]
        when 31  # 移动时动画 ON
          @walk_anime = true
        when 32  # 移动时动画 OFF
          @walk_anime = false
        when 33  # 停止时动画 ON
          @step_anime = true
        when 34  # 停止时动画 OFF
          @step_anime = false
        when 35  # 朝向固定 ON
          @direction_fix = true
        when 36  # 朝向固定 OFF
          @direction_fix = false
        when 37  # 穿透 ON
          @through = true
        when 38  # 穿透 OFF
          @through = false
        when 39  # 在最前面显示 ON
          @always_on_top = true
        when 40  # 在最前面显示 OFF
          @always_on_top = false
        when 41  # 更改图形
          @tile_id = 0
          @character_name = command.parameters[0]
          @character_hue = command.parameters[1]
          if @original_direction != command.parameters[2]
            @direction = command.parameters[2]
            @original_direction = @direction
            @prelock_direction = 0
          end
          if @original_pattern != command.parameters[3]
            @pattern = command.parameters[3]
            @original_pattern = @pattern
          end
        when 42  # 不更改不透明度
          @opacity = command.parameters[0]
        when 43  # 更改合成方式
          @blend_type = command.parameters[0]
        when 44  # 演奏 SE
          $game_system.se_play(command.parameters[0])
        when 45  # 脚本
          result = eval(command.parameters[0])
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
    # 清除停止步数
    @stop_count = 0
  end
end


#
# 处理角色的类。本类作为 Game_Player 类与 Game_Event
# 类的超级类使用。
#

class Game_Character
  #
  # 向下移动
  #
  # turn_enabled : 本场地位置更改许可标志
  #
  def move_down(turn_enabled = true)
    # 面向下
    if turn_enabled
      turn_down
    end
    # 可以通行的场合
    if passable?(@x, @y, 2)
      # 面向下
      turn_down
      # 更新坐标
      @y += 1
      # 增加步数
      increase_steps
    # 不能通行的情况下
    else
      # 接触事件的启动判定
      check_event_trigger_touch(@x, @y+1)
    end
  end
  #
  # 向左移动
  #
  # turn_enabled : 本场地位置更改许可标志
  #
  def move_left(turn_enabled = true)
    # 面向左
    if turn_enabled
      turn_left
    end
    # 可以通行的情况下
    if passable?(@x, @y, 4)
      # 面向左
      turn_left
      # 更新坐标
      @x -= 1
      # 增加步数
      increase_steps
    # 不能通行的情况下
    else
      # 接触事件的启动判定
      check_event_trigger_touch(@x-1, @y)
    end
  end
  #
  # 向右移动
  #
  # turn_enabled : 本场地位置更改许可标志
  #
  def move_right(turn_enabled = true)
    # 面向右
    if turn_enabled
      turn_right
    end
    # 可以通行的场合
    if passable?(@x, @y, 6)
      # 面向右
      turn_right
      # 更新坐标
      @x += 1
      # 增加部数
      increase_steps
    # 不能通行的情况下
    else
      # 接触事件的启动判定
      check_event_trigger_touch(@x+1, @y)
    end
  end
  #
  # 向上移动
  #
  # turn_enabled : 本场地位置更改许可标志
  #
  def move_up(turn_enabled = true)
    # 面向上
    if turn_enabled
      turn_up
    end
    # 可以通行的情况下
    if passable?(@x, @y, 8)
      # 面向上
      turn_up
      # 更新坐标
      @y -= 1
      # 歩数増加
      increase_steps
    # 不能通行的情况下
    else
      # 接触事件的启动判定
      check_event_trigger_touch(@x, @y-1)
    end
  end
  #
  # 向左下移动
  #
  #
  def move_lower_left
    # 没有固定面向的场合
    unless @direction_fix
      # 朝向是右的情况下适合的面是左面、朝向是上的情况下适合的面是下面
      @direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)
    end
    # 下→左、左→下 的通道可以通行的情况下
    if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 4)) or
       (passable?(@x, @y, 4) and passable?(@x - 1, @y, 2))
      # 更新坐标
      @x -= 1
      @y += 1
      # 增加步数
      increase_steps
    end
  end
  #
  # 向右下移动
  #
  #
  def move_lower_right
    # 没有固定面向的场合
    unless @direction_fix
      # 朝向是右的情况下适合的面是左面、朝向是上的情况下适合的面是下面
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
    end
    # 下→右、右→下 的通道可以通行的情况下
    if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 6)) or
       (passable?(@x, @y, 6) and passable?(@x + 1, @y, 2))
      # 更新坐标
      @x += 1
      @y += 1
      # 增加步数
      increase_steps
    end
  end
  #
  # 向左上移动
  #
  #
  def move_upper_left
    # 没有固定面向的场合
    unless @direction_fix
      # 朝向是右的情况下适合的面是左面、朝向是上的情况下适合的面是下面
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
    end
    # 上→左、左→上 的通道可以通行的情况下
    if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 4)) or
       (passable?(@x, @y, 4) and passable?(@x - 1, @y, 8))
      # 更新坐标
      @x -= 1
      @y -= 1
      # 增加步数
      increase_steps
    end
  end
  #
  # 向右上移动
  #
  #
  def move_upper_right
    # 没有固定面向的场合
    unless @direction_fix
      # 朝向是右的情况下适合的面是左面、朝向是上的情况下适合的面是下面
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
    end
    # 上→右、右→上 的通道可以通行的情况下
    if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 6)) or
       (passable?(@x, @y, 6) and passable?(@x + 1, @y, 8))
      # 更新坐标
      @x += 1
      @y -= 1
      # 增加步数
      increase_steps
    end
  end
  #
  # 随机移动
  #
  #
  def move_random
    case rand(4)
    when 0  # 向下移动
      move_down(false)
    when 1  # 向左移动
      move_left(false)
    when 2  # 向右移动
      move_right(false)
    when 3  # 向上移动
      move_up(false)
    end
  end
  #
  # 接近主角
  #
  #
  def move_toward_player
    # 求得与主角的坐标差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 坐标相等情况下
    if sx == 0 and sy == 0
      return
    end
    # 求得差的绝对值
    abs_sx = sx.abs
    abs_sy = sy.abs
    # 横距离与纵距离相等的情况下
    if abs_sx == abs_sy
      # 随机将边数增加 1
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # 横侧距离长的情况下
    if abs_sx > abs_sy
      # 左右方向优先。向主角移动
      sx > 0 ? move_left : move_right
      if not moving? and sy != 0
        sy > 0 ? move_up : move_down
      end
    # 竖侧距离长的情况下
    else
      # 上下方向优先。向主角移动
      sy > 0 ? move_up : move_down
      if not moving? and sx != 0
        sx > 0 ? move_left : move_right
      end
    end
  end
  #
  # 远离主角
  #
  #
  def move_away_from_player
    # 求得与主角的坐标差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 坐标相等情况下
    if sx == 0 and sy == 0
      return
    end
    # 求得差的绝对值
    abs_sx = sx.abs
    abs_sy = sy.abs
    # 横距离与纵距离相等的情况下
    if abs_sx == abs_sy
      # 随机将边数增加 1
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # 横侧距离长的情况下
    if abs_sx > abs_sy
      # 左右方向优先。远离主角移动
      sx > 0 ? move_right : move_left
      if not moving? and sy != 0
        sy > 0 ? move_down : move_up
      end
    # 竖侧距离长的情况下
    else
      # 上下方向优先。远离主角移动
      sy > 0 ? move_down : move_up
      if not moving? and sx != 0
        sx > 0 ? move_right : move_left
      end
    end
  end
  #
  # 前进一步
  #
  #
  def move_forward
    case @direction
    when 2
      move_down(false)
    when 4
      move_left(false)
    when 6
      move_right(false)
    when 8
      move_up(false)
    end
  end
  #
  # 后退一步
  #
  #
  def move_backward
    # 记忆朝向固定信息
    last_direction_fix = @direction_fix
    # 强制固定朝向
    @direction_fix = true
    # 朝向分支
    case @direction
    when 2  # 下
      move_up(false)
    when 4  # 左
      move_right(false)
    when 6  # 右
      move_left(false)
    when 8  # 上
      move_down(false)
    end
    # 还原朝向固定信息
    @direction_fix = last_direction_fix
  end
  #
  # 跳跃
  #
  # x_plus : X 坐标增加值
  # y_plus : Y 坐标增加值
  #
  def jump(x_plus, y_plus)
    # 增加值不是 (0,0) 的情况下
    if x_plus != 0 or y_plus != 0
      # 横侧距离长的情况下
      if x_plus.abs > y_plus.abs
        # 变更左右方向
        x_plus < 0 ? turn_left : turn_right
      # 竖侧距离长的情况下
      else
        # 变更上下方向
        y_plus < 0 ? turn_up : turn_down
      end
    end
    # 计算新的坐标
    new_x = @x + x_plus
    new_y = @y + y_plus
    # 增加值为 (0,0) 的情况下、跳跃目标可以通行的场合
    if (x_plus == 0 and y_plus == 0) or passable?(new_x, new_y, 0)
      # 矫正姿势
      straighten
      # 更新坐标
      @x = new_x
      @y = new_y
      # 距计算距离
      distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
      # 设置跳跃记数
      @jump_peak = 10 + distance - @move_speed
      @jump_count = @jump_peak * 2
      # 清除停止记数信息
      @stop_count = 0
    end
  end
  #
  # 面向向下
  #
  #
  def turn_down
    unless @direction_fix
      @direction = 2
      @stop_count = 0
    end
  end
  #
  # 面向向左
  #
  #
  def turn_left
    unless @direction_fix
      @direction = 4
      @stop_count = 0
    end
  end
  #
  # 面向向右
  #
  #
  def turn_right
    unless @direction_fix
      @direction = 6
      @stop_count = 0
    end
  end
  #
  # 面向向上
  #
  #
  def turn_up
    unless @direction_fix
      @direction = 8
      @stop_count = 0
    end
  end
  #
  # 向右旋转 90 度
  #
  #
  def turn_right_90
    case @direction
    when 2
      turn_left
    when 4
      turn_up
    when 6
      turn_down
    when 8
      turn_right
    end
  end
  #
  # 向左旋转 90 度
  #
  #
  def turn_left_90
    case @direction
    when 2
      turn_right
    when 4
      turn_down
    when 6
      turn_up
    when 8
      turn_left
    end
  end
  #
  # 旋转 180 度
  #
  #
  def turn_180
    case @direction
    when 2
      turn_up
    when 4
      turn_right
    when 6
      turn_left
    when 8
      turn_down
    end
  end
  #
  # 从右向左旋转 90 度
  #
  #
  def turn_right_or_left_90
    if rand(2) == 0
      turn_right_90
    else
      turn_left_90
    end
  end
  #
  # 随机变换方向
  #
  #
  def turn_random
    case rand(4)
    when 0
      turn_up
    when 1
      turn_right
    when 2
      turn_left
    when 3
      turn_down
    end
  end
  #
  # 接近主角的方向
  #
  #
  def turn_toward_player
    # 求得与主角的坐标差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 坐标相等的场合下
    if sx == 0 and sy == 0
      return
    end
    # 横侧距离长的情况下
    if sx.abs > sy.abs
      # 将左右方向变更为朝向主角的方向
      sx > 0 ? turn_left : turn_right
    # 竖侧距离长的情况下
    else
      # 将上下方向变更为朝向主角的方向
      sy > 0 ? turn_up : turn_down
    end
  end
  #
  # 背向主角的方向
  #
  #
  def turn_away_from_player
    # 求得与主角的坐标差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 坐标相等的场合下
    if sx == 0 and sy == 0
      return
    end
    # 横侧距离长的情况下
    if sx.abs > sy.abs
      # 将左右方向变更为背离主角的方向
      sx > 0 ? turn_right : turn_left
    # 竖侧距离长的情况下
    else
      # 将上下方向变更为背离主角的方向
      sy > 0 ? turn_down : turn_up
    end
  end
end
