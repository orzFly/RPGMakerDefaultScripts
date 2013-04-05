#encoding:utf-8
#
# 場景切換的管理器。RGSS3 內置了新功能，在使用 call 方法切換新場景時，可以
# 用 return 方法返回上一個場景。
#

module SceneManager
  #
  # 模組的案例變量
  #
  #
  @scene = nil                            # 當前場景案例
  @stack = []                             # 場景切換的記錄
  @background_bitmap = nil                # 背景用的場景截圖
  #
  # 運行
  #
  #
  def self.run
    DataManager.init
    Audio.setup_midi if use_midi?
    @scene = first_scene_class.new
    @scene.main while @scene
  end
  #
  # 取得最初場景的所屬類
  #
  #
  def self.first_scene_class
    $BTEST ? Scene_Battle : Scene_Title
  end
  #
  # 是否使用 MIDI 
  #
  #
  def self.use_midi?
    $data_system.opt_use_midi
  end
  #
  # 取得當前場景
  #
  #
  def self.scene
    @scene
  end
  #
  # 判定當前場景的所屬類
  #
  #
  def self.scene_is?(scene_class)
    @scene.instance_of?(scene_class)
  end
  #
  # 直接切換某個場景（無過渡）
  #
  #
  def self.goto(scene_class)
    @scene = scene_class.new
  end
  #
  # 切換
  #
  #
  def self.call(scene_class)
    @stack.push(@scene)
    @scene = scene_class.new
  end
  #
  # 返回到上一個場景
  #
  #
  def self.return
    @scene = @stack.pop
  end
  #
  # 清理場景切換的記錄
  #
  #
  def self.clear
    @stack.clear
  end
  #
  # 離開游戲
  #
  #
  def self.exit
    @scene = nil
  end
  #
  # 生成背景用的場景截圖
  #
  #
  def self.snapshot_for_background
    @background_bitmap.dispose if @background_bitmap
    @background_bitmap = Graphics.snap_to_bitmap
    @background_bitmap.blur
  end
  #
  # 取得背景用的場景截圖
  #
  #
  def self.background_bitmap
    @background_bitmap
  end
end
