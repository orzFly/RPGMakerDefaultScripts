#encoding:utf-8
#
# 計時器。本類的案例請參考 $game_timer 。
#

class Game_Timer
  #
  # 初始化物件
  #
  #
  def initialize
    @count = 0
    @working = false
  end
  #
  # 更新畫面
  #
  #
  def update
    if @working && @count > 0
      @count -= 1
      on_expire if @count == 0
    end
  end
  #
  # 開始
  #
  #
  def start(count)
    @count = count
    @working = true
  end
  #
  # 停止
  #
  #
  def stop
    @working = false
  end
  #
  # 判定是否正在工作
  #
  #
  def working?
    @working
  end
  #
  # 取得秒數
  #
  #
  def sec
    @count / Graphics.frame_rate
  end
  #
  # 計時器為 0 時的處理
  #
  #
  def on_expire
    BattleManager.abort
  end
end
