#
# 执行事件命令的解释器。本类在 Game_System 类
# 与 Game_Event 类的内部使用。
#

class Interpreter
  #
  # 初始化标志
  #
  # depth : 事件的深度
  # main  : 主标志
  #
  def initialize(depth = 0, main = false)
    @depth = depth
    @main = main
    # 深度超过 100 级
    if depth > 100
      print("调用公用事件超过了限制。")
      exit
    end
    # 清除注释器的内部状态
    clear
  end
  #
  # 清除
  #
  #
  def clear
    @map_id = 0                       # 启动时的地图 ID
    @event_id = 0                     # 事件 ID
    @message_waiting = false          # 信息结束后待机中
    @move_route_waiting = false       # 移动结束后待机中
    @button_input_variable_id = 0     # 输入按钮 变量 ID
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
  def setup(list, event_id)
    # 清除注释器的内部状态
    clear
    # 记忆地图 ID
    @map_id = $game_map.map_id
    # 记忆事件 ID
    @event_id = event_id
    # 记忆执行内容
    @list = list
    # 初始化索引
    @index = 0
    # 清除分支数据用复述
    @branch.clear
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
    # 刷新必要的地图
    if $game_map.need_refresh
      $game_map.refresh
    end
    # 如果调用的公共事件被预约的情况下
    if $game_temp.common_event_id > 0
      # 设置事件
      setup($data_common_events[$game_temp.common_event_id].list, 0)
      # 解除预约
      $game_temp.common_event_id = 0
      return
    end
    # 循环 (地图事件)
    for event in $game_map.events.values
      # 如果找到了启动中的事件
      if event.starting
        # 如果不是自动执行
        if event.trigger < 3
          # 清除启动中标志
          event.clear_starting
          # 锁定
          event.lock
        end
        # 设置事件
        setup(event.list, event.id)
        return
      end
    end
    # 循环(公共事件)
    for common_event in $data_common_events.compact
      # 目标的自动执行开关为 ON 的情况下
      if common_event.trigger == 1 and
         $game_switches[common_event.switch_id] == true
        # 设置事件
        setup(common_event.list, 0)
        return
      end
    end
  end
  #
  # 刷新画面
  #
  #
  def update
    # 初始化循环计数
    @loop_count = 0
    # 循环
    loop do
      # 循环计数加 1
      @loop_count += 1
      # 如果执行了 100 个事件指令
      if @loop_count > 100
        # 为了防止系统崩溃、调用 Graphics.update
        Graphics.update
        @loop_count = 0
      end
      # 如果地图与事件启动有差异
      if $game_map.map_id != @map_id
        # 事件 ID 设置为 0
        @event_id = 0
      end
      # 子注释器存在的情况下
      if @child_interpreter != nil
        # 刷新子注释器
        @child_interpreter.update
        # 子注释器执行结束的情况下
        unless @child_interpreter.running?
          # 删除字注释器
          @child_interpreter = nil
        end
        # 如果子注释器还存在
        if @child_interpreter != nil
          return
        end
      end
      # 信息结束待机的情况下
      if @message_waiting
        return
      end
      # 移动结束待机的情况下
      if @move_route_waiting
        # 强制主角移动路线的情况下
        if $game_player.move_route_forcing
          return
        end
        # 循环 (地图事件)
        for event in $game_map.events.values
          # 本事件为强制移动路线的情况下
          if event.move_route_forcing
            return
          end
        end
        # 清除移动结束待机中的标志
        @move_route_waiting = false
      end
      # 输入按钮待机中的情况下
      if @button_input_variable_id > 0
        # 执行按钮输入处理
        input_button
        return
      end
      # 等待中的情况下
      if @wait_count > 0
        # 减少等待计数
        @wait_count -= 1
        return
      end
      # 如果被强制行动的战斗者存在
      if $game_temp.forcing_battler != nil
        return
      end
      # 如果各画面的调用标志已经被设置
      if $game_temp.battle_calling or
         $game_temp.shop_calling or
         $game_temp.name_calling or
         $game_temp.menu_calling or
         $game_temp.save_calling or
         $game_temp.gameover
        return
      end
      # 执行内容列表为空的情况下
      if @list == nil
        # 主地图事件的情况下
        if @main
          # 设置启动中的事件
          setup_starting_event
        end
        # 什么都没有设置的情况下
        if @list == nil
          return
        end
      end
      # 尝试执行事件列表、返回值为 false 的情况下
      if execute_command == false
        return
      end
      # 推进索引
      @index += 1
    end
  end
  #
  # 输入按钮
  #
  #
  def input_button
    # 判定按下的按钮
    n = 0
    for i in 1..18
      if Input.trigger?(i)
        n = i
      end
    end
    # 按下按钮的情况下
    if n > 0
      # 更改变量值
      $game_variables[@button_input_variable_id] = n
      $game_map.need_refresh = true
      # 输入按键结束
      @button_input_variable_id = 0
    end
  end
  #
  # 设置选择项
  #
  #
  def setup_choices(parameters)
    # choice_max 为设置选择项的项目数
    $game_temp.choice_max = parameters[0].size
    # message_text 为设置选择项
    for text in parameters[0]
      $game_temp.message_text += text + "\n"
    end
    # 设置取消的情况的处理
    $game_temp.choice_cancel_type = parameters[1]
    # 返回调用设置
    current_indent = @list[@index].indent
    $game_temp.choice_proc = Proc.new { |n| @branch[current_indent] = n }
  end
  #
  # 角色用 itereta (考虑全体同伴)
  #
  # parameter : 1 以上为 ID、0 为全体
  #
  def iterate_actor(parameter)
    # 全体同伴的情况下
    if parameter == 0
      # 同伴全体循环
      for actor in $game_party.actors
        # 评价块
        yield actor
      end
    # 单体角色的情况下
    else
      # 获取角色
      actor = $game_actors[parameter]
      # 获取角色
      yield actor if actor != nil
    end
  end
  #
  # 敌人用 itereta (考虑队伍全体)
  #
  # parameter : 0 为索引、-1 为全体
  #
  def iterate_enemy(parameter)
    # 队伍全体的情况下
    if parameter == -1
      # 队伍全体循环
      for enemy in $game_troop.enemies
        # 评价块
        yield enemy
      end
    # 敌人单体的情况下
    else
      # 获取敌人
      enemy = $game_troop.enemies[parameter]
      # 评价块
      yield enemy if enemy != nil
    end
  end
  #
  # 战斗者用 itereta (要考虑全体队伍、全体同伴)
  #
  # parameter1 : 0 为敌人、1 为角色
  # parameter2 : 0 以上为索引、-1 为全体
  #
  def iterate_battler(parameter1, parameter2)
    # 敌人的情况下
    if parameter1 == 0
      # 调用敌人的 itereta
      iterate_enemy(parameter2) do |enemy|
        yield enemy
      end
    # 角色的情况下
    else
      # 全体同伴的情况下
      if parameter2 == -1
        # 同伴全体循环
        for actor in $game_party.actors
          # 评价块
          yield actor
        end
      # 角色单体 (N 个人) 的情况下
      else
        # 获取角色
        actor = $game_party.actors[parameter2]
        # 评价块
        yield actor if actor != nil
      end
    end
  end
end


#
# 执行时间命令的解释器。本类在 Game_System 类
# 和 Game_Event 类的内部使用。
#

class Interpreter
  #
  # 执行事件命令
  #
  #
  def execute_command
    # 到达执行内容列表末尾的情况下
    if @index >= @list.size - 1
      # 时间结束
      command_end
      # 继续
      return true
    end
    # 事件命令的功能可以参考 @parameters
    @parameters = @list[@index].parameters
    # 命令代码分支
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
    when 104  # 更改文章选项
      return command_104
    when 105  # 处理按键输入
      return command_105
    when 106  # 等待
      return command_106
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
    when 115  # 中断时间处理
      return command_115
    when 116  # 暂时删除事件
      return command_116
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
    when 131  # 更改窗口外关
      return command_131
    when 132  # 更改战斗 BGM
      return command_132
    when 133  # 更改战斗结束 BGS
      return command_133
    when 134  # 更改禁止保存
      return command_134
    when 135  # 更改禁止菜单
      return command_135
    when 136  # 更改禁止遇敌
      return command_136
    when 201  # 場所移動
      return command_201
    when 202  # 设置事件位置
      return command_202
    when 203  # 地图滚动
      return command_203
    when 204  # 更改地图设置
      return command_204
    when 205  # 更改雾的色调
      return command_205
    when 206  # 更改雾的不透明度
      return command_206
    when 207  # 显示动画
      return command_207
    when 208  # 更改透明状态
      return command_208
    when 209  # 设置移动路线
      return command_209
    when 210  # 移动结束后等待
      return command_210
    when 221  # 准备过渡
      return command_221
    when 222  # 执行过渡
      return command_222
    when 223  # 更改画面色调
      return command_223
    when 224  # 画面闪烁
      return command_224
    when 225  # 画面震动
      return command_225
    when 231  # 显示图片
      return command_231
    when 232  # 移动图片
      return command_232
    when 233  # 旋转图片
      return command_233
    when 234  # 更改色调
      return command_234
    when 235  # 删除图片
      return command_235
    when 236  # 设置天候
      return command_236
    when 241  # 演奏 BGM
      return command_241
    when 242  # BGM 的淡入淡出
      return command_242
    when 245  # 演奏 BGS
      return command_245
    when 246  # BGS 的淡入淡出
      return command_246
    when 247  # 记忆 BGM / BGS
      return command_247
    when 248  # 还原 BGM / BGS
      return command_248
    when 249  # 演奏 ME
      return command_249
    when 250  # 演奏 SE
      return command_250
    when 251  # 停止 SE
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
    when 312  # 增减 SP
      return command_312
    when 313  # 更改状态
      return command_313
    when 314  # 全回复
      return command_314
    when 315  # 增减 EXP
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
    when 331  # 増減敌人的 HP
      return command_331
    when 332  # 増減敌人的 SP
      return command_332
    when 333  # 更改敌人的状态
      return command_333
    when 334  # 敌人出现
      return command_334
    when 335  # 敌人变身
      return command_335
    when 336  # 敌人全回复
      return command_336
    when 337  # 显示动画
      return command_337
    when 338  # 伤害处理
      return command_338
    when 339  # 强制行动
      return command_339
    when 340  # 战斗中断
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
  #
  # 事件结束
  #
  #
  def command_end
    # 清除执行内容列表
    @list = nil
    # 主地图事件与事件 ID 有效的情况下
    if @main and @event_id > 0
      # 解除事件锁定
      $game_map.events[@event_id].unlock
    end
  end
  #
  # 指令跳转
  #
  #
  def command_skip
    # 获取缩进
    indent = @list[@index].indent
    # 循环
    loop do
      # 下一个事件命令是同等级的缩进的情况下
      if @list[@index+1].indent == indent
        # 继续
        return true
      end
      # 索引的下一个
      @index += 1
    end
  end
  #
  # 获取角色
  #
  # parameter : 能力值
  #
  def get_character(parameter)
    # 能力值分支
    case parameter
    when -1  # 角色
      return $game_player
    when 0  # 本事件
      events = $game_map.events
      return events == nil ? nil : events[@event_id]
    else  # 特定的事件
      events = $game_map.events
      return events == nil ? nil : events[parameter]
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
    # 获取操作数
    if operand_type == 0
      value = operand
    else
      value = $game_variables[operand]
    end
    # 操作为 [减少] 的情况下反转实际符号
    if operation == 1
      value = -value
    end
    # 返回 value
    return value
  end
end


#
# 执行事件指令的解释器。本类在 Game_System 类
# 和 Game_Event 类的内部使用。
#

class Interpreter
  #
  # 显示文章
  #
  #
  def command_101
    # 另外的文章已经设置过 message_text 的情况下
    if $game_temp.message_text != nil
      # 结束
      return false
    end
    # 设置信息结束后待机和返回调用标志
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # message_text 设置为 1 行
    $game_temp.message_text = @list[@index].parameters[0] + "\n"
    line_count = 1
    # 循环
    loop do
      # 下一个事件指令为文章两行以上的情况
      if @list[@index+1].code == 401
        # message_text 添加到第 2 行以下
        $game_temp.message_text += @list[@index+1].parameters[0] + "\n"
        line_count += 1
      # 事件指令不在文章两行以下的情况
      else
        # 下一个事件指令为显示选择项的情况下
        if @list[@index+1].code == 102
          # 如果选择项能收纳在画面里
          if @list[@index+1].parameters[0].size <= 4 - line_count
            # 推进索引
            @index += 1
            # 设置选择项
            $game_temp.choice_start = line_count
            setup_choices(@list[@index].parameters)
          end
        # 下一个事件指令为处理输入数值的情况下
        elsif @list[@index+1].code == 103
          # 如果数值输入窗口能收纳在画面里
          if line_count < 4
            # 推进索引
            @index += 1
            # 设置输入数值
            $game_temp.num_input_start = line_count
            $game_temp.num_input_variable_id = @list[@index].parameters[0]
            $game_temp.num_input_digits_max = @list[@index].parameters[1]
          end
        end
        # 继续
        return true
      end
      # 推进索引
      @index += 1
    end
  end
  #
  # 显示选择项
  #
  #
  def command_102
    # 文章已经设置过 message_text 的情况下
    if $game_temp.message_text != nil
      # 结束
      return false
    end
    # 设置信息结束后待机和返回调用标志
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # 设置选择项
    $game_temp.message_text = ""
    $game_temp.choice_start = 0
    setup_choices(@parameters)
    # 继续
    return true
  end
  #
  # [**] 的情况下
  #
  #
  def command_402
    # 如果符合的选择项被选择
    if @branch[@list[@index].indent] == @parameters[0]
      # 删除分支数据
      @branch.delete(@list[@index].indent)
      # 继续
      return true
    end
    # 不符合条件的情况下 : 指令跳转
    return command_skip
  end
  #
  # 取消的情况下
  #
  #
  def command_403
    # 如果选择了选择项取消
    if @branch[@list[@index].indent] == 4
      # 删除分支数据
      @branch.delete(@list[@index].indent)
      # 继续
      return true
    end
    # 不符合条件的情况下 : 指令跳转
    return command_skip
  end
  #
  # 处理数值输入
  #
  #
  def command_103
    # 文章已经设置过 message_text 的情况下
    if $game_temp.message_text != nil
      # 结束
      return false
    end
    # 设置信息结束后待机和返回调用标志
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # 设置数值输入
    $game_temp.message_text = ""
    $game_temp.num_input_start = 0
    $game_temp.num_input_variable_id = @parameters[0]
    $game_temp.num_input_digits_max = @parameters[1]
    # 继续
    return true
  end
  #
  # 更改文章选项
  #
  #
  def command_104
    # 正在显示信息的情况下
    if $game_temp.message_window_showing
      # 结束
      return false
    end
    # 更改各个选项
    $game_system.message_position = @parameters[0]
    $game_system.message_frame = @parameters[1]
    # 继续
    return true
  end
  #
  # 处理按键输入
  #
  #
  def command_105
    # 设置按键输入用变量 ID
    @button_input_variable_id = @parameters[0]
    # 推进索引
    @index += 1
    # 结束
    return false
  end
  #
  # 等待
  #
  #
  def command_106
    # 设置等待计数
    @wait_count = @parameters[0] * 2
    # 继续
    return true
  end
  #
  # 条件分支
  #
  #
  def command_111
    # 初始化本地变量 result
    result = false
    # 条件判定
    case @parameters[0]
    when 0  # 开关
      result = ($game_switches[@parameters[1]] == (@parameters[2] == 0))
    when 1  # 变量
      value1 = $game_variables[@parameters[1]]
      if @parameters[2] == 0
        value2 = @parameters[3]
      else
        value2 = $game_variables[@parameters[3]]
      end
      case @parameters[4]
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
      if @event_id > 0
        key = [$game_map.map_id, @event_id, @parameters[1]]
        if @parameters[2] == 0
          result = ($game_self_switches[key] == true)
        else
          result = ($game_self_switches[key] != true)
        end
      end
    when 3  # 计时器
      if $game_system.timer_working
        sec = $game_system.timer / Graphics.frame_rate
        if @parameters[2] == 0
          result = (sec >= @parameters[1])
        else
          result = (sec <= @parameters[1])
        end
      end
    when 4  # 角色
      actor = $game_actors[@parameters[1]]
      if actor != nil
        case @parameters[2]
        when 0  # 同伴
          result = ($game_party.actors.include?(actor))
        when 1  # 名称
          result = (actor.name == @parameters[3])
        when 2  # 特技
          result = (actor.skill_learn?(@parameters[3]))
        when 3  # 武器
          result = (actor.weapon_id == @parameters[3])
        when 4  # 防具
  result = (actor.armor1_id == @parameters[3] or
                    actor.armor2_id == @parameters[3] or
                    actor.armor3_id == @parameters[3] or
                    actor.armor4_id == @parameters[3])
        when 5  # 状态
          result = (actor.state?(@parameters[3]))
        end
      end
    when 5  # 敌人
      enemy = $game_troop.enemies[@parameters[1]]
      if enemy != nil
        case @parameters[2]
        when 0  # 出现
          result = (enemy.exist?)
        when 1  # 状态
          result = (enemy.state?(@parameters[3]))
        end
      end
    when 6  # 角色
      character = get_character(@parameters[1])
      if character != nil
        result = (character.direction == @parameters[2])
      end
    when 7  # 金钱
      if @parameters[2] == 0
        result = ($game_party.gold >= @parameters[1])
      else
        result = ($game_party.gold <= @parameters[1])
      end
    when 8  # 物品
      result = ($game_party.item_number(@parameters[1]) > 0)
    when 9  # 武器
      result = ($game_party.weapon_number(@parameters[1]) > 0)
    when 10  # 防具
      result = ($game_party.armor_number(@parameters[1]) > 0)
    when 11  # 按钮
      result = (Input.press?(@parameters[1]))
    when 12  # 活动块
      result = eval(@parameters[1])
    end
    # 判断结果保存在 hash 中
    @branch[@list[@index].indent] = result
    # 判断结果为真的情况下
    if @branch[@list[@index].indent] == true
      # 删除分支数据
      @branch.delete(@list[@index].indent)
      # 继续
      return true
    end
    # 不符合条件的情况下 : 指令跳转
    return command_skip
  end
  #
  # 这以外的情况
  #
  #
  def command_411
    # 判断结果为假的情况下
    if @branch[@list[@index].indent] == false
      # 删除分支数据
      @branch.delete(@list[@index].indent)
      # 继续
      return true
    end
    # 不符合条件的情况下 : 指令跳转
    return command_skip
  end
  #
  # 循环
  #
  #
  def command_112
    # 继续
    return true
  end
  #
  # 循环上次
  #
  #
  def command_413
    # 获取缩进
    indent = @list[@index].indent
    # 循环
    loop do
      # 推进索引
      @index -= 1
      # 本事件指令是同等级的缩进的情况下
      if @list[@index].indent == indent
        # 继续
        return true
      end
    end
  end
  #
  # 中断循环
  #
  #
  def command_113
    # 获取缩进
    indent = @list[@index].indent
    # 将缩进复制到临时变量中
    temp_index = @index
    # 循环
    loop do
      # 推进索引
      temp_index += 1
      # 没找到符合的循环的情况下
      if temp_index >= @list.size-1
        # 继续
        return true
      end
      # 本事件命令为 [重复上次] 的缩进浅的情况下
      if @list[temp_index].code == 413 and @list[temp_index].indent < indent
        # 刷新索引
        @index = temp_index
        # 继续
        return true
      end
    end
  end
  #
  # 中断事件处理
  #
  #
  def command_115
    # 结束事件
    command_end
    # 继续
    return true
  end
  #
  # 事件暂时删除
  #
  #
  def command_116
    # 事件 ID 有效的情况下
    if @event_id > 0
      # 删除事件
      $game_map.events[@event_id].erase
    end
    # 推进索引
    @index += 1
    # 继续
    return false
  end
  #
  # 公共事件
  #
  #
  def command_117
    # 获取公共事件
    common_event = $data_common_events[@parameters[0]]
    # 公共事件有效的情况下
    if common_event != nil
      # 生成子解释器
      @child_interpreter = Interpreter.new(@depth + 1)
      @child_interpreter.setup(common_event.list, @event_id)
    end
    # 继续
    return true
  end
  #
  # 标签
  #
  #
  def command_118
    # 继续
    return true
  end
  #
  # 标签跳转
  #
  #
  def command_119
    # 获取标签名
    label_name = @parameters[0]
    # 初始化临时变量
    temp_index = 0
    # 循环
    loop do
      # 没找到符合的标签的情况下
      if temp_index >= @list.size-1
        # 继续
        return true
      end
      # 本事件指令为指定的标签的名称的情况下
      if @list[temp_index].code == 118 and
         @list[temp_index].parameters[0] == label_name
        # 刷新索引
        @index = temp_index
        # 继续
        return true
      end
      # 推进索引
      temp_index += 1
    end
  end
end


#
# 执行事件命令的解释器。本类在 Game_System 类
# 和 Game_Event 类的内部使用。
#

class Interpreter
  #
  # 开关操作
  #
  #
  def command_121
    # 循环全部操作
    for i in @parameters[0] .. @parameters[1]
      # 更改开关
      $game_switches[i] = (@parameters[2] == 0)
    end
    # 刷新地图
    $game_map.need_refresh = true
    # 继续
    return true
  end
  #
  # 变量操作
  #
  #
  def command_122
    # 初始化值
    value = 0
    # 操作数的分支
    case @parameters[3]
    when 0  # 恒量
      value = @parameters[4]
    when 1  # 变量
      value = $game_variables[@parameters[4]]
    when 2  # 随机数
      value = @parameters[4] + rand(@parameters[5] - @parameters[4] + 1)
    when 3  # 物品
      value = $game_party.item_number(@parameters[4])
    when 4  # 角色
      actor = $game_actors[@parameters[4]]
      if actor != nil
        case @parameters[5]
        when 0  # 等级
          value = actor.level
        when 1  # EXP
          value = actor.exp
        when 2  # HP
          value = actor.hp
        when 3  # SP
          value = actor.sp
        when 4  # MaxHP
          value = actor.maxhp
        when 5  # MaxSP
          value = actor.maxsp
        when 6  # 力量
          value = actor.str
        when 7  # 灵巧
          value = actor.dex
        when 8  # 速度
          value = actor.agi
        when 9  # 魔力
          value = actor.int
        when 10  # 攻击力
          value = actor.atk
        when 11  # 物理防御
          value = actor.pdef
        when 12  # 魔法防御
          value = actor.mdef
        when 13  # 回避修正
          value = actor.eva
        end
      end
    when 5  # 敌人
      enemy = $game_troop.enemies[@parameters[4]]
      if enemy != nil
        case @parameters[5]
        when 0  # HP
          value = enemy.hp
        when 1  # SP
          value = enemy.sp
        when 2  # MaxHP
          value = enemy.maxhp
        when 3  # MaxSP
          value = enemy.maxsp
        when 4  # 力量
          value = enemy.str
        when 5  # 灵巧
          value = enemy.dex
        when 6  # 速度
          value = enemy.agi
        when 7  # 魔力
          value = enemy.int
        when 8  # 攻击力
          value = enemy.atk
        when 9  # 物理防御
          value = enemy.pdef
        when 10  # 魔法防御
          value = enemy.mdef
        when 11  # 回避修正
          value = enemy.eva
        end
      end
    when 6  # 角色
      character = get_character(@parameters[4])
      if character != nil
        case @parameters[5]
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
        when 5  # 地形标记
          value = character.terrain_tag
        end
      end
    when 7  # 其它
      case @parameters[4]
      when 0  # 地图 ID
        value = $game_map.map_id
      when 1  # 同伴人数
        value = $game_party.actors.size
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
    # 循环全部操作
    for i in @parameters[0] .. @parameters[1]
      # 操作分支
      case @parameters[2]
      when 0  # 代入
        $game_variables[i] = value
      when 1  # 加法
        $game_variables[i] += value
      when 2  # 减法
        $game_variables[i] -= value
      when 3  # 乘法
        $game_variables[i] *= value
      when 4  # 除法
        if value != 0
          $game_variables[i] /= value
        end
      when 5  # 剩余
        if value != 0
          $game_variables[i] %= value
        end
      end
      # 检查上限
      if $game_variables[i] > 99999999
        $game_variables[i] = 99999999
      end
      # 检查下限
      if $game_variables[i] < -99999999
        $game_variables[i] = -99999999
      end
    end
    # 刷新地图
    $game_map.need_refresh = true
    # 继续
    return true
  end
  #
  # 独立开关操作
  #
  #
  def command_123
    # 事件 ID 有效的情况下
    if @event_id > 0
      # 生成独立开关键
      key = [$game_map.map_id, @event_id, @parameters[0]]
      # 更改独立开关
      $game_self_switches[key] = (@parameters[1] == 0)
    end
    # 刷新地图
    $game_map.need_refresh = true
    # 继续
    return true
  end
  #
  # 计时器操作
  #
  #
  def command_124
    # 开始的情况
    if @parameters[0] == 0
      $game_system.timer = @parameters[1] * Graphics.frame_rate
      $game_system.timer_working = true
    end
    # 停止的情况
    if @parameters[0] == 1
      $game_system.timer_working = false
    end
    # 继续
    return true
  end
  #
  # 增减金钱
  #
  #
  def command_125
    # 获取要操作的值
    value = operate_value(@parameters[0], @parameters[1], @parameters[2])
    # 增减金钱
    $game_party.gain_gold(value)
    # 继续
    return true
  end
  #
  # 增减物品
  #
  #
  def command_126
    # 获取要操作的值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 增减物品
    $game_party.gain_item(@parameters[0], value)
    # 继续
    return true
  end
  #
  # 增减武器
  #
  #
  def command_127
    # 获取要操作的值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 增减武器
    $game_party.gain_weapon(@parameters[0], value)
    # 继续
    return true
  end
  #
  # 增减防具
  #
  #
  def command_128
    # 获取要操作的值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 增减防具
    $game_party.gain_armor(@parameters[0], value)
    # 继续
    return true
  end
  #
  # 角色的替换
  #
  #
  def command_129
    # 获取角色
    actor = $game_actors[@parameters[0]]
    # 角色有效的情况下
    if actor != nil
      # 操作分支
      if @parameters[1] == 0
        if @parameters[2] == 1
          $game_actors[@parameters[0]].setup(@parameters[0])
        end
        $game_party.add_actor(@parameters[0])
      else
        $game_party.remove_actor(@parameters[0])
      end
    end
    # 继续
    return true
  end
  #
  # 更改窗口外观
  #
  #
  def command_131
    # 设置窗口外观文件名
    $game_system.windowskin_name = @parameters[0]
    # 继续
    return true
  end
  #
  # 更改战斗 BGM
  #
  #
  def command_132
    # 设置战斗 BGM
    $game_system.battle_bgm = @parameters[0]
    # 继续
    return true
  end
  #
  # 更改战斗结束的 ME
  #
  #
  def command_133
    # 设置战斗结束的 ME
    $game_system.battle_end_me = @parameters[0]
    # 继续
    return true
  end
  #
  # 更改禁止存档
  #
  #
  def command_134
    # 更改禁止存档标志
    $game_system.save_disabled = (@parameters[0] == 0)
    # 继续
    return true
  end
  #
  # 更改禁止菜单
  #
  #
  def command_135
    # 更改禁止菜单标志
    $game_system.menu_disabled = (@parameters[0] == 0)
    # 继续
    return true
  end
  #
  # 更改禁止遇敌
  #
  #
  def command_136
    # 更改更改禁止遇敌标志
    $game_system.encounter_disabled = (@parameters[0] == 0)
    # 生成遇敌计数
    $game_player.make_encounter_count
    # 继续
    return true
  end
end


#
# 执行事件命令的注释器。本类在 Game_System 类
# 和 Game_Event 类的内部使用。
#

class Interpreter
  #
  # 场所移动
  #
  #
  def command_201
    # 战斗中的情况
    if $game_temp.in_battle
      # 继续
      return true
    end
    # 场所移动中、信息显示中、过渡处理中的情况下
    if $game_temp.player_transferring or
       $game_temp.message_window_showing or
       $game_temp.transition_processing
      # 结束
      return false
    end
    # 设置场所移动标志
    $game_temp.player_transferring = true
    # 指定方法为 [直接指定] 的情况下
    if @parameters[0] == 0
      # 设置主角的移动目标
      $game_temp.player_new_map_id = @parameters[1]
      $game_temp.player_new_x = @parameters[2]
      $game_temp.player_new_y = @parameters[3]
      $game_temp.player_new_direction = @parameters[4]
    # 指定方法为 [使用变量指定] 的情况下
    else
      # 设置主角的移动目标
      $game_temp.player_new_map_id = $game_variables[@parameters[1]]
      $game_temp.player_new_x = $game_variables[@parameters[2]]
      $game_temp.player_new_y = $game_variables[@parameters[3]]
      $game_temp.player_new_direction = @parameters[4]
    end
    # 推进索引
    @index += 1
    # 有淡入淡出的情况下
    if @parameters[5] == 0
      # 准备过渡
      Graphics.freeze
      # 设置过渡处理中标志
      $game_temp.transition_processing = true
      $game_temp.transition_name = ""
    end
    # 结束
    return false
  end
  #
  # 设置事件位置
  #
  #
  def command_202
    # 战斗中的情况下
    if $game_temp.in_battle
      # 继续
      return true
    end
    # 获取角色
    character = get_character(@parameters[0])
    # 角色不存在的情况下
    if character == nil
      # 继续
      return true
    end
    # 指定方法为 [直接指定] 的情况下
    if @parameters[1] == 0
      # 设置角色的位置
      character.moveto(@parameters[2], @parameters[3])
    # 指定方法为 [使用变量指定] 的情况下
    elsif @parameters[1] == 1
      # 设置角色的位置
      character.moveto($game_variables[@parameters[2]],
        $game_variables[@parameters[3]])
    # 指定方法为 [与其它事件交换] 的情况下
    else
      old_x = character.x
      old_y = character.y
      character2 = get_character(@parameters[2])
      if character2 != nil
        character.moveto(character2.x, character2.y)
        character2.moveto(old_x, old_y)
      end
    end
    # 设置觉得的朝向
    case @parameters[4]
    when 8  # 上
      character.turn_up
    when 6  # 右
      character.turn_right
    when 2  # 下
      character.turn_down
    when 4  # 左
      character.turn_left
    end
    # 继续
    return true
  end
  #
  # 地图的滚动
  #
  #
  def command_203
    # 战斗中的情况下
    if $game_temp.in_battle
      # 继续
      return true
    end
    # 已经在滚动中的情况下
    if $game_map.scrolling?
      # 结束
      return false
    end
    # 开始滚动
    $game_map.start_scroll(@parameters[0], @parameters[1], @parameters[2])
    # 继续
    return true
  end
  #
  # 更改地图设置
  #
  #
  def command_204
    case @parameters[0]
    when 0  # 远景
      $game_map.panorama_name = @parameters[1]
      $game_map.panorama_hue = @parameters[2]
    when 1  # 雾
      $game_map.fog_name = @parameters[1]
      $game_map.fog_hue = @parameters[2]
      $game_map.fog_opacity = @parameters[3]
      $game_map.fog_blend_type = @parameters[4]
      $game_map.fog_zoom = @parameters[5]
      $game_map.fog_sx = @parameters[6]
      $game_map.fog_sy = @parameters[7]
    when 2  # 战斗背景
      $game_map.battleback_name = @parameters[1]
      $game_temp.battleback_name = @parameters[1]
    end
    # 继续
    return true
  end
  #
  # 更改雾的色调
  #
  #
  def command_205
    # 开始更改色调
    $game_map.start_fog_tone_change(@parameters[0], @parameters[1] * 2)
    # 继续
    return true
  end
  #
  # 更改雾的不透明度
  #
  #
  def command_206
    # 开始更改不透明度
    $game_map.start_fog_opacity_change(@parameters[0], @parameters[1] * 2)
    # 继续
    return true
  end
  #
  # 显示动画
  #
  #
  def command_207
    # 获取角色
    character = get_character(@parameters[0])
    # 角色不存在的情况下
    if character == nil
      # 继续
      return true
    end
    # 设置动画 ID
    character.animation_id = @parameters[1]
    # 继续
    return true
  end
  #
  # 更改透明状态
  #
  #
  def command_208
    # 设置主角的透明状态
    $game_player.transparent = (@parameters[0] == 0)
    # 继续
    return true
  end
  #
  # 设置移动路线
  #
  #
  def command_209
    # 获取角色
    character = get_character(@parameters[0])
    # 角色不存在的情况下
    if character == nil
      # 继续
      return true
    end
    # 强制移动路线
    character.force_move_route(@parameters[1])
    # 继续
    return true
  end
  #
  # 移动结束后等待
  #
  #
  def command_210
    # 如果不在战斗中
    unless $game_temp.in_battle
      # 设置移动结束后待机标志
      @move_route_waiting = true
    end
    # 继续
    return true
  end
  #
  # 开始过渡
  #
  #
  def command_221
    # 显示信息窗口中的情况下
    if $game_temp.message_window_showing
      # 结束
      return false
    end
    # 准备过渡
    Graphics.freeze
    # 继续
    return true
  end
  #
  # 执行过渡
  #
  #
  def command_222
    # 已经设置了过渡处理中标志的情况下
    if $game_temp.transition_processing
      # 结束
      return false
    end
    # 设置过渡处理中标志
    $game_temp.transition_processing = true
    $game_temp.transition_name = @parameters[0]
    # 推进索引
    @index += 1
    # 结束
    return false
  end
  #
  # 更改画面色调
  #
  #
  def command_223
    # 开始更改色调
    $game_screen.start_tone_change(@parameters[0], @parameters[1] * 2)
    # 继续
    return true
  end
  #
  # 画面闪烁
  #
  #
  def command_224
    # 开始闪烁
    $game_screen.start_flash(@parameters[0], @parameters[1] * 2)
    # 继续
    return true
  end
  #
  # 画面震动
  #
  #
  def command_225
    # 震动开始
    $game_screen.start_shake(@parameters[0], @parameters[1],
      @parameters[2] * 2)
    # 继续
    return true
  end
  #
  # 显示图片
  #
  #
  def command_231
    # 获取图片编号
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # 指定方法为 [直接指定] 的情况下
    if @parameters[3] == 0
      x = @parameters[4]
      y = @parameters[5]
    # 指定方法为 [使用变量指定] 的情况下
    else
      x = $game_variables[@parameters[4]]
      y = $game_variables[@parameters[5]]
    end
    # 显示图片
    $game_screen.pictures[number].show(@parameters[1], @parameters[2],
      x, y, @parameters[6], @parameters[7], @parameters[8], @parameters[9])
    # 继续
    return true
  end
  #
  # 移动图片
  #
  #
  def command_232
    # 获取图片编号
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # 指定方法为 [直接指定] 的情况下
    if @parameters[3] == 0
      x = @parameters[4]
      y = @parameters[5]
    # 指定方法为 [使用变量指定] 的情况下
    else
      x = $game_variables[@parameters[4]]
      y = $game_variables[@parameters[5]]
    end
    # 移动图片
    $game_screen.pictures[number].move(@parameters[1] * 2, @parameters[2],
      x, y, @parameters[6], @parameters[7], @parameters[8], @parameters[9])
    # 继续
    return true
  end
  #
  # 旋转图片
  #
  #
  def command_233
    # 获取图片编号
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # 设置旋转速度
    $game_screen.pictures[number].rotate(@parameters[1])
    # 继续
    return true
  end
  #
  # 更改图片色调
  #
  #
  def command_234
    # 获取图片编号
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # 开始更改色调
    $game_screen.pictures[number].start_tone_change(@parameters[1],
      @parameters[2] * 2)
    # 继续
    return true
  end
  #
  # 删除图片
  #
  #
  def command_235
    # 获取图片编号
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # 删除图片
    $game_screen.pictures[number].erase
    # 继续
    return true
  end
  #
  # 天候设置
  #
  #
  def command_236
    # 设置天候
    $game_screen.weather(@parameters[0], @parameters[1], @parameters[2])
    # 继续
    return true
  end
  #
  # 演奏 BGM
  #
  #
  def command_241
    # 演奏 BGM
    $game_system.bgm_play(@parameters[0])
    # 继续
    return true
  end
  #
  # BGM 的淡入淡出
  #
  #
  def command_242
    # 淡入淡出 BGM
    $game_system.bgm_fade(@parameters[0])
    # 继续
    return true
  end
  #
  # 演奏 BGS
  #
  #
  def command_245
    # 演奏 BGS
    $game_system.bgs_play(@parameters[0])
    # 继续
    return true
  end
  #
  # BGS 的淡入淡出
  #
  #
  def command_246
    # 淡入淡出 BGS
    $game_system.bgs_fade(@parameters[0])
    # 继续
    return true
  end
  #
  # 记忆 BGM / BGS
  #
  #
  def command_247
    # 记忆 BGM / BGS
    $game_system.bgm_memorize
    $game_system.bgs_memorize
    # 继续
    return true
  end
  #
  # 还原 BGM / BGS
  #
  #
  def command_248
    # 还原 BGM / BGS
    $game_system.bgm_restore
    $game_system.bgs_restore
    # 继续
    return true
  end
  #
  # 演奏 ME
  #
  #
  def command_249
    # 演奏 ME
    $game_system.me_play(@parameters[0])
    # 继续
    return true
  end
  #
  # 演奏 SE
  #
  #
  def command_250
    # 演奏 SE
    $game_system.se_play(@parameters[0])
    # 继续
    return true
  end
  #
  # 停止 SE
  #
  #
  def command_251
    # 停止 SE
    Audio.se_stop
    # 继续
    return true
  end
end


#
# 执行事件命令的解释器。本类在 Game_System 类
# 和 Game_Event 类的内部使用。
#

class Interpreter
  #
  # 战斗处理
  #
  #
  def command_301
    # 如果不是无效的队伍
    if $data_troops[@parameters[0]] != nil
      # 设置中断战斗标志
      $game_temp.battle_abort = true
      # 设置战斗调用标志
      $game_temp.battle_calling = true
      $game_temp.battle_troop_id = @parameters[0]
      $game_temp.battle_can_escape = @parameters[1]
      $game_temp.battle_can_lose = @parameters[2]
      # 设置返回调用
      current_indent = @list[@index].indent
      $game_temp.battle_proc = Proc.new { |n| @branch[current_indent] = n }
    end
    # 推进索引
    @index += 1
    # 结束
    return false
  end
  #
  # 胜利的情况下
  #
  #
  def command_601
    # 战斗结果为胜利的情况下
    if @branch[@list[@index].indent] == 0
      # 删除分支数据
      @branch.delete(@list[@index].indent)
      # 继续
      return true
    end
    # 不符合条件的情况下 : 指令跳转
    return command_skip
  end
  #
  # 逃跑的情况下
  #
  #
  def command_602
    # 战斗结果为逃跑的情况下
    if @branch[@list[@index].indent] == 1
      # 删除分支数据
      @branch.delete(@list[@index].indent)
      # 继续
      return true
    end
    # 不符合条件的情况下 : 指令跳转
    return command_skip
  end
  #
  # 失败的情况下
  #
  #
  def command_603
    # 战斗结果为失败的情况下
    if @branch[@list[@index].indent] == 2
      # 删除分支数据
      @branch.delete(@list[@index].indent)
      # 继续
      return true
    end
    # 不符合条件的情况下 : 指令跳转
    return command_skip
  end
  #
  # 商店的处理
  #
  #
  def command_302
    # 设置战斗中断标志
    $game_temp.battle_abort = true
    # 设置商店调用标志
    $game_temp.shop_calling = true
    # 设置商品列表的新项目
    $game_temp.shop_goods = [@parameters]
    # 循环
    loop do
      # 推进索引
      @index += 1
      # 下一个事件命令在商店两行以上的情况下
      if @list[@index].code == 605
        # 在商品列表中添加新项目
        $game_temp.shop_goods.push(@list[@index].parameters)
      # 事件命令不在商店两行以上的情况下
      else
        # 技术
        return false
      end
    end
  end
  #
  # 名称输入处理
  #
  #
  def command_303
    # 如果不是无效的角色
    if $data_actors[@parameters[0]] != nil
      # 设置战斗中断标志
      $game_temp.battle_abort = true
      # 设置名称输入调用标志
      $game_temp.name_calling = true
      $game_temp.name_actor_id = @parameters[0]
      $game_temp.name_max_char = @parameters[1]
    end
    # 推进索引
    @index += 1
    # 结束
    return false
  end
  #
  # 增减 HP
  #
  #
  def command_311
    # 获取操作值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 处理重复
    iterate_actor(@parameters[0]) do |actor|
      # HP 不为 0 的情况下
      if actor.hp > 0
        # 更改 HP (如果不允许战斗不能的状态就设置为 1)
        if @parameters[4] == false and actor.hp + value <= 0
          actor.hp = 1
        else
          actor.hp += value
        end
      end
    end
    # 游戏结束判定
    $game_temp.gameover = $game_party.all_dead?
    # 继续
    return true
  end
  #
  # 增减 SP
  #
  #
  def command_312
    # 获取操作值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 处理重复
    iterate_actor(@parameters[0]) do |actor|
      # 更改角色的 SP
      actor.sp += value
    end
    # 继续
    return true
  end
  #
  # 更改状态
  #
  #
  def command_313
    # 处理重复
    iterate_actor(@parameters[0]) do |actor|
      # 更改状态
      if @parameters[1] == 0
        actor.add_state(@parameters[2])
      else
        actor.remove_state(@parameters[2])
      end
    end
    # 继续
    return true
  end
  #
  # 全回复
  #
  #
  def command_314
    # 处理重复
    iterate_actor(@parameters[0]) do |actor|
      # 角色全回复
      actor.recover_all
    end
    # 继续
    return true
  end
  #
  # 增减 EXP
  #
  #
  def command_315
    # 获取操作值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 处理重复
    iterate_actor(@parameters[0]) do |actor|
      # 更改角色 EXP
      actor.exp += value
    end
    # 继续
    return true
  end
  #
  # 增减等级
  #
  #
  def command_316
    # 获取操作值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 处理重复
    iterate_actor(@parameters[0]) do |actor|
      # 更改角色的等级
      actor.level += value
    end
    # 继续
    return true
  end
  #
  # 增减能力值
  #
  #
  def command_317
    # 获取操作值
    value = operate_value(@parameters[2], @parameters[3], @parameters[4])
    # 获取角色
    actor = $game_actors[@parameters[0]]
    # 更改能力值
    if actor != nil
      case @parameters[1]
      when 0  # MaxHP
        actor.maxhp += value
      when 1  # MaxSP
        actor.maxsp += value
      when 2  # 力量
        actor.str += value
      when 3  # 灵巧
        actor.dex += value
      when 4  # 速度
        actor.agi += value
      when 5  # 魔力
        actor.int += value
      end
    end
    # 继续
    return true
  end
  #
  # 增减特技
  #
  #
  def command_318
    # 获取角色
    actor = $game_actors[@parameters[0]]
    # 增减特技
    if actor != nil
      if @parameters[1] == 0
        actor.learn_skill(@parameters[2])
      else
        actor.forget_skill(@parameters[2])
      end
    end
    # 继续
    return true
  end
  #
  # 变更装备
  #
  #
  def command_319
    # 获取角色
    actor = $game_actors[@parameters[0]]
    # 变更角色
    if actor != nil
      actor.equip(@parameters[1], @parameters[2])
    end
    # 继续
    return true
  end
  #
  # 更改角色的名字
  #
  #
  def command_320
    # 获取角色
    actor = $game_actors[@parameters[0]]
    # 更改名字
    if actor != nil
      actor.name = @parameters[1]
    end
    # 继续
    return true
  end
  #
  # 更改角色的职业
  #
  #
  def command_321
    # 获取角色
    actor = $game_actors[@parameters[0]]
    # 更改职业
    if actor != nil
      actor.class_id = @parameters[1]
    end
    # 继续
    return true
  end
  #
  # 更改角色的图形
  #
  #
  def command_322
    # 获取角色
    actor = $game_actors[@parameters[0]]
    # 更改图形
    if actor != nil
      actor.set_graphic(@parameters[1], @parameters[2],
        @parameters[3], @parameters[4])
    end
    # 刷新角色
    $game_player.refresh
    # 继续
    return true
  end
end


#
# 执行事件命令的解释器。本类在 Game_System 类
# 和 Game_Event 类的内部使用。
#

class Interpreter
  #
  # 增减敌人的 HP
  #
  #
  def command_331
    # 获取操作值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 处理循环
    iterate_enemy(@parameters[0]) do |enemy|
      # HP 不为 0 的情况下
      if enemy.hp > 0
        # 更改 HP (如果不允许战斗不能的状态就设置为 1)
        if @parameters[4] == false and enemy.hp + value <= 0
          enemy.hp = 1
        else
          enemy.hp += value
        end
      end
    end
    # 继续
    return true
  end
  #
  # 增减敌人的 SP
  #
  #
  def command_332
    # 获取操作值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 处理循环
    iterate_enemy(@parameters[0]) do |enemy|
      # 更改 SP
      enemy.sp += value
    end
    # 继续
    return true
  end
  #
  # 更改敌人的状态
  #
  #
  def command_333
    # 处理循环
    iterate_enemy(@parameters[0]) do |enemy|
      # 状态选项 [当作 HP 为 0 的状态] 有效的情况下
      if $data_states[@parameters[2]].zero_hp
        # 清除不死身标志
        enemy.immortal = false
      end
      # 更改状态
      if @parameters[1] == 0
        enemy.add_state(@parameters[2])
      else
        enemy.remove_state(@parameters[2])
      end
    end
    # 继续
    return true
  end
  #
  # 敌人的全回复
  #
  #
  def command_334
    # 处理循环
    iterate_enemy(@parameters[0]) do |enemy|
      # 全回复
      enemy.recover_all
    end
    # 继续
    return true
  end
  #
  # 敌人出现
  #
  #
  def command_335
    # 获取敌人
    enemy = $game_troop.enemies[@parameters[0]]
    # 清除隐藏标志
    if enemy != nil
      enemy.hidden = false
    end
    # 继续
    return true
  end
  #
  # 敌人变身
  #
  #
  def command_336
    # 获取敌人
    enemy = $game_troop.enemies[@parameters[0]]
    # 变身处理
    if enemy != nil
      enemy.transform(@parameters[1])
    end
    # 继续
    return true
  end
  #
  # 显示动画
  #
  #
  def command_337
    # 处理循环
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # 战斗者存在的情况下
      if battler.exist?
        # 设置动画 ID
        battler.animation_id = @parameters[2]
      end
    end
    # 继续
    return true
  end
  #
  # 伤害处理
  #
  #
  def command_338
    # 获取操作值
    value = operate_value(0, @parameters[2], @parameters[3])
    # 处理循环
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # 战斗者存在的情况下
      if battler.exist?
        # 更改 HP
        battler.hp -= value
        # 如果在战斗中
        if $game_temp.in_battle
          # 设置伤害
          battler.damage = value
          battler.damage_pop = true
        end
      end
    end
    # 继续
    return true
  end
  #
  # 强制行动
  #
  #
  def command_339
    # 忽视是否在战斗中
    unless $game_temp.in_battle
      return true
    end
    # 忽视回合数为 0
    if $game_temp.battle_turn == 0
      return true
    end
    # 处理循环 (为了方便、不需要存在复数)
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # 战斗者存在的情况下
      if battler.exist?
        # 设置行动
        battler.current_action.kind = @parameters[2]
        if battler.current_action.kind == 0
          battler.current_action.basic = @parameters[3]
        else
          battler.current_action.skill_id = @parameters[3]
        end
        # 设置行动对像
        if @parameters[4] == -2
          if battler.is_a?(Game_Enemy)
            battler.current_action.decide_last_target_for_enemy
          else
            battler.current_action.decide_last_target_for_actor
          end
        elsif @parameters[4] == -1
          if battler.is_a?(Game_Enemy)
            battler.current_action.decide_random_target_for_enemy
          else
            battler.current_action.decide_random_target_for_actor
          end
        elsif @parameters[4] >= 0
          battler.current_action.target_index = @parameters[4]
        end
        # 设置强制标志
        battler.current_action.forcing = true
        # 行动有效并且是 [立即执行] 的情况下
        if battler.current_action.valid? and @parameters[5] == 1
          # 设置强制对像的战斗者
          $game_temp.forcing_battler = battler
          # 推进索引
          @index += 1
          # 结束
          return false
        end
      end
    end
    # 继续
    return true
  end
  #
  # 战斗中断
  #
  #
  def command_340
    # 设置战斗中断标志
    $game_temp.battle_abort = true
    # 推进索引
    @index += 1
    # 结束
    return false
  end
  #
  # 调用菜单画面
  #
  #
  def command_351
    # 设置战斗中断标志
    $game_temp.battle_abort = true
    # 设置调用菜单标志
    $game_temp.menu_calling = true
    # 推进索引
    @index += 1
    # 结束
    return false
  end
  #
  # 调用存档画面
  #
  #
  def command_352
    # 设置战斗中断标志
    $game_temp.battle_abort = true
    # 设置调用存档标志
    $game_temp.save_calling = true
    # 推进索引
    @index += 1
    # 结束
    return false
  end
  #
  # 游戏结束
  #
  #
  def command_353
    # 设置游戏结束标志
    $game_temp.gameover = true
    # 结束
    return false
  end
  #
  # 返回标题画面
  #
  #
  def command_354
    # 设置返回标题画面标志
    $game_temp.to_title = true
    # 结束
    return false
  end
  #
  # 脚本
  #
  #
  def command_355
    # script 设置第一行
    script = @list[@index].parameters[0] + "\n"
    # 循环
    loop do
      # 下一个事件指令在脚本 2 行以上的情况下
      if @list[@index+1].code == 655
        # 添加到 script 2 行以后
        script += @list[@index+1].parameters[0] + "\n"
      # 事件指令不在脚本 2 行以上的情况下
      else
        # 中断循环
        break
      end
      # 推进索引
      @index += 1
    end
    # 评价
    result = eval(script)
    # 返回值为 false 的情况下
    if result == false
      # 结束
      return false
    end
    # 继续
    return true
  end
end
