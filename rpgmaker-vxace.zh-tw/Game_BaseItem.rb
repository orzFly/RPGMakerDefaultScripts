#encoding:utf-8
#
# 管理技能、物品、武器、護甲的統一類。會根據自己的所屬類別而管理不同的資料。
#

class Game_BaseItem
  #
  # 初始化物件
  #
  #
  def initialize
    @class = nil
    @item_id = 0
  end
  #
  # 判定類
  #
  #
  def is_skill?;   @class == RPG::Skill;   end
  def is_item?;    @class == RPG::Item;    end
  def is_weapon?;  @class == RPG::Weapon;  end
  def is_armor?;   @class == RPG::Armor;   end
  def is_nil?;     @class == nil;          end
  #
  # 取得物品案例
  #
  #
  def object
    return $data_skills[@item_id]  if is_skill?
    return $data_items[@item_id]   if is_item?
    return $data_weapons[@item_id] if is_weapon?
    return $data_armors[@item_id]  if is_armor?
    return nil
  end
  #
  # 設定物品案例
  #
  #
  def object=(item)
    @class = item ? item.class : nil
    @item_id = item ? item.id : 0
  end
  #
  # 設定裝備的 ID
  #
  # is_weapon : 是否武器
  # item_id   : 武器／護甲 ID
  #
  def set_equip(is_weapon, item_id)
    @class = is_weapon ? RPG::Weapon : RPG::Armor
    @item_id = item_id
  end
end
