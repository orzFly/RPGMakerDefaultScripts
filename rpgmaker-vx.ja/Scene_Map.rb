#
# マップ画面の処理を行うクラスです。
#

class Scene_Map < Scene_Base
  #
  # 開始処理
  #
  #
  def start
    super
    $game_map.refresh
    @spriteset = Spriteset_Map.new
    @message_window = Window_Message.new
  end
  #
  # トランジション実行
  #
  #
  def perform_transition
    if Graphics.brightness == 0       # 戦闘後、ロード直後など
      fadein(30)
    else                              # メニューからの復帰など
      Graphics.transition(15)
    end
  end
  #
  # 終了処理
  #
  #
  def terminate
    super
    if $scene.is_a?(Scene_Battle)     # バトル画面に切り替え中の場合
      @spriteset.dispose_characters   # 背景作成のためにキャラを隠す
    end
    snapshot_for_background
    @spriteset.dispose
    @message_window.dispose
    if $scene.is_a?(Scene_Battle)     # バトル画面に切り替え中の場合
      perform_battle_transition       # 戦闘前トランジション実行
    end
  end
  #
  # 基本更新処理
  #
  #
  def update_basic
    Graphics.update                   # ゲーム画面を更新
    Input.update                      # 入力情報を更新
    $game_map.update                  # マップを更新
    @spriteset.update                 # スプライトセットを更新
  end
  #
  # フレーム更新
  #
  #
  def update
    super
    $game_map.interpreter.update      # インタプリタを更新
    $game_map.update                  # マップを更新
    $game_player.update               # プレイヤーを更新
    $game_system.update               # タイマーを更新
    @spriteset.update                 # スプライトセットを更新
    @message_window.update            # メッセージウィンドウを更新
    unless $game_message.visible      # メッセージ表示中以外
      update_transfer_player
      update_encounter
      update_call_menu
      update_call_debug
      update_scene_change
    end
  end
  #
  # 画面のフェードイン
  #
  # duration : 時間
  # マップ画面では、Graphics.fadeout を直接使うと天候エフェクトや遠景のス
  # クロールなどが止まるなどの不都合があるため、動的にフェードインを行う。
  #
  def fadein(duration)
    Graphics.transition(0)
    for i in 0..duration-1
      Graphics.brightness = 255 * i / duration
      update_basic
    end
    Graphics.brightness = 255
  end
  #
  # 画面のフェードアウト
  #
  # duration : 時間
  # 上記のフェードインと同じく、Graphics.fadein は直接使わない。
  #
  def fadeout(duration)
    Graphics.transition(0)
    for i in 0..duration-1
      Graphics.brightness = 255 - 255 * i / duration
      update_basic
    end
    Graphics.brightness = 0
  end
  #
  # 場所移動の処理
  #
  #
  def update_transfer_player
    return unless $game_player.transfer?
    fade = (Graphics.brightness > 0)
    fadeout(30) if fade
    @spriteset.dispose              # スプライトセットを解放
    $game_player.perform_transfer   # 場所移動の実行
    $game_map.autoplay              # BGM と BGS の自動切り替え
    $game_map.update
    Graphics.wait(15)
    @spriteset = Spriteset_Map.new  # スプライトセットを再作成
    fadein(30) if fade
    Input.update
  end
  #
  # エンカウントの処理
  #
  #
  def update_encounter
    return if $game_player.encounter_count > 0        # 遭遇歩数未満？
    return if $game_map.interpreter.running?          # イベント実行中？
    return if $game_system.encounter_disabled         # エンカウント禁止中？
    troop_id = $game_player.make_encounter_troop_id   # 敵グループを決定
    return if $data_troops[troop_id] == nil           # 敵グループが無効？
    $game_troop.setup(troop_id)
    $game_troop.can_escape = true
    $game_temp.battle_proc = nil
    $game_temp.next_scene = "battle"
    preemptive_or_surprise
  end
  #
  # 先制攻撃と不意打ちの確率判定
  #
  #
  def preemptive_or_surprise
    actors_agi = $game_party.average_agi
    enemies_agi = $game_troop.average_agi
    if actors_agi >= enemies_agi
      percent_preemptive = 5
      percent_surprise = 3
    else
      percent_preemptive = 3
      percent_surprise = 5
    end
    if rand(100) < percent_preemptive
      $game_troop.preemptive = true
    elsif rand(100) < percent_surprise
      $game_troop.surprise = true
    end
  end
  #
  # キャンセルボタンによるメニュー呼び出し判定
  #
  #
  def update_call_menu
    if Input.trigger?(Input::B)
      return if $game_map.interpreter.running?        # イベント実行中？
      return if $game_system.menu_disabled            # メニュー禁止中？
      $game_temp.menu_beep = true                     # SE 演奏フラグ設定
      $game_temp.next_scene = "menu"
    end
  end
  #
  # F9 キーによるデバッグ呼び出し判定
  #
  #
  def update_call_debug
    if $TEST and Input.press?(Input::F9)    # テストプレイ中 F9 キー
      $game_temp.next_scene = "debug"
    end
  end
  #
  # 画面切り替えの実行
  #
  #
  def update_scene_change
    return if $game_player.moving?    # プレイヤーの移動中？
    case $game_temp.next_scene
    when "battle"
      call_battle
    when "shop"
      call_shop
    when "name"
      call_name
    when "menu"
      call_menu
    when "save"
      call_save
    when "debug"
      call_debug
    when "gameover"
      call_gameover
    when "title"
      call_title
    else
      $game_temp.next_scene = nil
    end
  end
  #
  # バトル画面への切り替え
  #
  #
  def call_battle
    @spriteset.update
    Graphics.update
    $game_player.make_encounter_count
    $game_player.straighten
    $game_temp.map_bgm = RPG::BGM.last
    $game_temp.map_bgs = RPG::BGS.last
    RPG::BGM.stop
    RPG::BGS.stop
    Sound.play_battle_start
    $game_system.battle_bgm.play
    $game_temp.next_scene = nil
    $scene = Scene_Battle.new
  end
  #
  # ショップ画面への切り替え
  #
  #
  def call_shop
    $game_temp.next_scene = nil
    $scene = Scene_Shop.new
  end
  #
  # 名前入力画面への切り替え
  #
  #
  def call_name
    $game_temp.next_scene = nil
    $scene = Scene_Name.new
  end
  #
  # メニュー画面への切り替え
  #
  #
  def call_menu
    if $game_temp.menu_beep
      Sound.play_decision
      $game_temp.menu_beep = false
    end
    $game_temp.next_scene = nil
    $scene = Scene_Menu.new
  end
  #
  # セーブ画面への切り替え
  #
  #
  def call_save
    $game_temp.next_scene = nil
    $scene = Scene_File.new(true, false, true)
  end
  #
  # デバッグ画面への切り替え
  #
  #
  def call_debug
    Sound.play_decision
    $game_temp.next_scene = nil
    $scene = Scene_Debug.new
  end
  #
  # ゲームオーバー画面への切り替え
  #
  #
  def call_gameover
    $game_temp.next_scene = nil
    $scene = Scene_Gameover.new
  end
  #
  # タイトル画面への切り替え
  #
  #
  def call_title
    $game_temp.next_scene = nil
    $scene = Scene_Title.new
    fadeout(60)
  end
  #
  # 戦闘前トランジション実行
  #
  #
  def perform_battle_transition
    Graphics.transition(80, "Graphics/System/BattleStart", 80)
    Graphics.freeze
  end
end
