#
# コモンイベントを扱うクラスです。並列処理イベントを実行する機能を持っていま
# す。このクラスは Game_Map クラス ($game_map) の内部で使用されます。
#

class Game_CommonEvent
  #
  # オブジェクト初期化
  #
  # common_event_id : コモンイベント ID
  #
  def initialize(common_event_id)
    @common_event_id = common_event_id
    @interpreter = nil
    refresh
  end
  #
  # 名前の取得
  #
  #
  def name
    return $data_common_events[@common_event_id].name
  end
  #
  # トリガーの取得
  #
  #
  def trigger
    return $data_common_events[@common_event_id].trigger
  end
  #
  # 条件スイッチ ID の取得
  #
  #
  def switch_id
    return $data_common_events[@common_event_id].switch_id
  end
  #
  # 実行内容の取得
  #
  #
  def list
    return $data_common_events[@common_event_id].list
  end
  #
  # リフレッシュ
  #
  #
  def refresh
    if self.trigger == 2 and $game_switches[self.switch_id] == true
      @interpreter = Game_Interpreter.new if @interpreter == nil
    else
      @interpreter = nil
    end
  end
  #
  # フレーム更新
  #
  #
  def update
    if @interpreter != nil                # 並列処理が有効の場合
      unless @interpreter.running?        # 実行中でなければ
        @interpreter.setup(self.list)     # セットアップ
      end
      @interpreter.update                 # インタプリタを更新
    end
  end
end
