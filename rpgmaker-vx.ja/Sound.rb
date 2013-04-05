#
# 効果音を演奏するモジュールです。グローバル変数 $data_system からデータベー
# スで設定された SE の内容を取得し、演奏します。
#

module Sound

  # カーソル移動
  def self.play_cursor
    $data_system.sounds[0].play
  end

  # 決定
  def self.play_decision
    $data_system.sounds[1].play
  end

  # キャンセル
  def self.play_cancel
    $data_system.sounds[2].play
  end

  # ブザー
  def self.play_buzzer
    $data_system.sounds[3].play
  end

  # 装備
  def self.play_equip
    $data_system.sounds[4].play
  end

  # セーブ
  def self.play_save
    $data_system.sounds[5].play
  end

  # ロード
  def self.play_load
    $data_system.sounds[6].play
  end

  # 戦闘開始
  def self.play_battle_start
    $data_system.sounds[7].play
  end

  # 逃走
  def self.play_escape
    $data_system.sounds[8].play
  end

  # 敵の通常攻撃
  def self.play_enemy_attack
    $data_system.sounds[9].play
  end

  # 敵ダメージ
  def self.play_enemy_damage
    $data_system.sounds[10].play
  end

  # 敵消滅
  def self.play_enemy_collapse
    $data_system.sounds[11].play
  end

  # 味方ダメージ
  def self.play_actor_damage
    $data_system.sounds[12].play
  end

  # 味方戦闘不能
  def self.play_actor_collapse
    $data_system.sounds[13].play
  end

  # 回復
  def self.play_recovery
    $data_system.sounds[14].play
  end

  # ミス
  def self.play_miss
    $data_system.sounds[15].play
  end

  # 攻撃回避
  def self.play_evasion
    $data_system.sounds[16].play
  end

  # ショップ
  def self.play_shop
    $data_system.sounds[17].play
  end

  # アイテム使用
  def self.play_use_item
    $data_system.sounds[18].play
  end

  # スキル使用
  def self.play_use_skill
    $data_system.sounds[19].play
  end

end
