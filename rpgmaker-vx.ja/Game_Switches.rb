#
# スイッチを扱うクラスです。組み込みクラス Array のラッパーです。このクラス
# のインスタンスは $game_switches で参照されます。
#

class Game_Switches
  #
  # オブジェクト初期化
  #
  #
  def initialize
    @data = []
  end
  #
  # スイッチの取得
  #
  # switch_id : スイッチ ID
  #
  def [](switch_id)
    if @data[switch_id] == nil
      return false
    else
      return @data[switch_id]
    end
  end
  #
  # スイッチの設定
  #
  # switch_id : スイッチ ID
  # value     : ON (true) / OFF (false)
  #
  def []=(switch_id, value)
    if switch_id <= 5000
      @data[switch_id] = value
    end
  end
end
