#
# セルフスイッチを扱うクラスです。組み込みクラス Hash のラッパーです。このク
# ラスのインスタンスは $game_self_switches で参照されます。
#

class Game_SelfSwitches
  #
  # オブジェクト初期化
  #
  #
  def initialize
    @data = {}
  end
  #
  # セルフスイッチの取得
  #
  # key : キー
  #
  def [](key)
    return @data[key] == true ? true : false
  end
  #
  # セルフスイッチの設定
  #
  # key   : キー
  # value : ON (true) / OFF (false)
  #
  def []=(key, value)
    @data[key] = value
  end
end
