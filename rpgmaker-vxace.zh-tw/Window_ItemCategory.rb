#encoding:utf-8
#
# 物品畫面和商店畫面中，顯示裝備、所持物品等專案清單的視窗。
#

class Window_ItemCategory < Window_HorzCommand
  #
  # 定義案例變量
  #
  #
  attr_reader   :item_window
  #
  # 初始化物件
  #
  #
  def initialize
    super(0, 0)
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    Graphics.width
  end
  #
  # 取得列數
  #
  #
  def col_max
    return 4
  end
  #
  # 更新畫面
  #
  #
  def update
    super
    @item_window.category = current_symbol if @item_window
  end
  #
  # 生成指令清單
  #
  #
  def make_command_list
    add_command(Vocab::item,     :item)
    add_command(Vocab::weapon,   :weapon)
    add_command(Vocab::armor,    :armor)
    add_command(Vocab::key_item, :key_item)
  end
  #
  # 設定物品視窗
  #
  #
  def item_window=(item_window)
    @item_window = item_window
    update
  end
end
