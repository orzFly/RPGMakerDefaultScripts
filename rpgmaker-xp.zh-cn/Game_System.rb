#
# 处理系统附属数据的类。也可执行诸如 BGM 管理之类的功能。本类的实例请参考
# $game_system 。
#

class Game_System
  #
  # 定义实例变量
  #
  #
  attr_reader   :map_interpreter          # 地图事件用解释程序
  attr_reader   :battle_interpreter       # 战斗事件用解释程序
  attr_accessor :timer                    # 计时器
  attr_accessor :timer_working            # 计时器执行中的标志
  attr_accessor :save_disabled            # 禁止存档
  attr_accessor :menu_disabled            # 禁止菜单
  attr_accessor :encounter_disabled       # 禁止遇敌
  attr_accessor :message_position         # 文章选项 显示位置
  attr_accessor :message_frame            # 文章选项 窗口外关
  attr_accessor :save_count               # 存档次数
  attr_accessor :magic_number             # 魔法编号
  #
  # 初始化对像
  #
  #
  def initialize
    @map_interpreter = Interpreter.new(0, true)
    @battle_interpreter = Interpreter.new(0, false)
    @timer = 0
    @timer_working = false
    @save_disabled = false
    @menu_disabled = false
    @encounter_disabled = false
    @message_position = 2
    @message_frame = 0
    @save_count = 0
    @magic_number = 0
  end
  #
  # 演奏 BGM
  #
  # bgm : 演奏的 BGM
  #
  def bgm_play(bgm)
    @playing_bgm = bgm
    if bgm != nil and bgm.name != ""
      Audio.bgm_play("Audio/BGM/" + bgm.name, bgm.volume, bgm.pitch)
    else
      Audio.bgm_stop
    end
    Graphics.frame_reset
  end
  #
  # 停止 BGM
  #
  #
  def bgm_stop
    Audio.bgm_stop
  end
  #
  # BGM 的淡出
  #
  # time : 淡出时间 (秒)
  #
  def bgm_fade(time)
    @playing_bgm = nil
    Audio.bgm_fade(time * 1000)
  end
  #
  # 记忆 BGM
  #
  #
  def bgm_memorize
    @memorized_bgm = @playing_bgm
  end
  #
  # 还原 BGM
  #
  #
  def bgm_restore
    bgm_play(@memorized_bgm)
  end
  #
  # 演奏 BGS
  #
  # bgs : 演奏的 BGS
  #
  def bgs_play(bgs)
    @playing_bgs = bgs
    if bgs != nil and bgs.name != ""
      Audio.bgs_play("Audio/BGS/" + bgs.name, bgs.volume, bgs.pitch)
    else
      Audio.bgs_stop
    end
    Graphics.frame_reset
  end
  #
  # BGS 的淡出
  #
  # time : 淡出时间 (秒)
  #
  def bgs_fade(time)
    @playing_bgs = nil
    Audio.bgs_fade(time * 1000)
  end
  #
  # 记忆 BGS
  #
  #
  def bgs_memorize
    @memorized_bgs = @playing_bgs
  end
  #
  # 还原 BGS
  #
  #
  def bgs_restore
    bgs_play(@memorized_bgs)
  end
  #
  # ME 的演奏
  #
  # me : 演奏的 ME
  #
  def me_play(me)
    if me != nil and me.name != ""
      Audio.me_play("Audio/ME/" + me.name, me.volume, me.pitch)
    else
      Audio.me_stop
    end
    Graphics.frame_reset
  end
  #
  # SE 的演奏
  #
  # se : 演奏的 SE
  #
  def se_play(se)
    if se != nil and se.name != ""
      Audio.se_play("Audio/SE/" + se.name, se.volume, se.pitch)
    end
  end
  #
  # 停止 SE 
  #
  #
  def se_stop
    Audio.se_stop
  end
  #
  # 获取演奏中 BGM
  #
  #
  def playing_bgm
    return @playing_bgm
  end
  #
  # 获取演奏中 BGS
  #
  #
  def playing_bgs
    return @playing_bgs
  end
  #
  # 获取窗口外观的文件名
  #
  #
  def windowskin_name
    if @windowskin_name == nil
      return $data_system.windowskin_name
    else
      return @windowskin_name
    end
  end
  #
  # 设置窗口外观的文件名
  #
  # windowskin_name : 新的窗口外观文件名
  #
  def windowskin_name=(windowskin_name)
    @windowskin_name = windowskin_name
  end
  #
  # 获取战斗 BGM
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
  # 设置战斗 BGM
  #
  # battle_bgm : 新的战斗 BGM
  #
  def battle_bgm=(battle_bgm)
    @battle_bgm = battle_bgm
  end
  #
  # 获取战斗结束的 BGM
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
  # 设置战斗结束的 BGM
  #
  # battle_end_me : 新的战斗结束 BGM
  #
  def battle_end_me=(battle_end_me)
    @battle_end_me = battle_end_me
  end
  #
  # 刷新画面
  #
  #
  def update
    # 计时器减 1
    if @timer_working and @timer > 0
      @timer -= 1
    end
  end
end
