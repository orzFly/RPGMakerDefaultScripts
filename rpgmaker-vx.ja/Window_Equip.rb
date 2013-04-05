#
# 装備画面で、アクターが現在装備しているアイテムを表示するウィンドウです。
#

class Window_Equip < Window_Selectable
  #
  # オブジェクト初期化
  #
  # x     : ウィンドウの X 座標
  # y     : ウィンドウの Y 座標
  # actor : アクター
  #
  def initialize(x, y, actor)
    super(x, y, 336, WLH * 5 + 32)
    @actor = actor
    refresh
    self.index = 0
  end
  #
  # アイテムの取得
  #
  #
  def item
    return @data[self.index]
  end
  #
  # リフレッシュ
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
  # ヘルプテキスト更新
  #
  #
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
end
