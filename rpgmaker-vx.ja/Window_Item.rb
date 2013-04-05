#
# アイテム画面などで、所持アイテムの一覧を表示するウィンドウです。
#

class Window_Item < Window_Selectable
  #
  # オブジェクト初期化
  #
  # x      : ウィンドウの X 座標
  # y      : ウィンドウの Y 座標
  # width  : ウィンドウの幅
  # height : ウィンドウの高さ
  #
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @column_max = 2
    self.index = 0
    refresh
  end
  #
  # アイテムの取得
  #
  #
  def item
    return @data[self.index]
  end
  #
  # アイテムをリストに含めるかどうか
  #
  # item : アイテム
  #
  def include?(item)
    return false if item == nil
    if $game_temp.in_battle
      return false unless item.is_a?(RPG::Item)
    end
    return true
  end
  #
  # アイテムを許可状態で表示するかどうか
  #
  # item : アイテム
  #
  def enable?(item)
    return $game_party.item_can_use?(item)
  end
  #
  # リフレッシュ
  #
  #
  def refresh
    @data = []
    for item in $game_party.items
      next unless include?(item)
      @data.push(item)
      if item.is_a?(RPG::Item) and item.id == $game_party.last_item_id
        self.index = @data.size - 1
      end
    end
    @data.push(nil) if include?(nil)
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #
  # 項目の描画
  #
  # index : 項目番号
  #
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    if item != nil
      number = $game_party.item_number(item)
      enabled = enable?(item)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enabled)
      self.contents.draw_text(rect, sprintf(":%2d", number), 2)
    end
  end
  #
  # ヘルプテキスト更新
  #
  #
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
end
