#
# ゲーム中のすべてのシーンのスーパークラスです。
#

class Scene_Base
  #
  # メイン処理
  #
  #
  def main
    start                         # 開始処理
    perform_transition            # トランジション実行
    post_start                    # 開始後処理
    Input.update                  # 入力情報を更新
    loop do
      Graphics.update             # ゲーム画面を更新
      Input.update                # 入力情報を更新
      update                      # フレーム更新
      break if $scene != self     # 画面が切り替わったらループを中断
    end
    Graphics.update
    pre_terminate                 # 終了前処理
    Graphics.freeze               # トランジション準備
    terminate                     # 終了処理
  end
  #
  # 開始処理
  #
  #
  def start
  end
  #
  # トランジション実行
  #
  #
  def perform_transition
    Graphics.transition(10)
  end
  #
  # 開始後処理
  #
  #
  def post_start
  end
  #
  # フレーム更新
  #
  #
  def update
  end
  #
  # 終了前処理
  #
  #
  def pre_terminate
  end
  #
  # 終了処理
  #
  #
  def terminate
  end
  #
  # 別画面の背景として使うためのスナップショット作成
  #
  #
  def snapshot_for_background
    $game_temp.background_bitmap.dispose
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    $game_temp.background_bitmap.blur
  end
  #
  # メニュー画面系の背景作成
  #
  #
  def create_menu_background
    @menuback_sprite = Sprite.new
    @menuback_sprite.bitmap = $game_temp.background_bitmap
    @menuback_sprite.color.set(16, 16, 16, 128)
    update_menu_background
  end
  #
  # メニュー画面系の背景解放
  #
  #
  def dispose_menu_background
    @menuback_sprite.dispose
  end
  #
  # メニュー画面系の背景更新
  #
  #
  def update_menu_background
  end
end
