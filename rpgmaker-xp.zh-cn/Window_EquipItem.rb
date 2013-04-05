#
# 装备画面、显示浏览变更装备的候补物品的窗口。
#

class Window_EquipItem < Window_Selectable
  #
  # 初始化对像
  #
  # actor      : 角色
  # equip_type : 装备部位 (0～3)
  #
  def initialize(actor, equip_type)
    super(0, 256, 640, 224)
    @actor = actor
    @equip_type = equip_type
    @column_max = 2
    refresh
    self.active = false
    self.index = -1
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
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    # 添加可以装备的武器
    if @equip_type == 0
      weapon_set = $data_classes[@actor.class_id].weapon_set
      for i in 1...$data_weapons.size
        if $game_party.weapon_number(i) > 0 and weapon_set.include?(i)
          @data.push($data_weapons[i])
        end
      end
    end
    # 添加可以装备的防具
    if @equip_type != 0
      armor_set = $data_classes[@actor.class_id].armor_set
      for i in 1...$data_armors.size
        if $game_party.armor_number(i) > 0 and armor_set.include?(i)
          if $data_armors[i].kind == @equip_type-1
            @data.push($data_armors[i])
          end
        end
      end
    end
    # 添加空白
    @data.push(nil)
    # 生成位图、描绘全部项目
    @item_max = @data.size
    self.contents = Bitmap.new(width - 32, row_max * 32)
    for i in 0...@item_max-1
      draw_item(i)
    end
  end
  #
  # 项目的描绘
  #
  # index : 项目符号
  #
  def draw_item(index)
    item = @data[index]
    x = 4 + index % 2 * (288 + 32)
    y = index / 2 * 32
    case item
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    bitmap = RPG::Cache.icon(item.icon_name)
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24))
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 28, y, 212, 32, item.name, 0)
    self.contents.draw_text(x + 240, y, 16, 32, ":", 1)
    self.contents.draw_text(x + 256, y, 24, 32, number.to_s, 2)
  end
  #
  # 刷新帮助文本
  #
  #
  def update_help
    @help_window.set_text(self.item == nil ? "" : self.item.description)
  end
end
