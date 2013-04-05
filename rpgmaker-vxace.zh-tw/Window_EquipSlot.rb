#encoding:utf-8
#
# 裝備畫面中，顯示角色當前裝備的視窗。
#

class Window_EquipSlot < Window_Selectable
  #
  # 定義案例變量
  #
  #
  attr_reader   :status_window            # 狀態視窗
  attr_reader   :item_window              # 物品視窗
  #
  # 初始化物件
  #
  #
  def initialize(x, y, width)
    super(x, y, width, window_height)
    @actor = nil
    refresh
  end
  #
  # 取得視窗的高度
  #
  #
  def window_height
    fitting_height(visible_line_number)
  end
  #
  # 取得顯示行數
  #
  #
  def visible_line_number
    return 5
  end
  #
  # 設定角色
  #
  #
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #
  # 更新畫面
  #
  #
  def update
    super
    @item_window.slot_id = index if @item_window
  end
  #
  # 取得專案數
  #
  #
  def item_max
    @actor ? @actor.equip_slots.size : 0
  end
  #
  # 取得物品
  #
  #
  def item
    @actor ? @actor.equips[index] : nil
  end
  #
  # 繪制專案
  #
  #
  def draw_item(index)
    return unless @actor
    rect = item_rect_for_text(index)
    change_color(system_color, enable?(index))
    draw_text(rect.x, rect.y, 92, line_height, slot_name(index))
    draw_item_name(@actor.equips[index], rect.x + 92, rect.y, enable?(index))
  end
  #
  # 取得裝備欄的名字
  #
  #
  def slot_name(index)
    @actor ? Vocab::etype(@actor.equip_slots[index]) : ""
  end
  #
  # 查詢這個裝備欄的裝備是否可以替換
  #
  #
  def enable?(index)
    @actor ? @actor.equip_change_ok?(index) : false
  end
  #
  # 取得選擇專案的有效狀態
  #
  #
  def current_item_enabled?
    enable?(index)
  end
  #
  # 設定狀態視窗
  #
  #
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  #
  # 設定物品視窗
  #
  #
  def item_window=(item_window)
    @item_window = item_window
    update
  end
  #
  # 更新說明內容
  #
  #
  def update_help
    super
    @help_window.set_item(item) if @help_window
    @status_window.set_temp_actor(nil) if @status_window
  end
end
