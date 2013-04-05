#
# 装备画面、显示角色现在装备的物品的窗口。
#

class Window_Equip < Window_Selectable
  #
  # 初始化对像
  #
  # x : 窗口的X坐标
  # y : 窗口的Y坐标
  # actor  : 角色
  #
  def initialize(x, y, actor)
    super(x, y, 336, WLH * 5 + 32)
    @actor = actor
    refresh
    self.index = 0
  end
  #
  # 获取物品
  #
  #
  def item
    return @data[self.index]
  end
  #
  # 刷新
  #
  #
  def refresh
    self.contents.clear
    @data = []
    for item in @actor.equips do @data.push(item) end
    @item_max = @data.size
    self.contents.font.color = system_color
    if @actor.two_swords_style
      self.contents.draw_text(4, WLH * 0, 92, WLH, Vocab::weapon1)
      self.contents.draw_text(4, WLH * 1, 92, WLH, Vocab::weapon2)
    else
      self.contents.draw_text(4, WLH * 0, 92, WLH, Vocab::weapon)
      self.contents.draw_text(4, WLH * 1, 92, WLH, Vocab::armor1)
    end
    self.contents.draw_text(4, WLH * 2, 92, WLH, Vocab::armor2)
    self.contents.draw_text(4, WLH * 3, 92, WLH, Vocab::armor3)
    self.contents.draw_text(4, WLH * 4, 92, WLH, Vocab::armor4)
    draw_item_name(@data[0], 92, WLH * 0)
    draw_item_name(@data[1], 92, WLH * 1)
    draw_item_name(@data[2], 92, WLH * 2)
    draw_item_name(@data[3], 92, WLH * 3)
    draw_item_name(@data[4], 92, WLH * 4)
  end
  #
  # 刷新帮助文本
  #
  #
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
end
