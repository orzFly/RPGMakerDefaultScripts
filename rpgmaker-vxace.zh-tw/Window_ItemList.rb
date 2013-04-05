#encoding:utf-8
#
# 物品畫面中，顯示持有物品的視窗。
#

class Window_ItemList < Window_Selectable
  #
  # 初始化物件
  #
  #
  def initialize(x, y, width, height)
    super
    @category = :none
    @data = []
  end
  #
  # 設定分類
  #
  #
  def category=(category)
    return if @category == category
    @category = category
    refresh
    self.oy = 0
  end
  #
  # 取得列數
  #
  #
  def col_max
    return 2
  end
  #
  # 取得專案數
  #
  #
  def item_max
    @data ? @data.size : 1
  end
  #
  # 取得物品
  #
  #
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  #
  # 取得選擇專案的有效狀態
  #
  #
  def current_item_enabled?
    enable?(@data[index])
  end
  #
  # 查詢清單中是否含有此物品
  #
  #
  def include?(item)
    case @category
    when :item
      item.is_a?(RPG::Item) && !item.key_item?
    when :weapon
      item.is_a?(RPG::Weapon)
    when :armor
      item.is_a?(RPG::Armor)
    when :key_item
      item.is_a?(RPG::Item) && item.key_item?
    else
      false
    end
  end
  #
  # 查詢此物品是否可用
  #
  #
  def enable?(item)
    $game_party.usable?(item)
  end
  #
  # 生成物品清單
  #
  #
  def make_item_list
    @data = $game_party.all_items.select {|item| include?(item) }
    @data.push(nil) if include?(nil)
  end
  #
  # 返回上一個選擇的位置
  #
  #
  def select_last
    select(@data.index($game_party.last_item.object) || 0)
  end
  #
  # 繪制專案
  #
  #
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item))
      draw_item_number(rect, item)
    end
  end
  #
  # 繪制物品個數
  #
  #
  def draw_item_number(rect, item)
    draw_text(rect, sprintf(":%2d", $game_party.item_number(item)), 2)
  end
  #
  # 更新說明內容
  #
  #
  def update_help
    @help_window.set_item(item)
  end
  #
  # 重新整理
  #
  #
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
end
