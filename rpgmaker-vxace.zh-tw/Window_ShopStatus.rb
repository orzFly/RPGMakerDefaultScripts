#encoding:utf-8
#
# 商店畫面中，顯示“物品持有數”和“角色裝備”的視窗。
#

class Window_ShopStatus < Window_Base
  #
  # 初始化物件
  #
  #
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item = nil
    @page_index = 0
    refresh
  end
  #
  # 重新整理
  #
  #
  def refresh
    contents.clear
    draw_possession(4, 0)
    draw_equip_info(4, line_height * 2) if @item.is_a?(RPG::EquipItem)
  end
  #
  # 設定物品
  #
  #
  def item=(item)
    @item = item
    refresh
  end
  #
  # 繪制持有數
  #
  #
  def draw_possession(x, y)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change_color(system_color)
    draw_text(rect, Vocab::Possession)
    change_color(normal_color)
    draw_text(rect, $game_party.item_number(@item), 2)
  end
  #
  # 繪制裝備訊息
  #
  #
  def draw_equip_info(x, y)
    status_members.each_with_index do |actor, i|
      draw_actor_equip_info(x, y + line_height * (i * 2.4), actor)
    end
  end
  #
  # 需要繪制訊息的角色數組
  #
  #
  def status_members
    $game_party.members[@page_index * page_size, page_size]
  end
  #
  # 一頁中顯示的角色人數
  #
  #
  def page_size
    return 4
  end
  #
  # 取得總頁數
  #
  #
  def page_max
    ($game_party.members.size + page_size - 1) / page_size
  end
  #
  # 繪制角色的裝備訊息
  #
  #
  def draw_actor_equip_info(x, y, actor)
    enabled = actor.equippable?(@item)
    change_color(normal_color, enabled)
    draw_text(x, y, 112, line_height, actor.name)
    item1 = current_equipped_item(actor, @item.etype_id)
    draw_actor_param_change(x, y, actor, item1) if enabled
    draw_item_name(item1, x, y + line_height, enabled)
  end
  #
  # 繪制角色的能力值變化
  #
  #
  def draw_actor_param_change(x, y, actor, item1)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change = @item.params[param_id] - (item1 ? item1.params[param_id] : 0)
    change_color(param_change_color(change))
    draw_text(rect, sprintf("%+d", change), 2)
  end
  #
  # 取得選中裝備對應的能力值 ID
  #
  # 預設下武器對應物理攻擊、護甲對應物理防御。
  #
  def param_id
    @item.is_a?(RPG::Weapon) ? 2 : 3
  end
  #
  # 取得當前的裝備 
  #
  # 像雙持武器這類，同一類型裝備裝備多個裝備的場合，返回比較弱的一個。
  #
  def current_equipped_item(actor, etype_id)
    list = []
    actor.equip_slots.each_with_index do |slot_etype_id, i|
      list.push(actor.equips[i]) if slot_etype_id == etype_id
    end
    list.min_by {|item| item ? item.params[param_id] : 0 }
  end
  #
  # 更新畫面
  #
  #
  def update
    super
    update_page
  end
  #
  # 更新翻頁
  #
  #
  def update_page
    if visible && Input.trigger?(:A) && page_max > 1
      @page_index = (@page_index + 1) % page_max
      refresh
    end
  end
end
