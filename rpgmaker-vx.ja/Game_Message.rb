#
# 文章や選択肢などを表示するメッセージウィンドウの状態を扱うクラスです。この
# クラスのインスタンスは $game_message で参照されます。
#

class Game_Message
  #
  # 定数
  #
  #
  MAX_LINE = 4                            # 最大行数
  #
  # 公開インスタンス変数
  #
  #
  attr_accessor :texts                    # 文章の配列 (行単位)
  attr_accessor :face_name                # 顔グラフィック ファイル名
  attr_accessor :face_index               # 顔グラフィック インデックス
  attr_accessor :background               # 背景タイプ
  attr_accessor :position                 # 表示位置
  attr_accessor :main_proc                # メイン コールバック (Proc)
  attr_accessor :choice_proc              # 選択肢 コールバック (Proc)
  attr_accessor :choice_start             # 選択肢 開始行
  attr_accessor :choice_max               # 選択肢 項目数
  attr_accessor :choice_cancel_type       # 選択肢 キャンセルの場合
  attr_accessor :num_input_variable_id    # 数値入力 変数 ID
  attr_accessor :num_input_digits_max     # 数値入力 桁数
  attr_accessor :visible                  # メッセージ表示中
  #
  # オブジェクト初期化
  #
  #
  def initialize
    clear
    @visible = false
  end
  #
  # クリア
  #
  #
  def clear
    @texts = []
    @face_name = ""
    @face_index = 0
    @background = 0
    @position = 2
    @main_proc = nil
    @choice_start = 99
    @choice_max = 0
    @choice_cancel_type = 0
    @choice_proc = nil
    @num_input_variable_id = 0
    @num_input_digits_max = 0
  end
  #
  # ビジー状態判定
  #
  #
  def busy
    return @texts.size > 0
  end
  #
  # 改ページ
  #
  #
  def new_page
    while @texts.size % MAX_LINE > 0
      @texts.push("")
    end
  end
end
