#
# 读取各种图像，做成位图对象，并保存的模块。
# 为了节省内存以及读取高速化，生成的位图对象会保存在内部哈希，
# 当需要读取相同位图时可以从已保存的对象中提取。
#

module Cache
  #
  # 取得动画图像
  #
  # filename : 文件名
  # hue      : 色相变化值
  #
  def self.animation(filename, hue)
    load_bitmap("Graphics/Animations/", filename, hue)
  end
  #
  # 取得战斗图像
  #
  # filename : 文件名
  # hue      : 色相变化值
  #
  def self.battler(filename, hue)
    load_bitmap("Graphics/Battlers/", filename, hue)
  end
  #
  # 取得行走图
  #
  # filename : 文件名
  #
  def self.character(filename)
    load_bitmap("Graphics/Characters/", filename)
  end
  #
  # 取得脸图
  #
  # filename : 文件名
  #
  def self.face(filename)
    load_bitmap("Graphics/Faces/", filename)
  end
  #
  # 取得远景图
  #
  # filename : 文件名
  #
  def self.parallax(filename)
    load_bitmap("Graphics/Parallaxes/", filename)
  end
  #
  # 取得图片
  #
  # filename : 文件名
  #
  def self.picture(filename)
    load_bitmap("Graphics/Pictures/", filename)
  end
  #
  # 取得系统图像
  #
  # filename : 文件名
  #
  def self.system(filename)
    load_bitmap("Graphics/System/", filename)
  end
  #
  # 清除缓存
  #
  #
  def self.clear
    @cache = {} if @cache == nil
    @cache.clear
    GC.start
  end
  #
  # 读取位图
  #
  #
  def self.load_bitmap(folder_name, filename, hue = 0)
    @cache = {} if @cache == nil
    path = folder_name + filename
    if not @cache.include?(path) or @cache[path].disposed?
      if filename.empty?
        @cache[path] = Bitmap.new(32, 32)
      else
        @cache[path] = Bitmap.new(path)
      end
    end
    if hue == 0
      return @cache[path]
    else
      key = [path, hue]
      if not @cache.include?(key) or @cache[key].disposed?
        @cache[key] = @cache[path].clone
        @cache[key].hue_change(hue)
      end
      return @cache[key]
    end
  end
end
