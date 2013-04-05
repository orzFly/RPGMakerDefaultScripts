#
# 装備画面で、装備変更の候補となるアイテムの一覧を表示するウィンドウです。
#

class Window_EquipItem < Window_Item
  #
  # オブジェクト初期化
  #
  # x          : ウィンドウの X 座標
  # y          : ウィンドウの Y 座標
  # width      : ウィンドウの幅
  # height     : ウィンドウの高さ
  # actor      : アクター
  # equip_type : 装備部位 (0～4)
  #
  def initialize(x, y, width, height, actor, equip_type)
    @actor = actor
    if equip_type == 1 and actor.two_swords_style     # 二刀流なら
      equip_type = 0                                  # 盾を武器に変更
    end
    @equip_type = equip_type
    super(x, y, width, height)
  end
  #
  # アイテムをリストに含めるかどうか
  #
  # item : アイテム
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
  # アイテムを許可状態で表示するかどうか
  #
  # item : アイテム
  #
  def enable?(item)
    return true
  end
end
