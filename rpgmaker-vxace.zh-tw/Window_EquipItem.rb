#encoding:utf-8
#
# 裝備畫面中，顯示可替換裝備的視窗。
#

class Window_EquipItem < Window_ItemList
  #
  # 定義案例變量
  #
  #
  attr_reader   :status_window            # 狀態視窗
  #
  # 初始化物件
  #
  #
  def initialize(x, y, width, height)
    super
    @actor = nil
    @slot_id = 0
  end
  #
  # 設定角色
  #
  #
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
    self.oy = 0
  end
  #
  # 設定裝備欄 ID 
  #
  #
  def slot_id=(slot_id)
    return if @slot_id == slot_id
    @slot_id = slot_id
    refresh
    self.oy = 0
  end
  #
  # 查詢使用清單中是否含有此物品
  #
  #
  def include?(item)
    return true if item == nil
    return false unless item.is_a?(RPG::EquipItem)
    return false if @slot_id < 0
    return false if item.etype_id != @actor.equip_slots[@slot_id]
    return @actor.equippable?(item)
  end
  #
  # 查詢此檔案是否可以裝備
  #
  #
  def enable?(item)
    return true
  end
  #
  # 返回上一個選擇的位置
  #
  #
  def select_last
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
  # 更新說明內容
  #
  #
  def update_help
    super
    if @actor && @status_window
      temp_actor = Marshal.load(Marshal.dump(@actor))
      temp_actor.force_change_equip(@slot_id, item)
      @status_window.set_temp_actor(temp_actor)
    end
  end
end
