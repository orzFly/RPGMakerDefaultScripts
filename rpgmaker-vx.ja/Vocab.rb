#
# 用語とメッセージを定義するモジュールです。定数でメッセージなどを直接定義す
# るほか、グローバル変数 $data_system から用語データを取得します。
#

module Vocab

  # ショップ画面
  ShopBuy         = "購入する"
  ShopSell        = "売却する"
  ShopCancel      = "やめる"
  Possession      = "持っている数"

  # ステータス画面
  ExpTotal        = "現在の経験値"
  ExpNext         = "次の%sまで"

  # セーブ／ロード画面
  SaveMessage     = "どのファイルにセーブしますか？"
  LoadMessage     = "どのファイルをロードしますか？"
  File            = "ファイル"

  # 複数メンバーの場合の表示
  PartyName       = "%sたち"

  # 戦闘基本メッセージ
  Emerge          = "%sが出現！"
  Preemptive      = "%sは先手を取った！"
  Surprise        = "%sは不意をつかれた！"
  EscapeStart     = "%sは逃げ出した！"
  EscapeFailure   = "しかし逃げることはできなかった！"

  # 戦闘終了メッセージ
  Victory         = "%sの勝利！"
  Defeat          = "%sは戦いに敗れた。"
  ObtainExp       = "%s の経験値を獲得！"
  ObtainGold      = "お金を %s%s 手に入れた！"
  ObtainItem      = "%sを手に入れた！"
  LevelUp         = "%sは%s %s に上がった！"
  ObtainSkill     = "%sを覚えた！"

  # 戦闘行動
  DoAttack        = "%sの攻撃！"
  DoGuard         = "%sは身を守っている。"
  DoEscape        = "%sは逃げてしまった。"
  DoWait          = "%sは様子を見ている。"
  UseItem         = "%sは%sを使った！"

  # クリティカルヒット
  CriticalToEnemy = "会心の一撃！！"
  CriticalToActor = "痛恨の一撃！！"

  # アクター対象の行動結果
  ActorDamage     = "%sは %s のダメージを受けた！"
  ActorLoss       = "%sの%sが %s 減った！"
  ActorDrain      = "%sは%sを %s 奪われた！"
  ActorNoDamage   = "%sはダメージを受けていない！"
  ActorNoHit      = "ミス！　%sはダメージを受けていない！"
  ActorEvasion    = "%sは攻撃をかわした！"
  ActorRecovery   = "%sの%sが %s 回復した！"

  # 敵キャラ対象の行動結果
  EnemyDamage     = "%sに %s のダメージを与えた！"
  EnemyLoss       = "%sの%sが %s 減った！"
  EnemyDrain      = "%sの%sを %s 奪った！"
  EnemyNoDamage   = "%sにダメージを与えられない！"
  EnemyNoHit      = "ミス！　%sにダメージを与えられない！"
  EnemyEvasion    = "%sは攻撃をかわした！"
  EnemyRecovery   = "%sの%sが %s 回復した！"

  # 物理攻撃以外のスキル、アイテムの効果がなかった
  ActionFailure   = "%sには効かなかった！"

  # レベル
  def self.level
    return $data_system.terms.level
  end

  # レベル (略)
  def self.level_a
    return $data_system.terms.level_a
  end

  # HP
  def self.hp
    return $data_system.terms.hp
  end

  # HP (略)
  def self.hp_a
    return $data_system.terms.hp_a
  end

  # MP
  def self.mp
    return $data_system.terms.mp
  end

  # MP (略)
  def self.mp_a
    return $data_system.terms.mp_a
  end

  # 攻撃力
  def self.atk
    return $data_system.terms.atk
  end

  # 防御力
  def self.def
    return $data_system.terms.def
  end

  # 精神力
  def self.spi
    return $data_system.terms.spi
  end

  # 敏捷性
  def self.agi
    return $data_system.terms.agi
  end

  # 武器
  def self.weapon
    return $data_system.terms.weapon
  end

  # 盾
  def self.armor1
    return $data_system.terms.armor1
  end

  # 頭
  def self.armor2
    return $data_system.terms.armor2
  end

  # 身体
  def self.armor3
    return $data_system.terms.armor3
  end

  # 装飾品
  def self.armor4
    return $data_system.terms.armor4
  end

  # 武器 1
  def self.weapon1
    return $data_system.terms.weapon1
  end

  # 武器 2
  def self.weapon2
    return $data_system.terms.weapon2
  end

  # 攻撃
  def self.attack
    return $data_system.terms.attack
  end

  # スキル
  def self.skill
    return $data_system.terms.skill
  end

  # 防御
  def self.guard
    return $data_system.terms.guard
  end

  # アイテム
  def self.item
    return $data_system.terms.item
  end

  # 装備
  def self.equip
    return $data_system.terms.equip
  end

  # ステータス
  def self.status
    return $data_system.terms.status
  end

  # セーブ
  def self.save
    return $data_system.terms.save
  end

  # ゲーム終了
  def self.game_end
    return $data_system.terms.game_end
  end

  # 戦う
  def self.fight
    return $data_system.terms.fight
  end

  # 逃げる
  def self.escape
    return $data_system.terms.escape
  end

  # ニューゲーム
  def self.new_game
    return $data_system.terms.new_game
  end

  # コンティニュー
  def self.continue
    return $data_system.terms.continue
  end

  # シャットダウン
  def self.shutdown
    return $data_system.terms.shutdown
  end

  # タイトルへ
  def self.to_title
    return $data_system.terms.to_title
  end

  # やめる
  def self.cancel
    return $data_system.terms.cancel
  end

  # G (通貨単位)
  def self.gold
    return $data_system.terms.gold
  end

end
