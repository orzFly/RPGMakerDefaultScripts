#
# 不包含存档数据，处理暂时使用数据的类。
# 这个类的实例请参照$game_temp
#

class Game_Temp
  #
  # 定义实例变量
  #
  #
  attr_accessor :next_scene               # 切换待机中的画面 (文字列)
  attr_accessor :map_bgm                  # 地图画面 BGM (战斗时候记忆用)
  attr_accessor :map_bgs                  # 地图画面 BGS (战斗时候记忆用)
  attr_accessor :common_event_id          # 公用事件 ID
  attr_accessor :in_battle                # 战斗中标记
  attr_accessor :battle_proc              # 战斗 返回调用 (Proc)
  attr_accessor :shop_goods               # 商店商品列表
  attr_accessor :shop_purchase_only       # 仅从商店买入的标记
  attr_accessor :name_actor_id            # 名称输入 角色 ID
  attr_accessor :name_max_char            # 名称输入 最大文字数
  attr_accessor :menu_beep                # 菜单 SE 演奏标记
  attr_accessor :last_file_index          # 最后保存的文件编号
  attr_accessor :debug_top_row            # Debug画面 状态保存用
  attr_accessor :debug_index              # Debug画面 状态保存用
  attr_accessor :background_bitmap        # 背景位图
  #
  # 初始化对象
  #
  #
  def initialize
    @next_scene = nil
    @map_bgm = nil
    @map_bgs = nil
    @common_event_id = 0
    @in_battle = false
    @battle_proc = nil
    @shop_goods = nil
    @shop_purchase_only = false
    @name_actor_id = 0
    @name_max_char = 0
    @menu_beep = false
    @last_file_index = 0
    @debug_top_row = 0
    @debug_index = 0
    @background_bitmap = Bitmap.new(1, 1)
  end
end
