#
# メニュー画面の処理を行うクラスです。
#

class Scene_Menu < Scene_Base
  #
  # オブジェクト初期化
  #
  # menu_index : コマンドのカーソル初期位置
  #
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #
  # 開始処理
  #
  #
  def start
    super
    create_menu_background
    create_command_window
    @gold_window = Window_Gold.new(0, 360)
    @status_window = Window_MenuStatus.new(160, 0)
  end
  #
  # 終了処理
  #
  #
  def terminate
    super
    dispose_menu_background
    @command_window.dispose
    @gold_window.dispose
    @status_window.dispose
  end
  #
  # フレーム更新
  #
  #
  def update
    super
    update_menu_background
    @command_window.update
    @gold_window.update
    @status_window.update
    if @command_window.active
      update_command_selection
    elsif @status_window.active
      update_actor_selection
    end
  end
  #
  # コマンドウィンドウの作成
  #
  #
  def create_command_window
    s1 = Vocab::item
    s2 = Vocab::skill
    s3 = Vocab::equip
    s4 = Vocab::status
    s5 = Vocab::save
    s6 = Vocab::game_end
    @command_window = Window_Command.new(160, [s1, s2, s3, s4, s5, s6])
    @command_window.index = @menu_index
    if $game_party.members.size == 0          # パーティ人数が 0 人の場合
      @command_window.draw_item(0, false)     # アイテムを無効化
      @command_window.draw_item(1, false)     # スキルを無効化
      @command_window.draw_item(2, false)     # 装備を無効化
      @command_window.draw_item(3, false)     # ステータスを無効化
    end
    if $game_system.save_disabled             # セーブ禁止の場合
      @command_window.draw_item(4, false)     # セーブを無効化
    end
  end
  #
  # コマンド選択の更新
  #
  #
  def update_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::C)
      if $game_party.members.size == 0 and @command_window.index < 4
        Sound.play_buzzer
        return
      elsif $game_system.save_disabled and @command_window.index == 4
        Sound.play_buzzer
        return
      end
      Sound.play_decision
      case @command_window.index
      when 0      # アイテム
        $scene = Scene_Item.new
      when 1,2,3  # スキル、装備、ステータス
        start_actor_selection
      when 4      # セーブ
        $scene = Scene_File.new(true, false, false)
      when 5      # ゲーム終了
        $scene = Scene_End.new
      end
    end
  end
  #
  # アクター選択の開始
  #
  #
  def start_actor_selection
    @command_window.active = false
    @status_window.active = true
    if $game_party.last_actor_index < @status_window.item_max
      @status_window.index = $game_party.last_actor_index
    else
      @status_window.index = 0
    end
  end
  #
  # アクター選択の終了
  #
  #
  def end_actor_selection
    @command_window.active = true
    @status_window.active = false
    @status_window.index = -1
  end
  #
  # アクター選択の更新
  #
  #
  def update_actor_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_actor_selection
    elsif Input.trigger?(Input::C)
      $game_party.last_actor_index = @status_window.index
      Sound.play_decision
      case @command_window.index
      when 1  # スキル
        $scene = Scene_Skill.new(@status_window.index)
      when 2  # 装備
        $scene = Scene_Equip.new(@status_window.index)
      when 3  # ステータス
        $scene = Scene_Status.new(@status_window.index)
      end
    end
  end
end
