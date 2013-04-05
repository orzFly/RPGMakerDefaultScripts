#
# 游戏中处理全部画面的超级类。
#

class Scene_Base
  #
  # 主处理
  #
  #
  def main
    start                         # 开始处理
    perform_transition            # 执行过渡
    post_start                    # 开始后处理
    Input.update                  # 输入信息的刷新
    loop do
      Graphics.update             # 刷新游戏画面
      Input.update                # 刷新输入信息
      update                      # 刷新画面
      break if $scene != self     # 如果画面切换就中断循环
    end
    Graphics.update
    pre_terminate                 # 结束前处理
    Graphics.freeze               # 准备过渡
    terminate                     # 结束处理
  end
  #
  # 开始处理
  #
  #
  def start
  end
  #
  # 执行过渡
  #
  #
  def perform_transition
    Graphics.transition(10)
  end
  #
  # 开始后处理
  #
  #
  def post_start
  end
  #
  # 刷新画面
  #
  #
  def update
  end
  #
  # 结束前处理
  #
  #
  def pre_terminate
  end
  #
  # 处理结束
  #
  #
  def terminate
  end
  #
  # 为了其他画面的背景而生成截图
  #
  #
  def snapshot_for_background
    $game_temp.background_bitmap.dispose
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    $game_temp.background_bitmap.blur
  end
  #
  # 生成菜单画面背景
  #
  #
  def create_menu_background
    @menuback_sprite = Sprite.new
    @menuback_sprite.bitmap = $game_temp.background_bitmap
    @menuback_sprite.color.set(16, 16, 16, 128)
    update_menu_background
  end
  #
  # 释放菜单画面背景
  #
  #
  def dispose_menu_background
    @menuback_sprite.dispose
  end
  #
  # 刷新菜单画面背景
  #
  #
  def update_menu_background
  end
end