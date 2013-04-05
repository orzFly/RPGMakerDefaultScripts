#
# 处理同伴的类。事件启动判定、持有地图滚动功能。
# 本类的实例请参考 $game_party。
#

class Game_Player < Game_Character
  #
  # 定量
  #
  #
  CENTER_X = (544 / 2 - 16) * 8     # 画面中心的 X 坐标 * 8
  CENTER_Y = (416 / 2 - 16) * 8     # 画面中心的 Y 坐标 * 8
  #
  # 定义实例变量
  #
  #
  attr_reader   :vehicle_type       # 现在搭乘的交通工具种类(-1:无)
  #
  # 初始化对像
  #
  #
  def initialize
    super
    @vehicle_type = -1
    @vehicle_getting_on = false     # 搭乘动作中标记
    @vehicle_getting_off = false    # 降落动作中标记
    @transferring = false           # 场所移动标记
    @new_map_id = 0                 # 移动目标 地图 ID
    @new_x = 0                      # 移动目标 X 坐标
    @new_y = 0                      # 移动目标 Y 坐标
    @new_direction = 0              # 移动后的朝向
    @walking_bgm = nil              # 记忆步行时的 BGM 
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
  # 场所移动的准备
  #
  # map_id    : 地图 ID
  # x         : X 坐标
  # y         : Y 坐标
  # direction : 移动后的朝向
  #
  def reserve_transfer(map_id, x, y, direction)
    @transferring = true
    @new_map_id = map_id
    @new_x = x
    @new_y = y
    @new_direction = direction
  end
  #
  # 场所移动准备中判定
  #
  #
  def transfer?
    return @transferring
  end
  #
  # 执行场所移动
  #
  #
  def perform_transfer
    return unless @transferring
    @transferring = false
    set_direction(@new_direction)
    if $game_map.map_id != @new_map_id
      $game_map.setup(@new_map_id)     # 移动到别的地图
    end
    moveto(@new_x, @new_y)
  end
  #
  # 地图通行判定
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def map_passable?(x, y)
    case @vehicle_type
    when 0  # 小型船
      return $game_map.boat_passable?(x, y)
    when 1  # 大型船
      return $game_map.ship_passable?(x, y)
    when 2  # 飞行船
      return true
    else    # 徒步
      return $game_map.passable?(x, y)
    end
  end
  #
  # 步行可能判定
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def can_walk?(x, y)
    last_vehicle_type = @vehicle_type   # 退出交通工具并记录类型
    @vehicle_type = -1                  # 暂时设置步行
    result = passable?(x, y)            # 通行可能判定
    @vehicle_type = last_vehicle_type   # 恢复交通工具类型
    return result
  end
  #
  # 飞行船着陆可能判定
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def airship_land_ok?(x, y)
    unless $game_map.airship_land_ok?(x, y)
      return false    # 通行属性类型为不可着陆
    end
    unless $game_map.events_xy(x, y).empty?
      return false    # 有事件的地点不着陆
    end
    return true       # 可以着陆
  end
  #
  # 搭乘交通工具状态判定
  #
  #
  def in_vehicle?
    return @vehicle_type >= 0
  end
  #
  # 搭乘飞行船状态判定
  #
  #
  def in_airship?
    return @vehicle_type == 2
  end
  #
  # 跑动状态判定
  #
  #
  def dash?
    return false if @move_route_forcing
    return false if $game_map.disable_dash?
    return false if in_vehicle?
    return Input.press?(Input::A)
  end
  #
  # debug穿透状态判定
  #
  #
  def debug_through?
    return false unless $TEST
    return Input.press?(Input::CTRL)
  end
  #
  # 设置在画面中央的地图显示位置
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def center(x, y)
    display_x = x * 256 - CENTER_X                    # 计算坐标
    unless $game_map.loop_horizontal?                 # 横向不循环？
      max_x = ($game_map.width - 17) * 256            # 计算最大值
      display_x = [0, [display_x, max_x].min].max     # 坐标修正
    end
    display_y = y * 256 - CENTER_Y                    # 计算坐标
    unless $game_map.loop_vertical?                   # 纵向不循环？
      max_y = ($game_map.height - 13) * 256           # 计算最大值
      display_y = [0, [display_y, max_y].min].max     # 坐标修正
    end
    $game_map.set_display_pos(display_x, display_y)   # 显示位置变更
  end
  #
  # 向指定的位置移动
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def moveto(x, y)
    super
    center(x, y)                                      # 自连接
    make_encounter_count                              # 遇敌初期化
    if in_vehicle?                                    # 若搭乘交通工具
      vehicle = $game_map.vehicles[@vehicle_type]     # 获取交通工具
      vehicle.refresh                                 # 刷新
    end
  end
  #
  # 增加步数
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
  # 获取遇敌计数
  #
  #
  def encounter_count
    return @encounter_count
  end
  #
  # 生成遇敌计数
  #
  #
  def make_encounter_count
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = rand(n) + rand(n) + 1  # 两种颜色震动的图像
    end
  end
  #
  # 区域内判定
  #
  # area : 区域数据 (RPG::Area)
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
  # 生成遇敌列表敌人小组
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
  # 刷新
  #
  #
  def refresh
    if $game_party.members.size == 0
      @character_name = ""
      @character_index = 0
    else
      actor = $game_party.members[0]   # 获取带头的角色
      @character_name = actor.character_name
      @character_index = actor.character_index
    end
  end
  #
  # 同位置的事件启动判定
  #
  # triggers : 触发方式序列
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
  # 正面事件的启动判定
  #
  # triggers : 触发方式序列
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
  # 接触事件启动判定
  #
  # x : X 坐标
  # y : Y 坐标
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
  # 输入方向移动处理
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
  # 移动可能判定
  #
  #
  def movable?
    return false if moving?                     # 移动中
    return false if @move_route_forcing         # 强制移动中
    return false if @vehicle_getting_on         # 搭乘动作动作中
    return false if @vehicle_getting_off        # 降落动作中
    return false if $game_message.visible       # 文章显示表示中
    return false if in_airship? and not $game_map.airship.movable?
    return true
  end
  #
  # 刷新画面
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
  # 滚动处理
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
  # 交通工具处理
  #
  #
  def update_vehicle
    return unless in_vehicle?
    vehicle = $game_map.vehicles[@vehicle_type]
    if @vehicle_getting_on                    # 搭乘动作中？
      if not moving?
        @direction = vehicle.direction        # 方向变更
        @move_speed = vehicle.speed           # 移动速度变更
        @vehicle_getting_on = false           # 搭乘动作结束
        @transparent = true                   # 透明化
      end
    elsif @vehicle_getting_off                # 降落动作中？
      if not moving? and vehicle.altitude == 0
        @vehicle_getting_off = false          # 降落动作结束
        @vehicle_type = -1                    # 交通工具种类消去
        @transparent = false                  # 解除透明
      end
    else                                      # 搭乘交通工具
      vehicle.sync_with_player                # 与玩家一起行动
    end
  end
  #
  # 不在移动中的情况下处理
  #
  # last_moving : 之前是移动中吗
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
  # 刷新遇敌列表
  #
  #
  def update_encounter
    return if $TEST and Input.press?(Input::CTRL)   # 若debug状态
    return if in_vehicle?                           # 若搭乘交通工具？
    if $game_map.bush?(@x, @y)                      # 草木繁茂
      @encounter_count -= 2                         # 遇敌计数 减 2
    else                                            # 草木繁茂以外
      @encounter_count -= 1                         # 遇敌计数 减 1
    end
  end
  #
  # 接触（重叠）事件启动判定
  #
  #
  def check_touch_event
    return false if in_airship?
    return check_event_trigger_here([1,2])
  end
  #
  # 确定按键事件启动判定
  #
  #
  def check_action_event
    return false if in_airship?
    return true if check_event_trigger_here([0])
    return check_event_trigger_there([0,1,2])
  end
  #
  # 交通工具乘降
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
  # 搭乘交通工具
  #
  # 前提现在没乘坐交通工具
  #
  def get_on_vehicle
    front_x = $game_map.x_with_direction(@x, @direction)
    front_y = $game_map.y_with_direction(@y, @direction)
    if $game_map.airship.pos?(@x, @y)             # 与飞行船重叠？
      get_on_airship
      return true
    elsif $game_map.ship.pos?(front_x, front_y)   # 正面是大型船？
      get_on_ship
      return true
    elsif $game_map.boat.pos?(front_x, front_y)   # 正面是小型船？
      get_on_boat
      return true
    end
    return false
  end
  #
  # 搭乘小型船
  #
  #
  def get_on_boat
    @vehicle_getting_on = true        # 搭乘中标记
    @vehicle_type = 0                 # 设定搭乘种类
    force_move_forward                # 前进一步
    @walking_bgm = RPG::BGM::last     # 记忆步行时的BGM 
    $game_map.boat.get_on             # 搭乘处理
  end
  #
  # 搭乘大型船
  #
  #
  def get_on_ship
    @vehicle_getting_on = true        # 搭乘
    @vehicle_type = 1                 # 设定搭乘种类
    force_move_forward                # 前进一步
    @walking_bgm = RPG::BGM::last     # 记忆步行时的BGM 
    $game_map.ship.get_on             # 搭乘处理
  end
  #
  # 搭乘飞行船
  #
  #
  def get_on_airship
    @vehicle_getting_on = true        # 开始搭乘动作
    @vehicle_type = 2                 # 设定搭乘种类
    @through = true                   # 穿透 ON
    @walking_bgm = RPG::BGM::last     # 记忆步行时的BGM 
    $game_map.airship.get_on          # 搭乘处理
  end
  #
  # 降落交通工具
  #
  # 前提现在正乘坐交通工具。
  #
  def get_off_vehicle
    if in_airship?                                # 飞行船
      return unless airship_land_ok?(@x, @y)      # 不可着陆？
    else                                          # 小型船・大型船
      front_x = $game_map.x_with_direction(@x, @direction)
      front_y = $game_map.y_with_direction(@y, @direction)
      return unless can_walk?(front_x, front_y)   # 不可接岸？
    end
    $game_map.vehicles[@vehicle_type].get_off     # 降落处理
    if in_airship?                                # 飞行船
      @direction = 2                              # 朝向下
    else                                          # 小型船・大型船
      force_move_forward                          # 前进一步
      @transparent = false                        # 透明解除
    end
    @vehicle_getting_off = true                   # 开始降落动作
    @move_speed = 4                               # 恢复移动速度
    @through = false                              # 穿透 OFF
    @walking_bgm.play                             # 恢复步行时的BGM 
    make_encounter_count                          # 遇敌列表初始化
  end
  #
  # 强行前进一步
  #
  #
  def force_move_forward
    @through = true         # 穿透 ON
    move_forward            # 前进一步
    @through = false        # 穿透 OFF
  end
end
