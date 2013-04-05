#
# 执行事件命令的解释器。本类在 Game_System 类
# 与 Game_Event 类的内部使用。
#

class Game_Interpreter
  #
  # 初始化标志
  #
  # depth : 事件的深度
  # main  : 主标志
  #
  def initialize(depth = 0, main = false)
    @depth = depth
    @main = main
    if @depth > 100
      print("调用公用事件超过了限制。")
      exit
    end
    clear
  end
  #
  # 清除
  #
  #
  def clear
    @map_id = 0                       # 启动时的地图 ID
    @original_event_id = 0            # 启动时的事件 ID
    @event_id = 0                     # 事件 ID
    @list = nil                       # 执行内容
    @index = 0                        # 索引
    @message_waiting = false          # 文章信息结束待机中
    @moving_character = nil           # 移动中的人物
    @wait_count = 0                   # 窗口计数
    @child_interpreter = nil          # 子实例
    @branch = {}                      # 分支数据
  end
  #
  # 设置事件
  #
  # list     : 执行内容
  # event_id : 事件 ID
  #
  def setup(list, event_id = 0)
    clear                             # 清除索引的内部状态
    @map_id = $game_map.map_id        # 记忆地图 ID
    @original_event_id = event_id     # 记忆事件 ID
    @event_id = event_id              # 记忆事件 ID
    @list = list                      # 记忆执行内容
    @index = 0                        # 初始化索引
    cancel_menu_call                  # 取消呼出菜单
  end
  #
  # 取消呼出菜单
  #
  # 主角移动中取消按钮被按、呼出菜单画面被预约的状态下
  # 事件启动情况下的对策。
  #
  def cancel_menu_call
    if @main and $game_temp.next_scene == "menu" and $game_temp.menu_beep
      $game_temp.next_scene = nil
      $game_temp.menu_beep = false
    end
  end
  #
  # 执行中判定
  #
  #
  def running?
    return @list != nil
  end
  #
  # 设置启动中事件
  #
  #
  def setup_starting_event
    if $game_map.need_refresh             # 刷新必要的地图
      $game_map.refresh
    end
    if $game_temp.common_event_id > 0     # 如果调用的公共事件被预约的情况下
      setup($data_common_events[$game_temp.common_event_id].list)
      $game_temp.common_event_id = 0
      return
    end
    for event in $game_map.events.values  # 循环 (地图事件)
      if event.starting                   # 如果找到了启动中的事件
        event.clear_starting              # 清除启动中标志
        setup(event.list, event.id)       # 设置事件
        return
      end
    end
    for event in $data_common_events.compact      # 循环(公共事件)
      if event.trigger == 1 and           # 目标的自动执行开关为 ON 的情况下
         $game_switches[event.switch_id] == true  
        setup(event.list)                 # 设置事件
        return
      end
    end
  end
  #
  # 刷新画面
  #
  #
  def update
    loop do
      if $game_map.map_id != @map_id        # 如果地图与事件启动有差异
        @event_id = 0                       # 事件 ID 设置为 0
      end
      if @child_interpreter != nil          # 子注释器存在的情况下
        @child_interpreter.update           # 刷新子注释器
        if @child_interpreter.running?      # 子解释器执行中的情况下
          return                            # 返回
        else                                # 子解释器执行结束的情况下
          @child_interpreter = nil          # 删除字注释器
        end
      end
      if @message_waiting                   # 信息结束待机的情况下
        return
      end
      if @moving_character != nil           # 移动结束待机的情况下
        if @moving_character.move_route_forcing
          return
        end
        @moving_character = nil
      end
      if @wait_count > 0                    # 等待中
        @wait_count -= 1
        return
      end
      if $game_troop.forcing_battler != nil # 如果被强制行动的战斗者存在
        return
      end
      if $game_temp.next_scene != nil       # 各种画面打开的途中
        return
      end
      if @list == nil                       # 执行内容列表为空的情况下
        setup_starting_event if @main       # 设置启动中的事件
        return if @list == nil              # 什么都没有设置的情况下
      end
      return if execute_command == false    # 尝试执行事件列表、返回值为 false 的情况下
      @index += 1                           # 推进索引
    end
  end
  #
  # 角色用itereta(ID)
  #
  # param : 1 以上是 ID、0 是全体
  #
  def iterate_actor_id(param)
    if param == 0       # 全体
      for actor in $game_party.members do yield actor end
    else                # 单体
      actor = $game_actors[param]
      yield actor unless actor == nil
    end
  end
  #
  # 角色用itereta (索引)
  #
  # param : 0 以上是索引、-1 是全体
  #
  def iterate_actor_index(param)
    if param == -1      # 全体
      for actor in $game_party.members do yield actor end
    else                # 单体
      actor = $game_party.members[param]
      yield actor unless actor == nil
    end
  end
  #
  # 敌人用itereta (索引)
  #
  # param : 0 以上是索引、-1 是全体
  #
  def iterate_enemy_index(param)
    if param == -1      # 全体
      for enemy in $game_troop.members do yield enemy end
    else                # 单体
      enemy = $game_troop.members[param]
      yield enemy unless enemy == nil
    end
  end
  #
  # 战斗者用itereta (要考虑全体队伍、全体同伴)
  #
  # param1 : 0 是敌人、1 是角色
  # param2 : 0 以上是索引、-1 是全体
  #
  def iterate_battler(param1, param2)
    if $game_temp.in_battle
      if param1 == 0      # 敌人
        iterate_enemy_index(param2) do |enemy| yield enemy end
      else                # 角色
        iterate_actor_index(param2) do |enemy| yield enemy end
      end
    end
  end
  #
  # 获取画面指令对象
  #
  #
  def screen
    if $game_temp.in_battle
      return $game_troop.screen
    else
      return $game_map.screen
    end
  end
  #
  # 执行事件指令
  #
  #
  def execute_command
    if @index >= @list.size-1
      command_end
      return true
    else
      @params = @list[@index].parameters
      @indent = @list[@index].indent
      case @list[@index].code
      when 101  # 文章的显示
        return command_101
      when 102  # 显示选择项
        return command_102
      when 402  # [**] 的情况下
        return command_402
      when 403  # 取消的情况下
        return command_403
      when 103  # 处理数值输入
        return command_103
      when 111  # 条件分支
        return command_111
      when 411  # 这以外的情况
        return command_411
      when 112  # 循环
        return command_112
      when 413  # 重复上次
        return command_413
      when 113  # 中断循环
        return command_113
      when 115  # 中断事件处理
        return command_115
      when 117  # 公共事件
        return command_117
      when 118  # 标签
        return command_118
      when 119  # 标签跳转
        return command_119
      when 121  # 操作开关
        return command_121
      when 122  # 操作变量
        return command_122
      when 123  # 操作独立开关
        return command_123
      when 124  # 操作计时器
        return command_124
      when 125  # 增减金钱
        return command_125
      when 126  # 增减物品
        return command_126
      when 127  # 增减武器
        return command_127
      when 128  # 增减防具
        return command_128
      when 129  # 替换角色
        return command_129
      when 132  # 更改战斗 BGM
        return command_132
      when 133  # 更改结束 ME
        return command_133
      when 134  # 更改禁止保存
        return command_134
      when 135  # 更改禁止菜单
        return command_135
      when 136  # 更改禁止遇敌
        return command_136
      when 201  # 場所移動
        return command_201
      when 202  # 设置交通工具位置
        return command_202
      when 203  # 设置事件位置
        return command_203
      when 204  # 地图滚动
        return command_204
      when 205  # 设定移动路线
        return command_205
      when 206  # 交通工具乘降
        return command_206
      when 211  # 更改透明状态
        return command_211
      when 212  # 显示动画
        return command_212
      when 213  # 显示表情动画
        return command_213
      when 214  # 暂时消除事件
        return command_214
      when 221  # 淡出画面
        return command_221
      when 222  # 淡入画面
        return command_222
      when 223  # 更改画面色调
        return command_223
      when 224  # 画面闪烁
        return command_224
      when 225  # 画面震动
        return command_225
      when 230  # 等待
        return command_230
      when 231  # 显示图片
        return command_231
      when 232  # 移动图片
        return command_232
      when 233  # 旋转图片
        return command_233
      when 234  # 更改图片色调
        return command_234
      when 235  # 消失图片
        return command_235
      when 236  # 设置天气
        return command_236
      when 241  # 演奏BGM
        return command_241
      when 242  # 淡出BGM
        return command_242
      when 245  # 演奏BGS
        return command_245
      when 246  # 淡出BGS
        return command_246
      when 249  # 演奏ME
        return command_249
      when 250  # 演奏SE
        return command_250
      when 251  # 停止SE
        return command_251
      when 301  # 战斗处理
        return command_301
      when 601  # 胜利的情况
        return command_601
      when 602  # 逃跑的情况
        return command_602
      when 603  # 失败的情况
        return command_603
      when 302  # 商店的处理
        return command_302
      when 303  # 名称输入的处理
        return command_303
      when 311  # 增减 HP
        return command_311
      when 312  # 增减 MP
        return command_312
      when 313  # 更改状态
        return command_313
      when 314  # 全回复
        return command_314
      when 315  # 增减 经验
        return command_315
      when 316  # 増減 等级
        return command_316
      when 317  # 増減 能力值
        return command_317
      when 318  # 增减特技
        return command_318
      when 319  # 变更装备
        return command_319
      when 320  # 更改角色名字
        return command_320
      when 321  # 更改角色职业
        return command_321
      when 322  # 更改角色图形
        return command_322
      when 323  # 更改交通工具图形
        return command_323
      when 331  # 増減敌人的 HP
        return command_331
      when 332  # 増減敌人的 MP
        return command_332
      when 333  # 更改敌人的状态
        return command_333
      when 334  # 敌人全回复
        return command_334
      when 335  # 敌人出现
        return command_335
      when 336  # 敌人变身
        return command_336
      when 337  # 显示战斗动画
        return command_337
      when 339  # 强制战斗行动
        return command_339
      when 340  # 中断战斗
        return command_340
      when 351  # 调用菜单画面
        return command_351
      when 352  # 调用存档画面
        return command_352
      when 353  # 游戏结束
        return command_353
      when 354  # 返回标题画面
        return command_354
      when 355  # 脚本
        return command_355
      else      # 其它
        return true
      end
    end
  end
  #
  # 事件结束
  #
  #
  def command_end
    @list = nil                             # 清除执行内容列表
    if @main and @event_id > 0              # 主地图事件与事件 ID 有效的情况下
      $game_map.events[@event_id].unlock    # 解除事件锁定
    end
  end
  #
  # 指令跳转
  #
  #
  def command_skip
    while @list[@index+1].indent > @indent  # 下一个事件命令是同等级的缩进的情况下
      @index += 1                           # 推进索引
    end
  end
  #
  # 获取角色
  #
  # param : -1 是角色、0 是本事件、除此以外是 事件 ID
  #
  def get_character(param)
    case param
    when -1   # 角色
      return $game_player
    when 0    # 本事件
      events = $game_map.events
      return events == nil ? nil : events[@event_id]
    else      # 特定的事件
      events = $game_map.events
      return events == nil ? nil : events[param]
    end
  end
  #
  # 计算操作的值
  #
  # operation    : 操作
  # operand_type : 操作数类型 (0:恒量 1:变量)
  # operand      : 操作数 (数值是变量 ID)
  #
  def operate_value(operation, operand_type, operand)
    if operand_type == 0
      value = operand
    else
      value = $game_variables[operand]
    end
    if operation == 1
      value = -value
    end
    return value
  end
  #
  # 显示文章
  #
  #
  def command_101
    unless $game_message.busy
      $game_message.face_name = @params[0]
      $game_message.face_index = @params[1]
      $game_message.background = @params[2]
      $game_message.position = @params[3]
      @index += 1
      while @list[@index].code == 401       # 文章数据
        $game_message.texts.push(@list[@index].parameters[0])
        @index += 1
      end
      if @list[@index].code == 102          # 显示选择项
        setup_choices(@list[@index].parameters)
      elsif @list[@index].code == 103       # 处理数值输入
        setup_num_input(@list[@index].parameters)
      end
      set_message_waiting                   # 文章待机状态
    end
    return false
  end
  #
  # 设置文章待机标记与call back
  #
  #
  def set_message_waiting
    @message_waiting = true
    $game_message.main_proc = Proc.new { @message_waiting = false }
  end
  #
  # 显示选择项
  #
  #
  def command_102
    unless $game_message.busy
      setup_choices(@params)                # 设置选择项
      set_message_waiting                   # 文章待机状态
    end
    return false
  end
  #
  # 设置选择项
  #
  #
  def setup_choices(params)
    if $game_message.texts.size <= 4 - params[0].size
      $game_message.choice_start = $game_message.texts.size
      $game_message.choice_max = params[0].size
      for s in params[0]
        $game_message.texts.push(s)
      end
      $game_message.choice_cancel_type = params[1]
      $game_message.choice_proc = Proc.new { |n| @branch[@indent] = n }
      @index += 1
    end
  end
  #
  # [**] 的情况下
  #
  #
  def command_402
    if @branch[@indent] == @params[0]       # 如果符合的选择项被选择
      @branch.delete(@indent)               # 删除分支数据
      return true                           # 継続
    else                                    # 不符合条件的情况下
      return command_skip                   # 指令跳转
    end
  end
  #
  # 取消的情况下
  #
  #
  def command_403
    if @branch[@indent] == 4                # 如果选择了选择项取消
      @branch.delete(@indent)               # 删除分支数据
      return true                           # 继续
    else                                    # 不符合条件的情况下
      return command_skip                   # 指令跳转
    end
  end
  #
  # 处理数值输入
  #
  #
  def command_103
    unless $game_message.busy
      setup_num_input(@params)              # 设置数值输入
      set_message_waiting                   # 文章待机状态
    end
    return false
  end
  #
  # 设置数值输入
  #
  #
  def setup_num_input(params)
    if $game_message.texts.size < 4
      $game_message.num_input_variable_id = params[0]
      $game_message.num_input_digits_max = params[1]
      @index += 1
    end
  end
  #
  # 条件分歧
  #
  #
  def command_111
    result = false
    case @params[0]
    when 0  # 开关
      result = ($game_switches[@params[1]] == (@params[2] == 0))
    when 1  # 变量
      value1 = $game_variables[@params[1]]
      if @params[2] == 0
        value2 = @params[3]
      else
        value2 = $game_variables[@params[3]]
      end
      case @params[4]
      when 0  # 等于
        result = (value1 == value2)
      when 1  # 以上
        result = (value1 >= value2)
      when 2  # 以下
        result = (value1 <= value2)
      when 3  # 超过
        result = (value1 > value2)
      when 4  # 未满
        result = (value1 < value2)
      when 5  # 以外
        result = (value1 != value2)
      end
    when 2  # 独立开关
      if @original_event_id > 0
        key = [@map_id, @original_event_id, @params[1]]
        if @params[2] == 0
          result = ($game_self_switches[key] == true)
        else
          result = ($game_self_switches[key] != true)
        end
      end
    when 3  # 计时器
      if $game_system.timer_working
        sec = $game_system.timer / Graphics.frame_rate
        if @params[2] == 0
          result = (sec >= @params[1])
        else
          result = (sec <= @params[1])
        end
      end
    when 4  # 角色
      actor = $game_actors[@params[1]]
      if actor != nil
        case @params[2]
        when 0  # 同伴
          result = ($game_party.members.include?(actor))
        when 1  # 名称
          result = (actor.name == @params[3])
        when 2  # 特技
          result = (actor.skill_learn?($data_skills[@params[3]]))
        when 3  # 武器
          result = (actor.weapons.include?($data_weapons[@params[3]]))
        when 4  # 防具
          result = (actor.armors.include?($data_armors[@params[3]]))
        when 5  # 状态
          result = (actor.state?(@params[3]))
        end
      end
    when 5  # 敌人
      enemy = $game_troop.members[@params[1]]
      if enemy != nil
        case @params[2]
        when 0  # 出现
          result = (enemy.exist?)
        when 1  # 状态
          result = (enemy.state?(@params[3]))
        end
      end
    when 6  # 角色
      character = get_character(@params[1])
      if character != nil
        result = (character.direction == @params[2])
      end
    when 7  # 金钱
      if @params[2] == 0
        result = ($game_party.gold >= @params[1])
      else
        result = ($game_party.gold <= @params[1])
      end
    when 8  # 物品
      result = $game_party.has_item?($data_items[@params[1]])
    when 9  # 武器
      result = $game_party.has_item?($data_weapons[@params[1]], @params[2])
    when 10  # 防具
      result = $game_party.has_item?($data_armors[@params[1]], @params[2])
    when 11  # 按钮
      result = Input.press?(@params[1])
    when 12  # 活动块
      result = eval(@params[1])
    when 13  # 交通工具
      result = ($game_player.vehicle_type == @params[1])
    end
    @branch[@indent] = result     # 判断结果保存在 hash 中
    if @branch[@indent] == true
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #
  # 这以外的情况
  #
  #
  def command_411
    if @branch[@indent] == false
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #
  # 循环
  #
  #
  def command_112
    return true
  end
  #
  # 重复上次
  #
  #
  def command_413
    begin
      @index -= 1
    end until @list[@index].indent == @indent
    return true
  end
  #
  # 中断循环
  #
  #
  def command_113
    loop do
      @index += 1
      if @index >= @list.size-1
        return true
      end
      if @list[@index].code == 413 and    # 本事件命令为 [重复上次]
         @list[@index].indent < @indent   # 缩进浅的情况下
        return true
      end
    end
  end
  #
  # 中断事件处理
  #
  #
  def command_115
    command_end
    return true
  end
  #
  # 公共事件
  #
  #
  def command_117
    common_event = $data_common_events[@params[0]]
    if common_event != nil
      @child_interpreter = Game_Interpreter.new(@depth + 1)
      @child_interpreter.setup(common_event.list, @event_id)
    end
    return true
  end
  #
  # 标签
  #
  #
  def command_118
    return true
  end
  #
  # 标签跳转
  #
  #
  def command_119
    label_name = @params[0]
    for i in 0...@list.size
      if @list[i].code == 118 and @list[i].parameters[0] == label_name
        @index = i
        return true
      end
    end
    return true
  end
  #
  # 开关操作
  #
  #
  def command_121
    for i in @params[0] .. @params[1]   # 循环全部操作
      $game_switches[i] = (@params[2] == 0)
    end
    $game_map.need_refresh = true
    return true
  end
  #
  # 变量操作
  #
  #
  def command_122
    value = 0
    case @params[3]  # 操作数
    when 0  # 恒量
      value = @params[4]
    when 1  # 变量
      value = $game_variables[@params[4]]
    when 2  # 随机数
      value = @params[4] + rand(@params[5] - @params[4] + 1)
    when 3  # 物品
      value = $game_party.item_number($data_items[@params[4]])
    when 4  # 角色
      actor = $game_actors[@params[4]]
      if actor != nil
        case @params[5]
        when 0  # 等级
          value = actor.level
        when 1  # 经验
          value = actor.exp
        when 2  # HP
          value = actor.hp
        when 3  # MP
          value = actor.mp
        when 4  # MaxHP
          value = actor.maxhp
        when 5  # MaxMP
          value = actor.maxmp
        when 6  # 攻击力
          value = actor.atk
        when 7  # 防御力
          value = actor.def
        when 8  # 精神力
          value = actor.spi
        when 9  # 敏捷性
          value = actor.agi
        end
      end
    when 5  # 敌人
      enemy = $game_troop.members[@params[4]]
      if enemy != nil
        case @params[5]
        when 0  # HP
          value = enemy.hp
        when 1  # MP
          value = enemy.mp
        when 2  # MaxHP
          value = enemy.maxhp
        when 3  # MaxMP
          value = enemy.maxmp
        when 4  # 攻击力
          value = enemy.atk
        when 5  # 防御力
          value = enemy.def
        when 6  # 精神力
          value = enemy.spi
        when 7  # 敏捷性
          value = enemy.agi
        end
      end
    when 6  # 角色
      character = get_character(@params[4])
      if character != nil
        case @params[5]
        when 0  # X 坐标
          value = character.x
        when 1  # Y 坐标
          value = character.y
        when 2  # 朝向
          value = character.direction
        when 3  # 画面 X 坐标
          value = character.screen_x
        when 4  # 画面 Y 坐标
          value = character.screen_y
        end
      end
    when 7  # 其它
      case @params[4]
      when 0  # 地图 ID
        value = $game_map.map_id
      when 1  # 同伴人数
        value = $game_party.members.size
      when 2  # 金钱
        value = $game_party.gold
      when 3  # 步数
        value = $game_party.steps
      when 4  # 游戏时间
        value = Graphics.frame_count / Graphics.frame_rate
      when 5  # 计时器
        value = $game_system.timer / Graphics.frame_rate
      when 6  # 存档次数
        value = $game_system.save_count
      end
    end
    for i in @params[0] .. @params[1]   # 循环全部操作
      case @params[2]  # 操作分支
      when 0  # 代入
        $game_variables[i] = value
      when 1  # 加法
        $game_variables[i] += value
      when 2  # 减法
        $game_variables[i] -= value
      when 3  # 乘法
        $game_variables[i] *= value
      when 4  # 除法
        $game_variables[i] /= value if value != 0
      when 5  # 剰余
        $game_variables[i] %= value if value != 0
      end
      if $game_variables[i] > 99999999    # 检查上限
        $game_variables[i] = 99999999
      end
      if $game_variables[i] < -99999999   # 检查下限
        $game_variables[i] = -99999999
      end
    end
    $game_map.need_refresh = true
    return true
  end
  #
  # 独立开关操作
  #
  #
  def command_123
    if @original_event_id > 0
      key = [@map_id, @original_event_id, @params[0]]
      $game_self_switches[key] = (@params[1] == 0)
    end
    $game_map.need_refresh = true
    return true
  end
  #
  # 计时器操作
  #
  #
  def command_124
    if @params[0] == 0  # 始動
      $game_system.timer = @params[1] * Graphics.frame_rate
      $game_system.timer_working = true
    end
    if @params[0] == 1  # 停止
      $game_system.timer_working = false
    end
    return true
  end
  #
  # 增减金钱
  #
  #
  def command_125
    value = operate_value(@params[0], @params[1], @params[2])
    $game_party.gain_gold(value)
    return true
  end
  #
  # 增减物品
  #
  #
  def command_126
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_items[@params[0]], value)
    $game_map.need_refresh = true
    return true
  end
  #
  # 增减武器
  #
  #
  def command_127
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_weapons[@params[0]], value, @params[4])
    return true
  end
  #
  # 增减防具
  #
  #
  def command_128
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_armors[@params[0]], value, @params[4])
    return true
  end
  #
  # 角色的替换
  #
  #
  def command_129
    actor = $game_actors[@params[0]]
    if actor != nil
      if @params[1] == 0    # 加入
        if @params[2] == 1  # 初始化
          $game_actors[@params[0]].setup(@params[0])
        end
        $game_party.add_actor(@params[0])
      else                  # 离开
        $game_party.remove_actor(@params[0])
      end
      $game_map.need_refresh = true
    end
    return true
  end
  #
  # 更改战斗 BGM
  #
  #
  def command_132
    $game_system.battle_bgm = @params[0]
    return true
  end
  #
  # 更改战斗结束的 ME
  #
  #
  def command_133
    $game_system.battle_end_me = @params[0]
    return true
  end
  #
  # 更改禁止存档
  #
  #
  def command_134
    $game_system.save_disabled = (@params[0] == 0)
    return true
  end
  #
  # 更改禁止菜单
  #
  #
  def command_135
    $game_system.menu_disabled = (@params[0] == 0)
    return true
  end
  #
  # 更改禁止遇敌
  #
  #
  def command_136
    $game_system.encounter_disabled = (@params[0] == 0)
    $game_player.make_encounter_count
    return true
  end
  #
  # 场所移动
  #
  #
  def command_201
    return true if $game_temp.in_battle
    if $game_player.transfer? or            # 场所移动中
       $game_message.visible                # 文章显示中
      return false
    end
    if @params[0] == 0                      # 直接指定
      map_id = @params[1]
      x = @params[2]
      y = @params[3]
      direction = @params[4]
    else                                    # 变量指定
      map_id = $game_variables[@params[1]]
      x = $game_variables[@params[2]]
      y = $game_variables[@params[3]]
      direction = @params[4]
    end
    $game_player.reserve_transfer(map_id, x, y, direction)
    @index += 1
    return false
  end
  #
  # 设置交通工具位置
  #
  #
  def command_202
    if @params[1] == 0                      # 直接指定
      map_id = @params[2]
      x = @params[3]
      y = @params[4]
    else                                    # 变量指定
      map_id = $game_variables[@params[2]]
      x = $game_variables[@params[3]]
      y = $game_variables[@params[4]]
    end
    if @params[0] == 0                      # 小型船
      $game_map.boat.set_location(map_id, x, y)
    elsif @params[0] == 1                   # 大型船
      $game_map.ship.set_location(map_id, x, y)
    else                                    # 飞行船
      $game_map.airship.set_location(map_id, x, y)
    end
    return true
  end
  #
  # 设置事件位置
  #
  #
  def command_203
    character = get_character(@params[0])
    if character != nil
      if @params[1] == 0                      # 直接指定
        character.moveto(@params[2], @params[3])
      elsif @params[1] == 1                   # 变量指定
        new_x = $game_variables[@params[2]]
        new_y = $game_variables[@params[3]]
        character.moveto(new_x, new_y)
      else                                    # 与其它事件交换
        old_x = character.x
        old_y = character.y
        character2 = get_character(@params[2])
        if character2 != nil
          character.moveto(character2.x, character2.y)
          character2.moveto(old_x, old_y)
        end
      end
      case @params[4]   # 设置角色朝向
      when 8  # 上
        character.turn_up
      when 6  # 右
        character.turn_right
      when 2  # 下
        character.turn_down
      when 4  # 左
        character.turn_left
      end
    end
    return true
  end
  #
  # 地图的滚动
  #
  #
  def command_204
    return true if $game_temp.in_battle
    return false if $game_map.scrolling?
    $game_map.start_scroll(@params[0], @params[1], @params[2])
    return true
  end
  #
  # 设置移动路线
  #
  #
  def command_205
    if $game_map.need_refresh
      $game_map.refresh
    end
    character = get_character(@params[0])
    if character != nil
      character.force_move_route(@params[1])
      @moving_character = character if @params[1].wait
    end
    return true
  end
  #
  # 交通工具乘降
  #
  #
  def command_206
    $game_player.get_on_off_vehicle
    return true
  end
  #
  # 更改透明状态
  #
  #
  def command_211
    $game_player.transparent = (@params[0] == 0)
    return true
  end
  #
  # 显示动画
  #
  #
  def command_212
    character = get_character(@params[0])
    if character != nil
      character.animation_id = @params[1]
    end
    return true
  end
  #
  # 显示表情动画
  #
  #
  def command_213
    character = get_character(@params[0])
    if character != nil
      character.balloon_id = @params[1]
    end
    return true
  end
  #
  # 暂时消除事件
  #
  #
  def command_214
    if @event_id > 0
      $game_map.events[@event_id].erase
    end
    @index += 1
    return false
  end
  #
  # 淡出画面
  #
  #
  def command_221
    if $game_message.visible
      return false
    else
      screen.start_fadeout(30)
      @wait_count = 30
      return true
    end
  end
  #
  # 淡入画面
  #
  #
  def command_222
    if $game_message.visible
      return false
    else
      screen.start_fadein(30)
      @wait_count = 30
      return true
    end
  end
  #
  # 更改画面色调
  #
  #
  def command_223
    screen.start_tone_change(@params[0], @params[1])
    @wait_count = @params[1] if @params[2]
    return true
  end
  #
  # 画面闪烁
  #
  #
  def command_224
    screen.start_flash(@params[0], @params[1])
    @wait_count = @params[1] if @params[2]
    return true
  end
  #
  # 画面震动
  #
  #
  def command_225
    screen.start_shake(@params[0], @params[1], @params[2])
    @wait_count = @params[2] if @params[3]
    return true
  end
  #
  # 等待
  #
  #
  def command_230
    @wait_count = @params[0]
    return true
  end
  #
  # 显示图片
  #
  #
  def command_231
    if @params[3] == 0    # 直接指定
      x = @params[4]
      y = @params[5]
    else                  # 变量指定
      x = $game_variables[@params[4]]
      y = $game_variables[@params[5]]
    end
    screen.pictures[@params[0]].show(@params[1], @params[2],
      x, y, @params[6], @params[7], @params[8], @params[9])
    return true
  end
  #
  # 移动图片
  #
  #
  def command_232
    if @params[3] == 0    # 直接指定
      x = @params[4]
      y = @params[5]
    else                  # 变量指定
      x = $game_variables[@params[4]]
      y = $game_variables[@params[5]]
    end
    screen.pictures[@params[0]].move(@params[2], x, y, @params[6],
      @params[7], @params[8], @params[9], @params[10])
    @wait_count = @params[10] if @params[11]
    return true
  end
  #
  # 旋转图片
  #
  #
  def command_233
    screen.pictures[@params[0]].rotate(@params[1])
    return true
  end
  #
  # 更改图片色调
  #
  #
  def command_234
    screen.pictures[@params[0]].start_tone_change(@params[1], @params[2])
    @wait_count = @params[2] if @params[3]
    return true
  end
  #
  # 消失图片
  #
  #
  def command_235
    screen.pictures[@params[0]].erase
    return true
  end
  #
  # 天气设置
  #
  #
  def command_236
    return true if $game_temp.in_battle
    screen.weather(@params[0], @params[1], @params[2])
    @wait_count = @params[2] if @params[3]
    return true
  end
  #
  # 演奏 BGM
  #
  #
  def command_241
    @params[0].play
    return true
  end
  #
  # 淡出 BGM 
  #
  #
  def command_242
    RPG::BGM.fade(@params[0] * 1000)
    return true
  end
  #
  # 演奏 BGS
  #
  #
  def command_245
    @params[0].play
    return true
  end
  #
  # 淡出 BGS
  #
  #
  def command_246
    RPG::BGS.fade(@params[0] * 1000)
    return true
  end
  #
  # 演奏 ME
  #
  #
  def command_249
    @params[0].play
    return true
  end
  #
  # 演奏 SE
  #
  #
  def command_250
    @params[0].play
    return true
  end
  #
  # 停止 SE
  #
  #
  def command_251
    RPG::SE.stop
    return true
  end
  #
  # 战斗处理
  #
  #
  def command_301
    return true if $game_temp.in_battle
    if @params[0] == 0                      # 直接指定
      troop_id = @params[1]
    else                                    # 变量指定
      troop_id = $game_variables[@params[1]]
    end
    if $data_troops[troop_id] != nil
      $game_troop.setup(troop_id)
      $game_troop.can_escape = @params[2]
      $game_troop.can_lose = @params[3]
      $game_temp.battle_proc = Proc.new { |n| @branch[@indent] = n }
      $game_temp.next_scene = "battle"
    end
    @index += 1
    return false
  end
  #
  # 胜利的情况下
  #
  #
  def command_601
    if @branch[@indent] == 0
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #
  # 逃跑的情况下
  #
  #
  def command_602
    if @branch[@indent] == 1
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #
  # 失败的情况下
  #
  #
  def command_603
    if @branch[@indent] == 2
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #
  # 商店的处理
  #
  #
  def command_302
    $game_temp.next_scene = "shop"
    $game_temp.shop_goods = [@params]
    $game_temp.shop_purchase_only = @params[2]
    loop do
      @index += 1
      if @list[@index].code == 605          # 商店 2 行以下
        $game_temp.shop_goods.push(@list[@index].parameters)
      else
        return false
      end
    end
  end
  #
  # 名称输入处理
  #
  #
  def command_303
    if $data_actors[@params[0]] != nil
      $game_temp.next_scene = "name"
      $game_temp.name_actor_id = @params[0]
      $game_temp.name_max_char = @params[1]
    end
    @index += 1
    return false
  end
  #
  # 增减 HP
  #
  #
  def command_311
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      next if actor.dead?
      if @params[4] == false and actor.hp + value <= 0
        actor.hp = 1    # 如果战斗不能没被准许为1
      else
        actor.hp += value
      end
      actor.perform_collapse
    end
    if $game_party.all_dead?
      $game_temp.next_scene = "gameover"
    end
    return true
  end
  #
  # 增减 MP
  #
  #
  def command_312
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      actor.mp += value
    end
    return true
  end
  #
  # 更改状态
  #
  #
  def command_313
    iterate_actor_id(@params[0]) do |actor|
      if @params[1] == 0
        actor.add_state(@params[2])
        actor.perform_collapse
      else
        actor.remove_state(@params[2])
      end
    end
    return true
  end
  #
  # 完全回复
  #
  #
  def command_314
    iterate_actor_id(@params[0]) do |actor|
      actor.recover_all
    end
    return true
  end
  #
  # 增减经验
  #
  #
  def command_315
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      actor.change_exp(actor.exp + value, @params[4])
    end
    return true
  end
  #
  # 增减等级
  #
  #
  def command_316
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      actor.change_level(actor.level + value, @params[4])
    end
    return true
  end
  #
  # 增减能力值
  #
  #
  def command_317
    value = operate_value(@params[2], @params[3], @params[4])
    actor = $game_actors[@params[0]]
    if actor != nil
      case @params[1]
      when 0  # MaxHP
        actor.maxhp += value
      when 1  # MaxMP
        actor.maxmp += value
      when 2  # 攻击力
        actor.atk += value
      when 3  # 防御力
        actor.def += value
      when 4  # 精神力
        actor.spi += value
      when 5  # 敏捷性
        actor.agi += value
      end
    end
    return true
  end
  #
  # 增减特技
  #
  #
  def command_318
    actor = $game_actors[@params[0]]
    if actor != nil
      if @params[1] == 0
        actor.learn_skill(@params[2])
      else
        actor.forget_skill(@params[2])
      end
    end
    return true
  end
  #
  # 变更装备
  #
  #
  def command_319
    actor = $game_actors[@params[0]]
    if actor != nil
      actor.change_equip_by_id(@params[1], @params[2])
    end
    return true
  end
  #
  # 更改角色的名字
  #
  #
  def command_320
    actor = $game_actors[@params[0]]
    if actor != nil
      actor.name = @params[1]
    end
    return true
  end
  #
  # 更改角色的职业
  #
  #
  def command_321
    actor = $game_actors[@params[0]]
    if actor != nil and $data_classes[@params[1]] != nil
      actor.class_id = @params[1]
    end
    return true
  end
  #
  # 更改角色的图形
  #
  #
  def command_322
    actor = $game_actors[@params[0]]
    if actor != nil
      actor.set_graphic(@params[1], @params[2], @params[3], @params[4])
    end
    $game_player.refresh
    return true
  end
  #
  # 更改交通工具的图形
  #
  #
  def command_323
    if @params[0] == 0                      # 小型船
      $game_map.boat.set_graphic(@params[1], @params[2])
    elsif @params[0] == 1                   # 大型船
      $game_map.ship.set_graphic(@params[1], @params[2])
    else                                    # 飞行船
      $game_map.airship.set_graphic(@params[1], @params[2])
    end
    return true
  end
  #
  # 增减敌人的 HP
  #
  #
  def command_331
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      if enemy.hp > 0
        if @params[4] == false and enemy.hp + value <= 0
          enemy.hp = 1    # 如果战斗不能没被准许为1
        else
          enemy.hp += value
        end
        enemy.perform_collapse
      end
    end
    return true
  end
  #
  # 增减敌人的 MP
  #
  #
  def command_332
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.mp += value
    end
    return true
  end
  #
  # 更改敌人的状态
  #
  #
  def command_333
    iterate_enemy_index(@params[0]) do |enemy|
      if @params[2] == 1                    # 变更战斗不能
        enemy.immortal = false              # 清除不死身标志
      end
      if @params[1] == 0
        enemy.add_state(@params[2])
        enemy.perform_collapse
      else
        enemy.remove_state(@params[2])
      end
    end
    return true
  end
  #
  # 敌人的全回复
  #
  #
  def command_334
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.recover_all
    end
    return true
  end
  #
  # 敌人出现
  #
  #
  def command_335
    enemy = $game_troop.members[@params[0]]
    if enemy != nil and enemy.hidden
      enemy.hidden = false
      $game_troop.make_unique_names
    end
    return true
  end
  #
  # 敌人变身
  #
  #
  def command_336
    enemy = $game_troop.members[@params[0]]
    if enemy != nil
      enemy.transform(@params[1])
      $game_troop.make_unique_names
    end
    return true
  end
  #
  # 显示战斗动画
  #
  #
  def command_337
    iterate_battler(0, @params[0]) do |battler|
      next unless battler.exist?
      battler.animation_id = @params[1]
    end
    return true
  end
  #
  # 强制战斗行动
  #
  #
  def command_339
    iterate_battler(@params[0], @params[1]) do |battler|
      next unless battler.exist?
      battler.action.kind = @params[2]
      if battler.action.kind == 0
        battler.action.basic = @params[3]
      else
        battler.action.skill_id = @params[3]
      end
      if @params[4] == -2                   # 最后目标
        battler.action.decide_last_target
      elsif @params[4] == -1                # 随机目标
        battler.action.decide_random_target
      elsif @params[4] >= 0                 # 指定目标
        battler.action.target_index = @params[4]
      end
      battler.action.forcing = true
      $game_troop.forcing_battler = battler
      @index += 1
      return false
    end
    return true
  end
  #
  # 战斗中断
  #
  #
  def command_340
    $game_temp.next_scene = "map"
    @index += 1
    return false
  end
  #
  # 调用菜单画面
  #
  #
  def command_351
    $game_temp.next_scene = "menu"
    $game_temp.menu_beep = false
    @index += 1
    return false
  end
  #
  # 调用存档画面
  #
  #
  def command_352
    $game_temp.next_scene = "save"
    @index += 1
    return false
  end
  #
  # 游戏结束
  #
  #
  def command_353
    $game_temp.next_scene = "gameover"
    return false
  end
  #
  # 返回标题画面
  #
  #
  def command_354
    $game_temp.next_scene = "title"
    return false
  end
  #
  # 脚本
  #
  #
  def command_355
    script = @list[@index].parameters[0] + "\n"
    loop do
      if @list[@index+1].code == 655        # 脚本 2 行以上的情况下
        script += @list[@index+1].parameters[0] + "\n"
      else
        break
      end
      @index += 1
    end
    eval(script)
    return true
  end
end
