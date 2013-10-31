#
# 处理战斗画面的类。
#

class Scene_Battle
  #
  # 主处理
  #
  #
  def main
    # 初始化战斗用的各种暂时数据
    $game_temp.in_battle = true
    $game_temp.battle_turn = 0
    $game_temp.battle_event_flags.clear
    $game_temp.battle_abort = false
    $game_temp.battle_main_phase = false
    $game_temp.battleback_name = $game_map.battleback_name
    $game_temp.forcing_battler = nil
    # 初始化战斗用事件解释器
    $game_system.battle_interpreter.setup(nil, 0)
    # 准备队伍
    @troop_id = $game_temp.battle_troop_id
    $game_troop.setup(@troop_id)
    # 生成角色命令窗口
    s1 = $data_system.words.attack
    s2 = $data_system.words.skill
    s3 = $data_system.words.guard
    s4 = $data_system.words.item
    @actor_command_window = Window_Command.new(160, [s1, s2, s3, s4])
    @actor_command_window.y = 160
    @actor_command_window.back_opacity = 160
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # 生成其它窗口
    @party_command_window = Window_PartyCommand.new
    @help_window = Window_Help.new
    @help_window.back_opacity = 160
    @help_window.visible = false
    @status_window = Window_BattleStatus.new
    @message_window = Window_Message.new
    # 生成活动块
    @spriteset = Spriteset_Battle.new
    # 初始化等待计数
    @wait_count = 0
    # 执行过渡
    if $data_system.battle_transition == ""
      Graphics.transition(20)
    else
      Graphics.transition(40, "Graphics/Transitions/" +
        $data_system.battle_transition)
    end
    # 开始自由战斗回合
    start_phase1
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 刷新地图
    $game_map.refresh
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @actor_command_window.dispose
    @party_command_window.dispose
    @help_window.dispose
    @status_window.dispose
    @message_window.dispose
    if @skill_window != nil
      @skill_window.dispose
    end
    if @item_window != nil
      @item_window.dispose
    end
    if @result_window != nil
      @result_window.dispose
    end
    # 释放活动块
    @spriteset.dispose
    # 标题画面切换中的情况
    if $scene.is_a?(Scene_Title)
      # 淡入淡出画面
      Graphics.transition
      Graphics.freeze
    end
    # 战斗测试或者游戏结束以外的画面切换中的情况
    if $BTEST and not $scene.is_a?(Scene_Gameover)
      $scene = nil
    end
  end
  #
  # 胜负判定
  #
  #
  def judge
    # 全灭判定是真、并且同伴人数为 0 的情况下
    if $game_party.all_dead? or $game_party.actors.size == 0
      # 允许失败的情况下
      if $game_temp.battle_can_lose
        # 还原为战斗开始前的 BGM
        $game_system.bgm_play($game_temp.map_bgm)
        # 战斗结束
        battle_end(2)
        # 返回 true
        return true
      end
      # 设置游戏结束标志
      $game_temp.gameover = true
      # 返回 true
      return true
    end
    # 如果存在任意 1 个敌人就返回 false
    for enemy in $game_troop.enemies
      if enemy.exist?
        return false
      end
    end
    # 开始结束战斗回合 (胜利)
    start_phase5
    # 返回 true
    return true
  end
  #
  # 战斗结束
  #
  # result : 結果 (0:胜利 1:失败 2:逃跑)
  #
  def battle_end(result)
    # 清除战斗中标志
    $game_temp.in_battle = false
    # 清除全体同伴的行动
    $game_party.clear_actions
    # 解除战斗用状态
    for actor in $game_party.actors
      actor.remove_states_battle
    end
    # 清除敌人
    $game_troop.enemies.clear
    # 调用战斗返回调用
    if $game_temp.battle_proc != nil
      $game_temp.battle_proc.call(result)
      $game_temp.battle_proc = nil
    end
    # 切换到地图画面
    $scene = Scene_Map.new
  end
  #
  # 设置战斗事件
  #
  #
  def setup_battle_event
    # 正在执行战斗事件的情况下
    if $game_system.battle_interpreter.running?
      return
    end
    # 搜索全部页的战斗事件
    for index in 0...$data_troops[@troop_id].pages.size
      # 获取事件页
      page = $data_troops[@troop_id].pages[index]
      # 事件条件可以参考 c
      c = page.condition
      # 没有指定任何条件的情况下转到下一页
      unless c.turn_valid or c.enemy_valid or
             c.actor_valid or c.switch_valid
        next
      end
      # 执行完毕的情况下转到下一页
      if $game_temp.battle_event_flags[index]
        next
      end
      # 确认回合条件
      if c.turn_valid
        n = $game_temp.battle_turn
        a = c.turn_a
        b = c.turn_b
        if (b == 0 and n != a) or
           (b > 0 and (n < 1 or n < a or n % b != a % b))
          next
        end
      end
      # 确认敌人条件
      if c.enemy_valid
        enemy = $game_troop.enemies[c.enemy_index]
        if enemy == nil or enemy.hp * 100.0 / enemy.maxhp > c.enemy_hp
          next
        end
      end
      # 确认角色条件
      if c.actor_valid
        actor = $game_actors[c.actor_id]
        if actor == nil or actor.hp * 100.0 / actor.maxhp > c.actor_hp
          next
        end
      end
      # 确认开关条件
      if c.switch_valid
        if $game_switches[c.switch_id] == false
          next
        end
      end
      # 设置事件
      $game_system.battle_interpreter.setup(page.list, 0)
      # 本页的范围是 [战斗] 或 [回合] 的情况下
      if page.span <= 1
        # 设置执行结束标志
        $game_temp.battle_event_flags[index] = true
      end
      return
    end
  end
  #
  # 刷新画面
  #
  #
  def update
    # 执行战斗事件中的情况下
    if $game_system.battle_interpreter.running?
      # 刷新解释器
      $game_system.battle_interpreter.update
      # 强制行动的战斗者不存在的情况下
      if $game_temp.forcing_battler == nil
        # 执行战斗事件结束的情况下
        unless $game_system.battle_interpreter.running?
          # 继续战斗的情况下、再执行战斗事件的设置
          unless judge
            setup_battle_event
          end
        end
        # 如果不是结束战斗回合的情况下
        if @phase != 5
          # 刷新状态窗口
          @status_window.refresh
        end
      end
    end
    # 系统 (计时器)、刷新画面
    $game_system.update
    $game_screen.update
    # 计时器为 0 的情况下
    if $game_system.timer_working and $game_system.timer == 0
      # 中断战斗
      $game_temp.battle_abort = true
    end
    # 刷新窗口
    @help_window.update
    @party_command_window.update
    @actor_command_window.update
    @status_window.update
    @message_window.update
    # 刷新活动块
    @spriteset.update
    # 处理过渡中的情况下
    if $game_temp.transition_processing
      # 清除处理过渡中标志
      $game_temp.transition_processing = false
      # 执行过渡
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
    # 显示信息窗口中的情况下
    if $game_temp.message_window_showing
      return
    end
    # 显示效果中的情况下
    if @spriteset.effect?
      return
    end
    # 游戏结束的情况下
    if $game_temp.gameover
      # 切换到游戏结束画面
      $scene = Scene_Gameover.new
      return
    end
    # 返回标题画面的情况下
    if $game_temp.to_title
      # 切换到标题画面
      $scene = Scene_Title.new
      return
    end
    # 中断战斗的情况下
    if $game_temp.battle_abort
      # 还原为战斗前的 BGM
      $game_system.bgm_play($game_temp.map_bgm)
      # 战斗结束
      battle_end(1)
      return
    end
    # 等待中的情况下
    if @wait_count > 0
      # 减少等待计数
      @wait_count -= 1
      return
    end
    # 强制行动的角色存在、
    # 并且战斗事件正在执行的情况下
    if $game_temp.forcing_battler == nil and
       $game_system.battle_interpreter.running?
      return
    end
    # 回合分支
    case @phase
    when 1  # 自由战斗回合
      update_phase1
    when 2  # 同伴命令回合
      update_phase2
    when 3  # 角色命令回合
      update_phase3
    when 4  # 主回合
      update_phase4
    when 5  # 战斗结束回合
      update_phase5
    end
  end
end


#
# 处理战斗画面的类。
#

class Scene_Battle
  #
  # 开始自由战斗回合
  #
  #
  def start_phase1
    # 转移到回合 1
    @phase = 1
    # 清除全体同伴的行动
    $game_party.clear_actions
    # 设置战斗事件
    setup_battle_event
  end
  #
  # 刷新画面 (自由战斗回合)
  #
  #
  def update_phase1
    # 胜败判定
    if judge
      # 胜利或者失败的情况下 : 过程结束
      return
    end
    # 开始同伴命令回合
    start_phase2
  end
  #
  # 开始同伴命令回合
  #
  #
  def start_phase2
    # 转移到回合 2
    @phase = 2
    # 设置角色为非选择状态
    @actor_index = -1
    @active_battler = nil
    # 有效化同伴指令窗口
    @party_command_window.active = true
    @party_command_window.visible = true
    # 无效化角色指令窗口
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # 清除主回合标志
    $game_temp.battle_main_phase = false
    # 清除全体同伴的行动
    $game_party.clear_actions
    # 不能输入命令的情况下
    unless $game_party.inputable?
      # 开始主回合
      start_phase4
    end
  end
  #
  # 刷新画面 (同伴命令回合)
  #
  #
  def update_phase2
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 同伴指令窗口光标位置分支
      case @party_command_window.index
      when 0  # 战斗
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 开始角色的命令回合
        start_phase3
      when 1  # 逃跑
        # 不能逃跑的情况下
        if $game_temp.battle_can_escape == false
          # 演奏冻结 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 逃走处理
        update_phase2_escape
      end
      return
    end
  end
  #
  # 画面更新 (同伴指令回合 : 逃跑)
  #
  #
  def update_phase2_escape
    # 计算敌人速度的平均值
    enemies_agi = 0
    enemies_number = 0
    for enemy in $game_troop.enemies
      if enemy.exist?
        enemies_agi += enemy.agi
        enemies_number += 1
      end
    end
    if enemies_number > 0
      enemies_agi /= enemies_number
    end
    # 计算角色速度的平均值
    actors_agi = 0
    actors_number = 0
    for actor in $game_party.actors
      if actor.exist?
        actors_agi += actor.agi
        actors_number += 1
      end
    end
    if actors_number > 0
      actors_agi /= actors_number
    end
    # 逃跑成功判定
    success = rand(100) < 50 * actors_agi / enemies_agi
    # 成功逃跑的情况下
    if success
      # 演奏逃跑 SE
      $game_system.se_play($data_system.escape_se)
      # 还原为战斗开始前的 BGM
      $game_system.bgm_play($game_temp.map_bgm)
      # 战斗结束
      battle_end(1)
    # 逃跑失败的情况下
    else
      # 清除全体同伴的行动
      $game_party.clear_actions
      # 开始主回合
      start_phase4
    end
  end
  #
  # 开始结束战斗回合
  #
  #
  def start_phase5
    # 转移到回合 5
    @phase = 5
    # 演奏战斗结束 ME
    $game_system.me_play($game_system.battle_end_me)
    # 还原为战斗开始前的 BGM
    $game_system.bgm_play($game_temp.map_bgm)
    # 初始化 EXP、金钱、宝物
    exp = 0
    gold = 0
    treasures = []
    # 循环
    for enemy in $game_troop.enemies
      # 敌人不是隐藏状态的情况下
      unless enemy.hidden
        # 获得 EXP、增加金钱
        exp += enemy.exp
        gold += enemy.gold
        # 出现宝物判定
        if rand(100) < enemy.treasure_prob
          if enemy.item_id > 0
            treasures.push($data_items[enemy.item_id])
          end
          if enemy.weapon_id > 0
            treasures.push($data_weapons[enemy.weapon_id])
          end
          if enemy.armor_id > 0
            treasures.push($data_armors[enemy.armor_id])
          end
        end
      end
    end
    # 限制宝物数为 6 个
    treasures = treasures[0..5]
    # 获得 EXP
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      if actor.cant_get_exp? == false
        last_level = actor.level
        actor.exp += exp
        if actor.level > last_level
          @status_window.level_up(i)
        end
      end
    end
    # 获得金钱
    $game_party.gain_gold(gold)
    # 获得宝物
    for item in treasures
      case item
      when RPG::Item
        $game_party.gain_item(item.id, 1)
      when RPG::Weapon
        $game_party.gain_weapon(item.id, 1)
      when RPG::Armor
        $game_party.gain_armor(item.id, 1)
      end
    end
    # 生成战斗结果窗口
    @result_window = Window_BattleResult.new(exp, gold, treasures)
    # 设置等待计数
    @phase5_wait_count = 100
  end
  #
  # 画面更新 (结束战斗回合)
  #
  #
  def update_phase5
    # 等待计数大于 0 的情况下
    if @phase5_wait_count > 0
      # 减少等待计数
      @phase5_wait_count -= 1
      # 等待计数为 0 的情况下
      if @phase5_wait_count == 0
        # 显示结果窗口
        @result_window.visible = true
        # 清除主回合标志
        $game_temp.battle_main_phase = false
        # 刷新状态窗口
        @status_window.refresh
      end
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 战斗结束
      battle_end(0)
    end
  end
end


#
# 处理战斗画面的类。
#

class Scene_Battle
  #
  # 开始角色命令回合
  #
  #
  def start_phase3
    # 转移到回合 3
    @phase = 3
    # 设置觉得为非选择状态
    @actor_index = -1
    @active_battler = nil
    # 输入下一个角色的命令
    phase3_next_actor
  end
  #
  # 转到输入下一个角色的命令
  #
  #
  def phase3_next_actor
    # 循环
    begin
      # 角色的明灭效果 OFF
      if @active_battler != nil
        @active_battler.blink = false
      end
      # 最后的角色的情况
      if @actor_index == $game_party.actors.size-1
        # 开始主回合
        start_phase4
        return
      end
      # 推进角色索引
      @actor_index += 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    # 如果角色是在无法接受指令的状态就再试
    end until @active_battler.inputable?
    # 设置角色的命令窗口
    phase3_setup_command_window
  end
  #
  # 转向前一个角色的命令输入
  #
  #
  def phase3_prior_actor
    # 循环
    begin
      # 角色的明灭效果 OFF
      if @active_battler != nil
        @active_battler.blink = false
      end
      # 最初的角色的情况下
      if @actor_index == 0
        # 开始同伴指令回合
        start_phase2
        return
      end
      # 返回角色索引
      @actor_index -= 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    # 如果角色是在无法接受指令的状态就再试
    end until @active_battler.inputable?
    # 设置角色的命令窗口
    phase3_setup_command_window
  end
  #
  # 设置角色指令窗口
  #
  #
  def phase3_setup_command_window
    # 同伴指令窗口无效化
    @party_command_window.active = false
    @party_command_window.visible = false
    # 角色指令窗口无效化
    @actor_command_window.active = true
    @actor_command_window.visible = true
    # 设置角色指令窗口的位置
    @actor_command_window.x = @actor_index * 160
    # 设置索引为 0
    @actor_command_window.index = 0
  end
  #
  # 刷新画面 (角色命令回合)
  #
  #
  def update_phase3
    # 敌人光标有效的情况下
    if @enemy_arrow != nil
      update_phase3_enemy_select
    # 角色光标有效的情况下
    elsif @actor_arrow != nil
      update_phase3_actor_select
    # 特技窗口有效的情况下
    elsif @skill_window != nil
      update_phase3_skill_select
    # 物品窗口有效的情况下
    elsif @item_window != nil
      update_phase3_item_select
    # 角色指令窗口有效的情况下
    elsif @actor_command_window.active
      update_phase3_basic_command
    end
  end
  #
  # 刷新画面 (角色命令回合 : 基本命令)
  #
  #
  def update_phase3_basic_command
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 转向前一个角色的指令输入
      phase3_prior_actor
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 角色指令窗口光标位置分之
      case @actor_command_window.index
      when 0  # 攻击
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 设置行动
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
        # 开始选择敌人
        start_enemy_select
      when 1  # 特技
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 设置行动
        @active_battler.current_action.kind = 1
        # 开始选择特技
        start_skill_select
      when 2  # 防御
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 设置行动
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 1
        # 转向下一位角色的指令输入
        phase3_next_actor
      when 3  # 物品
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 设置行动
        @active_battler.current_action.kind = 2
        # 开始选择物品
        start_item_select
      end
      return
    end
  end
  #
  # 刷新画面 (角色命令回合 : 选择特技)
  #
  #
  def update_phase3_skill_select
    # 设置特技窗口为可视状态
    @skill_window.visible = true
    # 刷新特技窗口
    @skill_window.update
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 结束特技选择
      end_skill_select
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 获取特技选择窗口现在选择的特技的数据
      @skill = @skill_window.skill
      # 无法使用的情况下
      if @skill == nil or not @active_battler.skill_can_use?(@skill.id)
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 设置行动
      @active_battler.current_action.skill_id = @skill.id
      # 设置特技窗口为不可见状态
      @skill_window.visible = false
      # 效果范围是敌单体的情况下
      if @skill.scope == 1
        # 开始选择敌人
        start_enemy_select
      # 效果范围是我方单体的情况下
      elsif @skill.scope == 3 or @skill.scope == 5
        # 开始选择角色
        start_actor_select
      # 效果范围不是单体的情况下
      else
        # 选择特技结束
        end_skill_select
        # 转到下一位角色的指令输入
        phase3_next_actor
      end
      return
    end
  end
  #
  # 刷新画面 (角色命令回合 : 选择物品)
  #
  #
  def update_phase3_item_select
    # 设置物品窗口为可视状态
    @item_window.visible = true
    # 刷新物品窗口
    @item_window.update
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 选择物品结束
      end_item_select
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 获取物品窗口现在选择的物品资料
      @item = @item_window.item
      # 无法使用的情况下
      unless $game_party.item_can_use?(@item.id)
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 设置行动
      @active_battler.current_action.item_id = @item.id
      # 设置物品窗口为不可见状态
      @item_window.visible = false
      # 效果范围是敌单体的情况下
      if @item.scope == 1
        # 开始选择敌人
        start_enemy_select
      # 效果范围是我方单体的情况下
      elsif @item.scope == 3 or @item.scope == 5
        # 开始选择角色
        start_actor_select
      # 效果范围不是单体的情况下
      else
        # 物品选择结束
        end_item_select
        # 转到下一位角色的指令输入
        phase3_next_actor
      end
      return
    end
  end
  #
  # 刷新画面画面 (角色命令回合 : 选择敌人)
  #
  #
  def update_phase3_enemy_select
    # 刷新敌人箭头
    @enemy_arrow.update
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 选择敌人结束
      end_enemy_select
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 设置行动
      @active_battler.current_action.target_index = @enemy_arrow.index
      # 选择敌人结束
      end_enemy_select
      # 显示特技窗口中的情况下
      if @skill_window != nil
        # 结束特技选择
        end_skill_select
      end
      # 显示物品窗口的情况下
      if @item_window != nil
        # 结束物品选择
        end_item_select
      end
      # 转到下一位角色的指令输入
      phase3_next_actor
    end
  end
  #
  # 画面更新 (角色指令回合 : 选择角色)
  #
  #
  def update_phase3_actor_select
    # 刷新角色箭头
    @actor_arrow.update
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 选择角色结束
      end_actor_select
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 设置行动
      @active_battler.current_action.target_index = @actor_arrow.index
      # 选择角色结束
      end_actor_select
      # 显示特技窗口中的情况下
      if @skill_window != nil
        # 结束特技选择
        end_skill_select
      end
      # 显示物品窗口的情况下
      if @item_window != nil
        # 结束物品选择
        end_item_select
      end
      # 转到下一位角色的指令输入
      phase3_next_actor
    end
  end
  #
  # 开始选择敌人
  #
  #
  def start_enemy_select
    # 生成敌人箭头
    @enemy_arrow = Arrow_Enemy.new(@spriteset.viewport1)
    # 关联帮助窗口
    @enemy_arrow.help_window = @help_window
    # 无效化角色指令窗口
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #
  # 结束选择敌人
  #
  #
  def end_enemy_select
    # 释放敌人箭头
    @enemy_arrow.dispose
    @enemy_arrow = nil
    # 指令为 [战斗] 的情况下
    if @actor_command_window.index == 0
      # 有效化角色指令窗口
      @actor_command_window.active = true
      @actor_command_window.visible = true
      # 隐藏帮助窗口
      @help_window.visible = false
    end
  end
  #
  # 开始选择角色
  #
  #
  def start_actor_select
    # 生成角色箭头
    @actor_arrow = Arrow_Actor.new(@spriteset.viewport2)
    @actor_arrow.index = @actor_index
    # 关联帮助窗口
    @actor_arrow.help_window = @help_window
    # 无效化角色指令窗口
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #
  # 结束选择角色
  #
  #
  def end_actor_select
    # 释放角色箭头
    @actor_arrow.dispose
    @actor_arrow = nil
  end
  #
  # 开始选择特技
  #
  #
  def start_skill_select
    # 生成特技窗口
    @skill_window = Window_Skill.new(@active_battler)
    # 关联帮助窗口
    @skill_window.help_window = @help_window
    # 无效化角色指令窗口
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #
  # 选择特技结束
  #
  #
  def end_skill_select
    # 释放特技窗口
    @skill_window.dispose
    @skill_window = nil
    # 隐藏帮助窗口
    @help_window.visible = false
    # 有效化角色指令窗口
    @actor_command_window.active = true
    @actor_command_window.visible = true
  end
  #
  # 开始选择物品
  #
  #
  def start_item_select
    # 生成物品窗口
    @item_window = Window_Item.new
    # 关联帮助窗口
    @item_window.help_window = @help_window
    # 无效化角色指令窗口
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #
  # 结束选择物品
  #
  #
  def end_item_select
    # 释放物品窗口
    @item_window.dispose
    @item_window = nil
    # 隐藏帮助窗口
    @help_window.visible = false
    # 有效化角色指令窗口
    @actor_command_window.active = true
    @actor_command_window.visible = true
  end
end


#
# 处理战斗画面的类。
#

class Scene_Battle
  #
  # 开始主回合
  #
  #
  def start_phase4
    # 转移到回合 4
    @phase = 4
    # 回合数计数
    $game_temp.battle_turn += 1
    # 搜索全页的战斗事件
    for index in 0...$data_troops[@troop_id].pages.size
      # 获取事件页
      page = $data_troops[@troop_id].pages[index]
      # 本页的范围是 [回合] 的情况下
      if page.span == 1
        # 设置已经执行标志
        $game_temp.battle_event_flags[index] = false
      end
    end
    # 设置角色为非选择状态
    @actor_index = -1
    @active_battler = nil
    # 有效化同伴指令窗口
    @party_command_window.active = false
    @party_command_window.visible = false
    # 无效化角色指令窗口
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # 设置主回合标志
    $game_temp.battle_main_phase = true
    # 生成敌人行动
    for enemy in $game_troop.enemies
      enemy.make_action
    end
    # 生成行动顺序
    make_action_orders
    # 移动到步骤 1
    @phase4_step = 1
  end
  #
  # 生成行动循序
  #
  #
  def make_action_orders
    # 初始化序列 @action_battlers
    @action_battlers = []
    # 添加敌人到 `@action_battlers` 序列
    for enemy in $game_troop.enemies
      @action_battlers.push(enemy)
    end
    # 添加角色到 `@action_battlers` 序列
    for actor in $game_party.actors
      @action_battlers.push(actor)
    end
    # 确定全体的行动速度
    for battler in @action_battlers
      battler.make_action_speed
    end
    # 按照行动速度从大到小排列
    @action_battlers.sort! {|a,b|
      b.current_action.speed - a.current_action.speed }
  end
  #
  # 刷新画面 (主回合)
  #
  #
  def update_phase4
    case @phase4_step
    when 1
      update_phase4_step1
    when 2
      update_phase4_step2
    when 3
      update_phase4_step3
    when 4
      update_phase4_step4
    when 5
      update_phase4_step5
    when 6
      update_phase4_step6
    end
  end
  #
  # 刷新画面 (主回合步骤 1 : 准备行动)
  #
  #
  def update_phase4_step1
    # 隐藏帮助窗口
    @help_window.visible = false
    # 判定胜败
    if judge
      # 胜利或者失败的情况下 : 过程结束
      return
    end
    # 强制行动的战斗者不存在的情况下
    if $game_temp.forcing_battler == nil
      # 设置战斗事件
      setup_battle_event
      # 执行战斗事件中的情况下
      if $game_system.battle_interpreter.running?
        return
      end
    end
    # 强制行动的战斗者存在的情况下
    if $game_temp.forcing_battler != nil
      # 在头部添加后移动
      @action_battlers.delete($game_temp.forcing_battler)
      @action_battlers.unshift($game_temp.forcing_battler)
    end
    # 未行动的战斗者不存在的情况下 (全员已经行动)
    if @action_battlers.size == 0
      # 开始同伴命令回合
      start_phase2
      return
    end
    # 初始化动画 ID 和公共事件 ID
    @animation1_id = 0
    @animation2_id = 0
    @common_event_id = 0
    # 未行动的战斗者移动到序列的头部
    @active_battler = @action_battlers.shift
    # 如果已经在战斗之外的情况下
    if @active_battler.index == nil
      return
    end
    # 连续伤害
    if @active_battler.hp > 0 and @active_battler.slip_damage?
      @active_battler.slip_damage_effect
      @active_battler.damage_pop = true
    end
    # 自然解除状态
    @active_battler.remove_states_auto
    # 刷新状态窗口
    @status_window.refresh
    # 移至步骤 2
    @phase4_step = 2
  end
  #
  # 刷新画面 (主回合步骤 2 : 开始行动)
  #
  #
  def update_phase4_step2
    # 如果不是强制行动
    unless @active_battler.current_action.forcing
      # 限制为 [敌人为普通攻击] 或 [我方为普通攻击] 的情况下
      if @active_battler.restriction == 2 or @active_battler.restriction == 3
        # 设置行动为攻击
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
      end
      # 限制为 [不能行动] 的情况下
      if @active_battler.restriction == 4
        # 清除行动强制对像的战斗者
        $game_temp.forcing_battler = nil
        # 移至步骤 1
        @phase4_step = 1
        return
      end
    end
    # 清除对像战斗者
    @target_battlers = []
    # 行动种类分支
    case @active_battler.current_action.kind
    when 0  # 基本
      make_basic_action_result
    when 1  # 特技
      make_skill_action_result
    when 2  # 物品
      make_item_action_result
    end
    # 移至步骤 3
    if @phase4_step == 2
      @phase4_step = 3
    end
  end
  #
  # 生成基本行动结果
  #
  #
  def make_basic_action_result
    # 攻击的情况下
    if @active_battler.current_action.basic == 0
      # 设置攻击 ID
      @animation1_id = @active_battler.animation1_id
      @animation2_id = @active_battler.animation2_id
      # 行动方的战斗者是敌人的情况下
      if @active_battler.is_a?(Game_Enemy)
        if @active_battler.restriction == 3
          target = $game_troop.random_target_enemy
        elsif @active_battler.restriction == 2
          target = $game_party.random_target_actor
        else
          index = @active_battler.current_action.target_index
          target = $game_party.smooth_target_actor(index)
        end
      end
      # 行动方的战斗者是角色的情况下
      if @active_battler.is_a?(Game_Actor)
        if @active_battler.restriction == 3
          target = $game_party.random_target_actor
        elsif @active_battler.restriction == 2
          target = $game_troop.random_target_enemy
        else
          index = @active_battler.current_action.target_index
          target = $game_troop.smooth_target_enemy(index)
        end
      end
      # 设置对像方的战斗者序列
      @target_battlers = [target]
      # 应用通常攻击效果
      for target in @target_battlers
        target.attack_effect(@active_battler)
      end
      return
    end
    # 防御的情况下
    if @active_battler.current_action.basic == 1
      # 帮助窗口显示"防御"
      @help_window.set_text($data_system.words.guard, 1)
      return
    end
    # 逃跑的情况下
    if @active_battler.is_a?(Game_Enemy) and
       @active_battler.current_action.basic == 2
      # 帮助窗口显示"逃跑"
      @help_window.set_text("逃跑", 1)
      # 逃跑
      @active_battler.escape
      return
    end
    # 什么也不做的情况下
    if @active_battler.current_action.basic == 3
      # 清除强制行动对像的战斗者
      $game_temp.forcing_battler = nil
      # 移至步骤 1
      @phase4_step = 1
      return
    end
  end
  #
  # 设置物品或特技对像方的战斗者
  #
  # scope : 特技或者是物品的范围
  #
  def set_target_battlers(scope)
    # 行动方的战斗者是敌人的情况下
    if @active_battler.is_a?(Game_Enemy)
      # 效果范围分支
      case scope
      when 1  # 敌单体
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 2  # 敌全体
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 3  # 我方单体
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 4  # 我方全体
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy)
          end
        end
      when 5  # 我方单体 (HP 0) 
        index = @active_battler.current_action.target_index
        enemy = $game_troop.enemies[index]
        if enemy != nil and enemy.hp0?
          @target_battlers.push(enemy)
        end
      when 6  # 我方全体 (HP 0) 
        for enemy in $game_troop.enemies
          if enemy != nil and enemy.hp0?
            @target_battlers.push(enemy)
          end
        end
      when 7  # 使用者
        @target_battlers.push(@active_battler)
      end
    end
    # 行动方的战斗者是角色的情况下
    if @active_battler.is_a?(Game_Actor)
      # 效果范围分支
      case scope
      when 1  # 敌单体
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 2  # 敌全体
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy)
          end
        end
      when 3  # 我方单体
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 4  # 我方全体
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 5  # 我方单体 (HP 0) 
        index = @active_battler.current_action.target_index
        actor = $game_party.actors[index]
        if actor != nil and actor.hp0?
          @target_battlers.push(actor)
        end
      when 6  # 我方全体 (HP 0) 
        for actor in $game_party.actors
          if actor != nil and actor.hp0?
            @target_battlers.push(actor)
          end
        end
      when 7  # 使用者
        @target_battlers.push(@active_battler)
      end
    end
  end
  #
  # 生成特技行动结果
  #
  #
  def make_skill_action_result
    # 获取特技
    @skill = $data_skills[@active_battler.current_action.skill_id]
    # 如果不是强制行动
    unless @active_battler.current_action.forcing
      # 因为 SP 耗尽而无法使用的情况下
      unless @active_battler.skill_can_use?(@skill.id)
        # 清除强制行动对像的战斗者
        $game_temp.forcing_battler = nil
        # 移至步骤 1
        @phase4_step = 1
        return
      end
    end
    # 消耗 SP
    @active_battler.sp -= @skill.sp_cost
    # 刷新状态窗口
    @status_window.refresh
    # 在帮助窗口显示特技名
    @help_window.set_text(@skill.name, 1)
    # 设置动画 ID
    @animation1_id = @skill.animation1_id
    @animation2_id = @skill.animation2_id
    # 设置公共事件 ID
    @common_event_id = @skill.common_event_id
    # 设置对像侧战斗者
    set_target_battlers(@skill.scope)
    # 应用特技效果
    for target in @target_battlers
      target.skill_effect(@active_battler, @skill)
    end
  end
  #
  # 生成物品行动结果
  #
  #
  def make_item_action_result
    # 获取物品
    @item = $data_items[@active_battler.current_action.item_id]
    # 因为物品耗尽而无法使用的情况下
    unless $game_party.item_can_use?(@item.id)
      # 移至步骤 1
      @phase4_step = 1
      return
    end
    # 消耗品的情况下
    if @item.consumable
      # 使用的物品减 1
      $game_party.lose_item(@item.id, 1)
    end
    # 在帮助窗口显示物品名
    @help_window.set_text(@item.name, 1)
    # 设置动画 ID
    @animation1_id = @item.animation1_id
    @animation2_id = @item.animation2_id
    # 设置公共事件 ID
    @common_event_id = @item.common_event_id
    # 确定对像
    index = @active_battler.current_action.target_index
    target = $game_party.smooth_target_actor(index)
    # 设置对像侧战斗者
    set_target_battlers(@item.scope)
    # 应用物品效果
    for target in @target_battlers
      target.item_effect(@item)
    end
  end
  #
  # 刷新画面 (主回合步骤 3 : 行动方动画)
  #
  #
  def update_phase4_step3
    # 行动方动画 (ID 为 0 的情况下是白色闪烁)
    if @animation1_id == 0
      @active_battler.white_flash = true
    else
      @active_battler.animation_id = @animation1_id
      @active_battler.animation_hit = true
    end
    # 移至步骤 4
    @phase4_step = 4
  end
  #
  # 刷新画面 (主回合步骤 4 : 对像方动画)
  #
  #
  def update_phase4_step4
    # 对像方动画
    for target in @target_battlers
      target.animation_id = @animation2_id
      target.animation_hit = (target.damage != "Miss")
    end
    # 限制动画长度、最低 8 帧
    @wait_count = 8
    # 移至步骤 5
    @phase4_step = 5
  end
  #
  # 刷新画面 (主回合步骤 5 : 显示伤害)
  #
  #
  def update_phase4_step5
    # 隐藏帮助窗口
    @help_window.visible = false
    # 刷新状态窗口
    @status_window.refresh
    # 显示伤害
    for target in @target_battlers
      if target.damage != nil
        target.damage_pop = true
      end
    end
    # 移至步骤 6
    @phase4_step = 6
  end
  #
  # 刷新画面 (主回合步骤 6 : 刷新)
  #
  #
  def update_phase4_step6
    # 清除强制行动对像的战斗者
    $game_temp.forcing_battler = nil
    # 公共事件 ID 有效的情况下
    if @common_event_id > 0
      # 设置事件
      common_event = $data_common_events[@common_event_id]
      $game_system.battle_interpreter.setup(common_event.list, 0)
    end
    # 移至步骤 1
    @phase4_step = 1
  end
end
