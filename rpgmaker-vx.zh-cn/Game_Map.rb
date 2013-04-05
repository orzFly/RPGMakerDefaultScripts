#
# 处理地图的类。包含卷动以及可以通行的判断功能。
# 本类的实例请参考 $game_map 。
#

class Game_Map
  #
  # 定义实例变量
  #
  #
  attr_reader   :screen                   # 地图画面状态
  attr_reader   :interpreter              # 地图事件用解释器
  attr_reader   :display_x                # 显示 X 坐标 * 256
  attr_reader   :display_y                # 显示 Y 坐标 * 256
  attr_reader   :parallax_name            # 远景 文件名
  attr_reader   :passages                 # 通行表
  attr_reader   :events                   # 事件
  attr_reader   :vehicles                 # 交通工具
  attr_accessor :need_refresh             # 刷新要求标志
  #
  # 初始化对象
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
  # 设置
  #
  # map_id : 地图 ID
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
  # 生成交通工具
  #
  #
  def create_vehicles
    @vehicles = []
    @vehicles[0] = Game_Vehicle.new(0)    # 小型船
    @vehicles[1] = Game_Vehicle.new(1)    # 大型船
    @vehicles[2] = Game_Vehicle.new(2)    # 飛行船
  end
  #
  # 刷新交通工具
  #
  #
  def referesh_vehicles
    for vehicle in @vehicles
      vehicle.refresh
    end
  end
  #
  # 获取小型船
  #
  #
  def boat
    return @vehicles[0]
  end
  #
  # 获取大型船
  #
  #
  def ship
    return @vehicles[1]
  end
  #
  # 获取飞行船
  #
  #
  def airship
    return @vehicles[2]
  end
  #
  # 设置事件
  #
  #
  def setup_events
    @events = {}          # 地图事件
    for i in @map.events.keys
      @events[i] = Game_Event.new(@map_id, @map.events[i])
    end
    @common_events = {}   # 公共事件
    for i in 1...$data_common_events.size
      @common_events[i] = Game_CommonEvent.new(i)
    end
  end
  #
  # 设置滚动
  #
  #
  def setup_scroll
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
    @margin_x = (width - 17) * 256 / 2      # 画面不显示的地方宽 / 2
    @margin_y = (height - 13) * 256 / 2     # 画面不显示的地方高 / 2
  end
  #
  # 设置远景
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
  # 设置显示位置
  #
  # x : 新显示 X 坐标 (*256)
  # y : 新显示 Y 坐标 (*256)
  #
  def set_display_pos(x, y)
    @display_x = (x + @map.width * 256) % (@map.width * 256)
    @display_y = (y + @map.height * 256) % (@map.height * 256)
    @parallax_x = x
    @parallax_y = y
  end
  #
  # 计算远景显示 X 坐标
  #
  # bitmap : 远景位图
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
  # 计算远景显示 Y 坐标
  #
  # bitmap : 远景位图
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
  # 获取地图 ID
  #
  #
  def map_id
    return @map_id
  end
  #
  # 获取宽度
  #
  #
  def width
    return @map.width
  end
  #
  # 获取高度
  #
  #
  def height
    return @map.height
  end
  #
  # 横方向循环吗？
  #
  #
  def loop_horizontal?
    return (@map.scroll_type == 2 or @map.scroll_type == 3)
  end
  #
  # 纵方向循环吗？
  #
  #
  def loop_vertical?
    return (@map.scroll_type == 1 or @map.scroll_type == 3)
  end
  #
  # 获取跑动与否？
  #
  #
  def disable_dash?
    return @map.disable_dashing
  end
  #
  # 获取遇敌列表
  #
  #
  def encounter_list
    return @map.encounter_list
  end
  #
  # 获取遇敌步数
  #
  #
  def encounter_step
    return @map.encounter_step
  end
  #
  # 获取地图数据
  #
  #
  def data
    return @map.data
  end
  #
  # 计算扣除显示坐标的 X 坐标
  #
  # x : X 坐标
  #
  def adjust_x(x)
    if loop_horizontal? and x < @display_x - @margin_x
      return x - @display_x + @map.width * 256
    else
      return x - @display_x
    end
  end
  #
  # 计算扣除显示坐标的 Y 坐标
  #
  # y : Y 坐标
  #
  def adjust_y(y)
    if loop_vertical? and y < @display_y - @margin_y
      return y - @display_y + @map.height * 256
    else
      return y - @display_y
    end
  end
  #
  # 计算循环修正后的 X 坐标
  #
  # x : X 坐标
  #
  def round_x(x)
    if loop_horizontal?
      return (x + width) % width
    else
      return x
    end
  end
  #
  # 计算循环修正后的 Y坐标
  #
  # y : Y 坐标
  #
  def round_y(y)
    if loop_vertical?
      return (y + height) % height
    else
      return y
    end
  end
  #
  # 计算特定方向移动 1 マス X 坐标
  #
  # x         : X 坐标
  # direction : 方向 (2,4,6,8)
  #
  def x_with_direction(x, direction)
    return round_x(x + (direction == 6 ? 1 : direction == 4 ? -1 : 0))
  end
  #
  # 计算特定方向移动 1 マス Y 坐标
  #
  # y         : Y 坐标
  # direction : 方向 (2,4,6,8)
  #
  def y_with_direction(y, direction)
    return round_y(y + (direction == 2 ? 1 : direction == 8 ? -1 : 0))
  end
  #
  # 获取指定坐标存在的事件排列
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def events_xy(x, y)
    result = []
    for event in $game_map.events.values
      result.push(event) if event.pos?(x, y)
    end
    return result
  end
  #
  # BGM / BGS 自动切换
  #
  #
  def autoplay
    @map.bgm.play if @map.autoplay_bgm
    @map.bgs.play if @map.autoplay_bgs
  end
  #
  # 刷新
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
  # 向下滚动
  #
  # distance : 滚动距离
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
  # 向左滚动
  #
  # distance : 滚动距离
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
  # 向右滚动
  #
  # distance : 滚动距离
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
  # 向上滚动
  #
  # distance : 滚动距离
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
  # 有效坐标判定
  #
  # x          : X 坐标
  # y          : Y 坐标
  #
  def valid?(x, y)
    return (x >= 0 and x < width and y >= 0 and y < height)
  end
  #
  # 可以通行判定
  #
  # x    : X 坐标
  # y    : Y 坐标  
  # flag : 检查通行禁止数据 (通常 0x01、交通工具的情况下变更)
  #
  def passable?(x, y, flag = 0x01)
    for event in events_xy(x, y)            # 检查坐标相同的事件
      next if event.tile_id == 0            # 地图没有图块的情况下
      next if event.priority_type > 0       # 不是[通常形式下] 
      next if event.through                 # 穿透状态
      pass = @passages[event.tile_id]       # 获取通行属性
      next if pass & 0x10 == 0x10           # [☆] : 不影响通行
      return true if pass & flag == 0x00    # [○] : 可通行
      return false if pass & flag == flag   # [×] : 不可通行
    end
    for i in [2, 1, 0]                      # 从层按从上到下的顺序调查循环
      tile_id = @map.data[x, y, i]          # 获取元件 ID
      return false if tile_id == nil        # 取得元件 ID 失败 : 不能通行
      pass = @passages[tile_id]             # 获取通行属性
      next if pass & 0x10 == 0x10           # [☆] : 不影响通行
      return true if pass & flag == 0x00    # [○] : 可通行
      return false if pass & flag == flag   # [×] : 不可通行
    end
    return false                            # 通行不可
  end
  #
  # 小型船通行判定
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def boat_passable?(x, y)
    return passable?(x, y, 0x02)
  end
  #
  # 大型船通行判定
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def ship_passable?(x, y)
    return passable?(x, y, 0x04)
  end
  #
  # 飞行船着陆可能判定
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def airship_land_ok?(x, y)
    return passable?(x, y, 0x08)
  end
  #
  # 茂密判定
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def bush?(x, y)
    return false unless valid?(x, y)
    return @passages[@map.data[x, y, 1]] & 0x40 == 0x40
  end
  #
  # 反击判定
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def counter?(x, y)
    return false unless valid?(x, y)
    return @passages[@map.data[x, y, 0]] & 0x80 == 0x80
  end
  #
  # 滚动开始
  #
  # direction : 滚动方向
  # distance  : 滚动距离
  # speed     : 滚动速度
  #
  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
    @scroll_rest = distance * 256
    @scroll_speed = speed
  end
  #
  # 滚动中中判定
  #
  #
  def scrolling?
    return @scroll_rest > 0
  end
  #
  # 画面刷新
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
  # 滚动刷新
  #
  #
  def update_scroll
    if @scroll_rest > 0                 # 滚动中的情况下
      distance = 2 ** @scroll_speed     # 滚动速度变化为地图坐标系的距离
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
      @scroll_rest -= distance          # 滚动距离的减法运算
    end
  end
  #
  # 刷新事件
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
  # 刷新交通工具
  #
  #
  def update_vehicles
    for vehicle in @vehicles
      vehicle.update
    end
  end
  #
  # 刷新远景
  #
  #
  def update_parallax
    @parallax_x += @parallax_sx * 4 if @parallax_loop_x
    @parallax_y += @parallax_sy * 4 if @parallax_loop_y
  end
end
