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
  ObtainGold      = "お金を %s\\G 手に入れた！"
  ObtainItem      = "%sを手に入れた！"
  LevelUp         = "%sは%s %s に上がった！"
  ObtainSkill     = "%sを覚えた！"

  # アイテム使用
  UseItem         = "%sは%sを使った！"

  # クリティカルヒット
  CriticalToEnemy = "会心の一撃！！"
  CriticalToActor = "痛恨の一撃！！"

  # アクター対象の行動結果
  ActorDamage     = "%sは %s のダメージを受けた！"
  ActorRecovery   = "%sの%sが %s 回復した！"
  ActorGain       = "%sの%sが %s 増えた！"
  ActorLoss       = "%sの%sが %s 減った！"
  ActorDrain      = "%sは%sを %s 奪われた！"
  ActorNoDamage   = "%sはダメージを受けていない！"
  ActorNoHit      = "ミス！　%sはダメージを受けていない！"

  # 敵キャラ対象の行動結果
  EnemyDamage     = "%sに %s のダメージを与えた！"
  EnemyRecovery   = "%sの%sが %s 回復した！"
  EnemyGain       = "%sの%sが %s 増えた！"
  EnemyLoss       = "%sの%sが %s 減った！"
  EnemyDrain      = "%sの%sを %s 奪った！"
  EnemyNoDamage   = "%sにダメージを与えられない！"
  EnemyNoHit      = "ミス！　%sにダメージを与えられない！"

  # 回避／反射
  Evasion         = "%sは攻撃をかわした！"
  MagicEvasion    = "%sは魔法を打ち消した！"
  MagicReflection = "%sは魔法を跳ね返した！"
  CounterAttack   = "%sの反撃！"
  Substitute      = "%sが%sをかばった！"

  # 能力強化／弱体
  BuffAdd         = "%sの%sが上がった！"
  DebuffAdd       = "%sの%sが下がった！"
  BuffRemove      = "%sの%sが元に戻った！"

  # スキル、アイテムの効果がなかった
  ActionFailure   = "%sには効かなかった！"

  # エラーメッセージ
  PlayerPosError  = "プレイヤーの初期位置が設定されていません。"
  EventOverflow   = "コモンイベントの呼び出しが上限を超えました。"

  # 基本ステータス
  def self.basic(basic_id)
    $data_system.terms.basic[basic_id]
  end

  # 能力値
  def self.param(param_id)
    $data_system.terms.params[param_id]
  end

  # 装備タイプ
  def self.etype(etype_id)
    $data_system.terms.etypes[etype_id]
  end

  # コマンド
  def self.command(command_id)
    $data_system.terms.commands[command_id]
  end

  # 通貨単位
  def self.currency_unit
    $data_system.currency_unit
  end

  #
  def self.level;       basic(0);     end   # レベル
  def self.level_a;     basic(1);     end   # レベル (短)
  def self.hp;          basic(2);     end   # HP
  def self.hp_a;        basic(3);     end   # HP (短)
  def self.mp;          basic(4);     end   # MP
  def self.mp_a;        basic(5);     end   # MP (短)
  def self.tp;          basic(6);     end   # TP
  def self.tp_a;        basic(7);     end   # TP (短)
  def self.fight;       command(0);   end   # 戦う
  def self.escape;      command(1);   end   # 逃げる
  def self.attack;      command(2);   end   # 攻撃
  def self.guard;       command(3);   end   # 防御
  def self.item;        command(4);   end   # アイテム
  def self.skill;       command(5);   end   # スキル
  def self.equip;       command(6);   end   # 装備
  def self.status;      command(7);   end   # ステータス
  def self.formation;   command(8);   end   # 並び替え
  def self.save;        command(9);   end   # セーブ
  def self.game_end;    command(10);  end   # ゲーム終了
  def self.weapon;      command(12);  end   # 武器
  def self.armor;       command(13);  end   # 防具
  def self.key_item;    command(14);  end   # 大事なもの
  def self.equip2;      command(15);  end   # 装備変更
  def self.optimize;    command(16);  end   # 最強装備
  def self.clear;       command(17);  end   # 全て外す
  def self.new_game;    command(18);  end   # ニューゲーム
  def self.continue;    command(19);  end   # コンティニュー
  def self.shutdown;    command(20);  end   # シャットダウン
  def self.to_title;    command(21);  end   # タイトルへ
  def self.cancel;      command(22);  end   # やめる
  #
end
