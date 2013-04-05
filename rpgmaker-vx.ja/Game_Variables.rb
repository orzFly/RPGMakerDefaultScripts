#
# 変数を扱うクラスです。組み込みクラス Array のラッパーです。このクラスのイ
# ンスタンスは $game_variables で参照されます。
#

class Game_Variables
  #
  # オブジェクト初期化
  #
  #
  def initialize
    @data = []
  end
  #
  # 変数の取得
  #
  # variable_id : 変数 ID
  #
  def [](variable_id)
    if @data[variable_id] == nil
      return 0
    else
      return @data[variable_id]
    end
  end
  #
  # 変数の設定
  #
  # variable_id : 変数 ID
  # value       : 変数の値
  #
  def []=(variable_id, value)
    if variable_id <= 5000
      @data[variable_id] = value
    end
  end
end
