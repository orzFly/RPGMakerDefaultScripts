#
# 处理系统相关数据的类。交通工具与BGM也都在这里管理。
# 这个类的实例请参考 $game_system。
#

class Game_System
  #
  # 定义实例变量
  #
  #
  attr_accessor :timer                    # 计时器
  attr_accessor :timer_working            # 计时器执行中的标志
  attr_accessor :save_disabled            # 禁止存档
  attr_accessor :menu_disabled            # 禁止菜单
  attr_accessor :encounter_disabled       # 禁止遇敌
  attr_accessor :save_count               # 存档次数
  attr_accessor :version_id               # 游戏版本 ID
  #
  # 初始化对象
  #
  #
  def initialize
    @timer = 0
    @timer_working = false
    @save_disabled = false
    @menu_disabled = false
    @encounter_disabled = false
    @save_count = 0
    @version_id = 0
  end
  #
  # 取得战斗 BGM
  #
  #
  def battle_bgm
    if @battle_bgm == nil
      return $data_system.battle_bgm
    else
      return @battle_bgm
    end
  end
  #
  # 设定战斗 BGM
  #
  # battle_bgm : 新的战斗 BGM
  #
  def battle_bgm=(battle_bgm)
    @battle_bgm = battle_bgm
  end
  #
  # 取得战斗结束 ME
  #
  #
  def battle_end_me
    if @battle_end_me == nil
      return $data_system.battle_end_me
    else
      return @battle_end_me
    end
  end
  #
  # 设定战斗结束 ME
  #
  # battle_end_me : 新的战斗结束 ME
  #
  def battle_end_me=(battle_end_me)
    @battle_end_me = battle_end_me
  end
  #
  # 刷新画面
  #
  #
  def update
    if @timer_working and @timer > 0
      @timer -= 1
      if @timer == 0 and $game_temp.in_battle     # 如果战斗中计时器为 0
        $game_temp.next_scene = "map"             # 那么就中断战斗
      end
    end
  end
end
