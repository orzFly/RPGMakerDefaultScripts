#encoding:utf-8
#
# 讀檔畫面
#

class Scene_Load < Scene_File
  #
  # 取得說明視窗的文字
  #
  #
  def help_window_text
    Vocab::LoadMessage
  end
  #
  # 取得開始時檔案索引的位置
  #
  #
  def first_savefile_index
    DataManager.latest_savefile_index
  end
  #
  # 確定讀檔檔案
  #
  #
  def on_savefile_ok
    super
    if DataManager.load_game(@index)
      on_load_success
    else
      Sound.play_buzzer
    end
  end
  #
  # 讀檔成功時的處理
  #
  #
  def on_load_success
    Sound.play_load
    fadeout_all
    $game_system.on_after_load
    SceneManager.goto(Scene_Map)
  end
end
