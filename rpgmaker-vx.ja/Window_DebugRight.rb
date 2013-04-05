#
# デバッグ画面で、スイッチや変数を個別に表示するウィンドウです。
#

class Window_DebugRight < Window_Selectable
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :mode                     # モード (0:スイッチ、1:変数)
  attr_reader   :top_id                   # 先頭に表示する ID
  #
  # オブジェクト初期化
  #
  # x : ウィンドウの X 座標
  # y : ウィンドウの Y 座標
  #
  def initialize(x, y)
    super(x, y, 368, 10 * WLH + 32)
    self.index = -1
    self.active = false
    @item_max = 10
    @mode = 0
    @top_id = 1
    refresh
  end
  #
  # リフレッシュ
  #
  #
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #
  # 項目の描画
  #
  # index   : 項目番号
  #
  def draw_item(index)
    current_id = @top_id + index
    id_text = sprintf("%04d:", current_id)
    id_width = self.contents.text_size(id_text).width
    if @mode == 0
      name = $data_system.switches[current_id]
      status = $game_switches[current_id] ? "[ON]" : "[OFF]"
    else
      name = $data_system.variables[current_id]
      status = $game_variables[current_id]
    end
    if name == nil
      name = ""
    end
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.draw_text(rect, id_text)
    rect.x += id_width
    rect.width -= id_width + 60
    self.contents.draw_text(rect, name)
    rect.width += 60
    self.contents.draw_text(rect, status, 2)
  end
  #
  # モードの設定
  #
  # id : 新しいモード
  #
  def mode=(mode)
    if @mode != mode
      @mode = mode
      refresh
    end
  end
  #
  # 先頭に表示する ID の設定
  #
  # id : 新しい ID
  #
  def top_id=(id)
    if @top_id != id
      @top_id = id
      refresh
    end
  end
end
