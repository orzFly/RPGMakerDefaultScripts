#encoding:utf-8
#
# 包裝了圖片數組的外殼。本類在 Game_Screen 類的內定使用。地圖圖塊圖像和戰鬥圖
# 像另行處理。
#

class Game_Pictures
  #
  # 初始化物件
  #
  #
  def initialize
    @data = []
  end
  #
  # 取得圖片
  #
  #
  def [](number)
    @data[number] ||= Game_Picture.new(number)
  end
  #
  # 迭代
  #
  #
  def each
    @data.compact.each {|picture| yield picture } if block_given?
  end
end
