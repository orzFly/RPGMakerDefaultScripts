#
# 处理交通工具的类。该类在 Game_Map类的内部使用。
# 当前地图没有交通工具的时,地图坐标设置为 (-1,-1) 。
#

class Game_Vehicle < Game_Character
  #
  # 定量
  #
  #
  MAX_ALTITUDE = 32                       # 飞行船飞行高度
  #
  # 定义实例变量
  #
  #
  attr_reader   :type                     # 交通工具种类 (0..2)
  attr_reader   :altitude                 # 高度 (飞行船用)
  attr_reader   :driving                  # 运行中标记
  #
  # 初始化对像
  #
  # type : 交通工具种类(0:小型船 1:大型船 2:飞行船)
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
  # 读取系统设置
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
  # 刷新
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
  # 变更位置
  #
  # map_id : 地图 ID
  # x      : X 坐标
  # y      : Y 坐标
  #
  def set_location(map_id, x, y)
    @map_id = map_id
    @x = x
    @y = y
    refresh
  end
  #
  # 坐标一致判断
  #
  # x : X 坐标
  # y : Y 坐标
  #
  def pos?(x, y)
    return (@map_id == $game_map.map_id and super(x, y))
  end
  #
  # 透明判断
  #
  #
  def transparent
    return (@map_id != $game_map.map_id or super)
  end
  #
  # 搭乘交通工具
  #
  #
  def get_on
    @driving = true
    @walk_anime = true
    @step_anime = true
    if @type == 2               # 飞行船的情况
      @priority_type = 2        # 变更优先「普通造型之上」
    end
    @bgm.play                   # 开始 BGM
  end
  #
  # 降落交通工具
  #
  #
  def get_off
    @driving = false
    @walk_anime = false
    @step_anime = false
    @direction = 4
  end
  #
  # 与玩家一起行动
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
  # 获取速度
  #
  #
  def speed
    return @move_speed
  end
  #
  # 获取画面 Y 坐标
  #
  #
  def screen_y
    return super - altitude
  end
  #
  # 移动可能判断
  #
  #
  def movable?
    return false if (@type == 2 and @altitude < MAX_ALTITUDE)
    return (not moving?)
  end
  #
  # 刷新画面
  #
  #
  def update
    super
    if @type == 2               # 飞行船的情况下
      if @driving
        if @altitude < MAX_ALTITUDE
          @altitude += 1        # 高度上升
        end
      elsif @altitude > 0
        @altitude -= 1          # 高度下降
        if @altitude == 0
          @priority_type = 0    # 变更优先「普通造型之下」
        end
      end
    end
  end
end
