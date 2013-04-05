#encoding:utf-8
#
# 此模組載入所有圖像，建立並儲存 Bitmap 物件。為加快載入速度並節省記憶體，
# 此模組將以建立的 bitmap 物件儲存在內定哈希表中，使得程式在需要已存在
# 的圖像時能快速讀取 bitmap 物件。
#

module Cache
  #
  # 取得動畫圖像
  #
  #
  def self.animation(filename, hue)
    load_bitmap("Graphics/Animations/", filename, hue)
  end
  #
  # 取得戰鬥背景（地面）圖像
  #
  #
  def self.battleback1(filename)
    load_bitmap("Graphics/Battlebacks1/", filename)
  end
  #
  # 取得戰鬥背景（牆壁）圖像
  #
  #
  def self.battleback2(filename)
    load_bitmap("Graphics/Battlebacks2/", filename)
  end
  #
  # 取得戰鬥圖
  #
  #
  def self.battler(filename, hue)
    load_bitmap("Graphics/Battlers/", filename, hue)
  end
  #
  # 取得角色行走圖
  #
  #
  def self.character(filename)
    load_bitmap("Graphics/Characters/", filename)
  end
  #
  # 取得角色肖像圖
  #
  #
  def self.face(filename)
    load_bitmap("Graphics/Faces/", filename)
  end
  #
  # 取得遠景圖
  #
  #
  def self.parallax(filename)
    load_bitmap("Graphics/Parallaxes/", filename)
  end
  #
  # 取得“圖片”圖像
  #
  #
  def self.picture(filename)
    load_bitmap("Graphics/Pictures/", filename)
  end
  #
  # 取得系統圖像
  #
  #
  def self.system(filename)
    load_bitmap("Graphics/System/", filename)
  end
  #
  # 取得圖塊組圖像
  #
  #
  def self.tileset(filename)
    load_bitmap("Graphics/Tilesets/", filename)
  end
  #
  # 取得標題圖像（背景）
  #
  #
  def self.title1(filename)
    load_bitmap("Graphics/Titles1/", filename)
  end
  #
  # 取得標題圖像（外框）
  #
  #
  def self.title2(filename)
    load_bitmap("Graphics/Titles2/", filename)
  end
  #
  # 讀取點陣圖
  #
  #
  def self.load_bitmap(folder_name, filename, hue = 0)
    @cache ||= {}
    if filename.empty?
      empty_bitmap
    elsif hue == 0
      normal_bitmap(folder_name + filename)
    else
      hue_changed_bitmap(folder_name + filename, hue)
    end
  end
  #
  # 生成空點陣圖
  #
  #
  def self.empty_bitmap
    Bitmap.new(32, 32)
  end
  #
  # 生成／取得普通的點陣圖
  #
  #
  def self.normal_bitmap(path)
    @cache[path] = Bitmap.new(path) unless include?(path)
    @cache[path]
  end
  #
  # 生成／取得色相變化後的點陣圖
  #
  #
  def self.hue_changed_bitmap(path, hue)
    key = [path, hue]
    unless include?(key)
      @cache[key] = normal_bitmap(path).clone
      @cache[key].hue_change(hue)
    end
    @cache[key]
  end
  #
  # 檢查快取是否存在
  #
  #
  def self.include?(key)
    @cache[key] && !@cache[key].disposed?
  end
  #
  # 清理快取
  #
  #
  def self.clear
    @cache ||= {}
    @cache.clear
    GC.start
  end
end
