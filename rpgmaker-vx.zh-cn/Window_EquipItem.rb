#
# 装备画面、显示浏览变更装备的候补物品的窗口。
#

class Window_EquipItem < Window_Item
  #
  # 初始化对像
  #
  # x : 窗口的X坐标
  # y : 窗口的Y坐标
  # width  : 窗口的宽
  # height : 窗口的高
  # actor  : 角色
  # equip_type : 装备部位 (0～4)
  #
  def initialize(x, y, width, height, actor, equip_type)
    @actor = actor
    if equip_type == 1 and actor.two_swords_style     # 二刀流
      equip_type = 0                                  # 武器变更为盾
    end
    @equip_type = equip_type
    super(x, y, width, height)
  end
  #
  # 列表中是否包含某物品
  #
  # item : 物品
  #
  def include?(item)
    return true if item == nil
    if @equip_type == 0
      return false unless item.is_a?(RPG::Weapon)
    else
      return false unless item.is_a?(RPG::Armor)
      return false unless item.kind == @equip_type - 1
    end
    return @actor.equippable?(item)
  end
  #
  # 是否允许使用判定
  #
  # item : 物品
  #
  def enable?(item)
    return true
  end
end
