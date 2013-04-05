#
# 处理事件的类。条件判断、事件页的切换、并行处理、执行事件功能
# 在 Game_Map 类的内部使用。
#

class Game_Event < Game_Character
  #
  # 定义实例变量
  #
  #
  attr_reader   :trigger                  # 触发器
  attr_reader   :list                     # 执行内容
  attr_reader   :starting                 # 启动中标记
  #
  # 初始化对像
  #
  # map_id : 地图 ID
  # event  : 事件 (RPG::Event)
  #
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    @erased = false
    @starting = false
    @through = true
    moveto(@event.x, @event.y)            # 初期位置的移动
    refresh
  end
  #
  # 清除移动中标志
  #
  #
  def clear_starting
    @starting = false
  end
  #
  # 启动事件
  #
  #
  def start
    return if @list.size <= 1                   # 事件的执行内容不为空的时候
    @starting = true
    lock if @trigger < 3
    unless $game_map.interpreter.running?
      $game_map.interpreter.setup_starting_event
    end
  end
  #
  # 暂时消失
  #
  #
  def erase
    @erased = true
    refresh
  end
  #
  # 事件页的启动条件判定
  #
  #
  def conditions_met?(page)
    c = page.condition
    if c.switch1_valid      # 开关 1
      return false if $game_switches[c.switch1_id] == false
    end
    if c.switch2_valid      # 开关 2
      return false if $game_switches[c.switch2_id] == false
    end
    if c.variable_valid     # 变量
      return false if $game_variables[c.variable_id] < c.variable_value
    end
    if c.self_switch_valid  # 独立开关
      key = [@map_id, @event.id, c.self_switch_ch]
      return false if $game_self_switches[key] != true
    end
    if c.item_valid         # 拥有物品
      item = $data_items[c.item_id]
      return false if $game_party.item_number(item) == 0
    end
    if c.actor_valid        # 队员
      actor = $game_actors[c.actor_id]
      return false unless $game_party.members.include?(actor)
    end
    return true   # 条件相同
  end
  #
  # 事件的设置
  #
  #
  def setup(new_page)
    @page = new_page
    if @page == nil
      @tile_id = 0
      @character_name = ""
      @character_index = 0
      @move_type = 0
      @through = true
      @trigger = nil
      @list = nil
      @interpreter = nil
    else
      @tile_id = @page.graphic.tile_id
      @character_name = @page.graphic.character_name
      @character_index = @page.graphic.character_index
      if @original_direction != @page.graphic.direction
        @direction = @page.graphic.direction
        @original_direction = @direction
        @prelock_direction = 0
      end
      if @original_pattern != @page.graphic.pattern
        @pattern = @page.graphic.pattern
        @original_pattern = @pattern
      end
      @move_type = @page.move_type
      @move_speed = @page.move_speed
      @move_frequency = @page.move_frequency
      @move_route = @page.move_route
      @move_route_index = 0
      @move_route_forcing = false
      @walk_anime = @page.walk_anime
      @step_anime = @page.step_anime
      @direction_fix = @page.direction_fix
      @through = @page.through
      @priority_type = @page.priority_type
      @trigger = @page.trigger
      @list = @page.list
      @interpreter = nil
      if @trigger == 4                       # 事件为 [并行处理] 的情况下
        @interpreter = Game_Interpreter.new  # 并行处理用解释器生成
      end
    end
    update_bush_depth
  end
  #
  # 刷新
  #
  #
  def refresh
    new_page = nil
    unless @erased                          # 不是 暂时消失 的場合
      for page in @event.pages.reverse      # 按照事件编号的顺序
        next unless conditions_met?(page)   # 条件吻合判定
        new_page = page
        break
      end
    end
    if new_page != @page            # 事件页变化了？
      clear_starting                # 清除移动中标志
      setup(new_page)               # 事件页的设置
      check_event_trigger_auto      # 自动执行启动判定
    end
  end
  #
  # 接触事件启动判定
  #
  #
  def check_event_trigger_touch(x, y)
    return if $game_map.interpreter.running?
    if @trigger == 2 and $game_player.pos?(x, y)
      start if not jumping? and @priority_type == 1
    end
  end
  #
  # 自动事件启动判定
  #
  #
  def check_event_trigger_auto
    start if @trigger == 3
  end
  #
  # 刷新
  #
  #
  def update
    super
    check_event_trigger_auto                    # 自动执行启动判定
    if @interpreter != nil                      # 并行处理有效
      unless @interpreter.running?              # 如果不是正在执行
        @interpreter.setup(@list, @event.id)    # 设置事件
      end
      @interpreter.update                       # 更新解释器
    end
  end
end
