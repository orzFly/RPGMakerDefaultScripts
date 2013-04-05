#encoding:utf-8
#
# 存檔畫面
#

class Scene_Save < Scene_File
  #
  # 取得說明視窗的文字
  #
  #
  def help_window_text
    Vocab::SaveMessage
  end
  #
  # 取得開始時檔案索引的位置
  #
  #
  def first_savefile_index
    DataManager.last_savefile_index
  end
  #
  # 確定存檔檔案
  #
  #
  def on_savefile_ok
    super
    if DataManager.save_game(@index)
      on_save_success
    else
      Sound.play_buzzer
    end
  end
  #
  # 存檔成功時的處理
  #
  #
  def on_save_success
    Sound.play_save
    return_scene
  end
end
