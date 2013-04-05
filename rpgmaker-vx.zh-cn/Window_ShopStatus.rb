#
# 商店画面、显示物品所持数与角色装备的窗口。
#

class Window_ShopStatus < Window_Base
  #
  # 初始化对像
  #
  # x : 窗口的X坐标
  # y : 窗口的Y坐标
  #
  def initialize(x, y)
    super(x, y, 240, 304)
    @item = nil
    refresh
  end
  #
  # 刷新
  #
  #
  def refresh
    self.contents.clear
    if @item != nil
      number = $game_party.item_number(@item)
      self.contents.font.color = system_color
      self.contents.draw_text(4, 0, 200, WLH, Vocab::Possession)
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, 200, WLH, number, 2)
      for actor in $game_party.members
        x = 4
        y = WLH * (2 + actor.index * 2)
        draw_actor_parameter_change(actor, x, y)
      end
    end
  end
  #
  # 描画角色当前装备和能力值变化
  #
  # actor : 角色
  # x     : 描画目标 X 坐标
  # y     : 描画目标 Y 坐标  
  #
  def draw_actor_parameter_change(actor, x, y)
    return if @item.is_a?(RPG::Item)
    enabled = actor.equippable?(@item)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(x, y, 200, WLH, actor.name)
    if @item.is_a?(RPG::Weapon)
      item1 = weaker_weapon(actor)
    elsif actor.two_swords_style and @item.kind == 0
      item1 = nil
    else
      item1 = actor.equips[1 + @item.kind]
    end
    if enabled
      if @item.is_a?(RPG::Weapon)
        atk1 = item1 == nil ? 0 : item1.atk
        atk2 = @item == nil ? 0 : @item.atk
        change = atk2 - atk1
      else
        def1 = item1 == nil ? 0 : item1.def
        def2 = @item == nil ? 0 : @item.def
        change = def2 - def1
      end
      self.contents.draw_text(x, y, 200, WLH, sprintf("%+d", change), 2)
    end
    draw_item_name(item1, x, y + WLH, enabled)
  end
  #
  # 获取角色装备所装备弱的武器 (二刀流用)
  #
  # actor : 角色
  #
  def weaker_weapon(actor)
    if actor.two_swords_style
      weapon1 = actor.weapons[0]
      weapon2 = actor.weapons[1]
      if weapon1 == nil or weapon2 == nil
        return nil
      elsif weapon1.atk < weapon2.atk
        return weapon1
      else
        return weapon2
      end
    else
      return actor.weapons[0]
    end
  end
  #
  # 设置物品
  #
  # item : 新的物品
  #
  def item=(item)
    if @item != item
      @item = item
      refresh
    end
  end
end
