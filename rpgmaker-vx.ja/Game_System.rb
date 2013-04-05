#
# システム周りのデータを扱うクラスです。乗り物や BGM などの管理も行います。
# このクラスのインスタンスは $game_system で参照されます。
#

class Game_System
  #
  # 公開インスタンス変数
  #
  #
  attr_accessor :timer                    # タイマー
  attr_accessor :timer_working            # タイマー作動中フラグ
  attr_accessor :save_disabled            # セーブ禁止
  attr_accessor :menu_disabled            # メニュー禁止
  attr_accessor :encounter_disabled       # エンカウント禁止
  attr_accessor :save_count               # セーブ回数
  attr_accessor :version_id               # ゲームのバージョン ID
  #
  # オブジェクト初期化
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
  # バトル BGM の取得
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
  # バトル BGM の設定
  #
  # battle_bgm : 新しいバトル BGM
  #
  def battle_bgm=(battle_bgm)
    @battle_bgm = battle_bgm
  end
  #
  # バトル終了 ME の取得
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
  # バトル終了 ME の設定
  #
  # battle_end_me : 新しいバトル終了 ME
  #
  def battle_end_me=(battle_end_me)
    @battle_end_me = battle_end_me
  end
  #
  # フレーム更新
  #
  #
  def update
    if @timer_working and @timer > 0
      @timer -= 1
      if @timer == 0 and $game_temp.in_battle     # 戦闘中にタイマーが 0 に
        $game_temp.next_scene = "map"             # なったら戦闘を中断する
      end
    end
  end
end
