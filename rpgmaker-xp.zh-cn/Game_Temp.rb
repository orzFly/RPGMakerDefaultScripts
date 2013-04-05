#
# 在没有存档的情况下，处理临时数据的类。这个类的实例请参考
# $game_temp 。
#

class Game_Temp
  #
  # 定义实例变量
  #
  #
  attr_accessor :map_bgm                  # 地图画面 BGM (战斗时记忆用)
  attr_accessor :message_text             # 信息文章
  attr_accessor :message_proc             # 信息 返回调用 (Proc)
  attr_accessor :choice_start             # 选择项 开始行
  attr_accessor :choice_max               # 选择项 项目数
  attr_accessor :choice_cancel_type       # 选择项 取消的情况
  attr_accessor :choice_proc              # 选择项 返回调用 (Proc)
  attr_accessor :num_input_start          # 输入数值 开始行
  attr_accessor :num_input_variable_id    # 输入数值 变量 ID
  attr_accessor :num_input_digits_max     # 输入数值 位数
  attr_accessor :message_window_showing   # 显示信息窗口
  attr_accessor :common_event_id          # 公共事件 ID
  attr_accessor :in_battle                # 战斗中的标志
  attr_accessor :battle_calling           # 调用战斗的标志
  attr_accessor :battle_troop_id          # 战斗 队伍 ID
  attr_accessor :battle_can_escape        # 战斗中 允许逃跑 ID
  attr_accessor :battle_can_lose          # 战斗中 允许失败 ID
  attr_accessor :battle_proc              # 战斗 返回调用 (Proc)
  attr_accessor :battle_turn              # 战斗 回合数
  attr_accessor :battle_event_flags       # 战斗 事件执行执行完毕的标志
  attr_accessor :battle_abort             # 战斗 中断标志
  attr_accessor :battle_main_phase        # 战斗 状态标志
  attr_accessor :battleback_name          # 战斗背景 文件名
  attr_accessor :forcing_battler          # 强制行动的战斗者
  attr_accessor :shop_calling             # 调用商店的标志
  attr_accessor :shop_goods               # 商店 商品列表
  attr_accessor :name_calling             # 输入名称 调用标志
  attr_accessor :name_actor_id            # 输入名称 角色 ID
  attr_accessor :name_max_char            # 输入名称 最大字数
  attr_accessor :menu_calling             # 菜单 调用标志
  attr_accessor :menu_beep                # 菜单 SE 演奏标志
  attr_accessor :save_calling             # 存档 调用标志
  attr_accessor :debug_calling            # 调试 调用标志
  attr_accessor :player_transferring      # 主角 场所移动标志
  attr_accessor :player_new_map_id        # 主角 移动目标地图 ID
  attr_accessor :player_new_x             # 主角 移动目标 X 坐标
  attr_accessor :player_new_y             # 主角 移动目标 Y 坐标
  attr_accessor :player_new_direction     # 主角 移动目标 朝向
  attr_accessor :transition_processing    # 过渡处理中标志
  attr_accessor :transition_name          # 过渡 文件名
  attr_accessor :gameover                 # 游戏结束标志
  attr_accessor :to_title                 # 返回标题画面标志
  attr_accessor :last_file_index          # 最后存档的文件编号
  attr_accessor :debug_top_row            # 调试画面 保存状态用
  attr_accessor :debug_index              # 调试画面 保存状态用
  #
  # 初始化对像
  #
  #
  def initialize
    @map_bgm = nil
    @message_text = nil
    @message_proc = nil
    @choice_start = 99
    @choice_max = 0
    @choice_cancel_type = 0
    @choice_proc = nil
    @num_input_start = 99
    @num_input_variable_id = 0
    @num_input_digits_max = 0
    @message_window_showing = false
    @common_event_id = 0
    @in_battle = false
    @battle_calling = false
    @battle_troop_id = 0
    @battle_can_escape = false
    @battle_can_lose = false
    @battle_proc = nil
    @battle_turn = 0
    @battle_event_flags = {}
    @battle_abort = false
    @battle_main_phase = false
    @battleback_name = ''
    @forcing_battler = nil
    @shop_calling = false
    @shop_id = 0
    @name_calling = false
    @name_actor_id = 0
    @name_max_char = 0
    @menu_calling = false
    @menu_beep = false
    @save_calling = false
    @debug_calling = false
    @player_transferring = false
    @player_new_map_id = 0
    @player_new_x = 0
    @player_new_y = 0
    @player_new_direction = 0
    @transition_processing = false
    @transition_name = ""
    @gameover = false
    @to_title = false
    @last_file_index = 0
    @debug_top_row = 0
    @debug_index = 0
  end
end
