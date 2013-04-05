#
# セーブデータに含まれない、一時的なデータを扱うクラスです。このクラスのイン
# スタンスは $game_temp で参照されます。
#

class Game_Temp
  #
  # 公開インスタンス変数
  #
  #
  attr_accessor :next_scene               # 切り替え待機中の画面 (文字列)
  attr_accessor :map_bgm                  # マップ画面 BGM (バトル時記憶用)
  attr_accessor :map_bgs                  # マップ画面 BGS (バトル時記憶用)
  attr_accessor :common_event_id          # コモンイベント ID
  attr_accessor :in_battle                # 戦闘中フラグ
  attr_accessor :battle_proc              # バトル コールバック (Proc)
  attr_accessor :shop_goods               # ショップ 商品リスト
  attr_accessor :shop_purchase_only       # ショップ 購入のみフラグ
  attr_accessor :name_actor_id            # 名前入力 アクター ID
  attr_accessor :name_max_char            # 名前入力 最大文字数
  attr_accessor :menu_beep                # メニュー SE 演奏フラグ
  attr_accessor :last_file_index          # 最後にセーブしたファイルの番号
  attr_accessor :debug_top_row            # デバッグ画面 状態保存用
  attr_accessor :debug_index              # デバッグ画面 状態保存用
  attr_accessor :background_bitmap        # 背景ビットマップ
  #
  # オブジェクト初期化
  #
  #
  def initialize
    @next_scene = nil
    @map_bgm = nil
    @map_bgs = nil
    @common_event_id = 0
    @in_battle = false
    @battle_proc = nil
    @shop_goods = nil
    @shop_purchase_only = false
    @name_actor_id = 0
    @name_max_char = 0
    @menu_beep = false
    @last_file_index = 0
    @debug_top_row = 0
    @debug_index = 0
    @background_bitmap = Bitmap.new(1, 1)
  end
end
