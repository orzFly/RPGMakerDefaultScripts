#
# 输入名称的画面、文字选择窗口。
#

class Window_NameInput < Window_Base
  CHARACTER_TABLE =
  [
    "あ","い","う","え","お",
    "か","き","く","け","こ",
    "さ","し","す","せ","そ",
    "た","ち","つ","て","と",
    "な","に","ぬ","ね","の",
    "は","ひ","ふ","へ","ほ",
    "ま","み","む","め","も",
    "や", "" ,"ゆ", "" ,"よ",
    "ら","り","る","れ","ろ",
    "わ", "" ,"を", "" ,"ん",
    "が","ぎ","ぐ","げ","ご",
    "ざ","じ","ず","ぜ","ぞ",
    "だ","ぢ","づ","で","ど",
    "ば","び","ぶ","べ","ぼ",
    "ぱ","ぴ","ぷ","ぺ","ぽ",
    "ゃ","ゅ","ょ","っ","ゎ",
    "ぁ","ぃ","ぅ","ぇ","ぉ",
    "ー","・", "" , "" , "" ,
    "ア","イ","ウ","エ","オ",
    "カ","キ","ク","ケ","コ",
    "サ","シ","ス","セ","ソ",
    "タ","チ","ツ","テ","ト",
    "ナ","ニ","ヌ","ネ","ノ",
    "ハ","ヒ","フ","ヘ","ホ",
    "マ","ミ","ム","メ","モ",
    "ヤ", "" ,"ユ", "" ,"ヨ",
    "ラ","リ","ル","レ","ロ",
    "ワ", "" ,"ヲ", "" ,"ン",
    "ガ","ギ","グ","ゲ","ゴ",
    "ザ","ジ","ズ","ゼ","ゾ",
    "ダ","ヂ","ヅ","デ","ド",
    "バ","ビ","ブ","ベ","ボ",
    "パ","ピ","プ","ペ","ポ",
    "ャ","ュ","ョ","ッ","ヮ",
    "ァ","ィ","ゥ","ェ","ォ",
    "ー","・","ヴ", "" , "" ,
  ]
  #
  # 初始化对像
  #
  #
  def initialize
    super(0, 128, 640, 352)
    self.contents = Bitmap.new(width - 32, height - 32)
    @index = 0
    refresh
    update_cursor_rect
  end
  #
  # 获取文字
  #
  #
  def character
    return CHARACTER_TABLE[@index]
  end
  #
  # 刷新
  #
  #
  def refresh
    self.contents.clear
    for i in 0..179
      x = 4 + i / 5 / 9 * 152 + i % 5 * 28
      y = i / 5 % 9 * 32
      self.contents.draw_text(x, y, 28, 32, CHARACTER_TABLE[i], 1)
    end
    self.contents.draw_text(544, 9 * 32, 64, 32, "确定", 1)
  end
  #
  # 刷新光标矩形
  #
  #
  def update_cursor_rect
    # 光标位置在 [确定] 的情况下
    if @index >= 180
      self.cursor_rect.set(544, 9 * 32, 64, 32)
    # 光标位置在 [确定] 以外的情况下
    else
      x = 4 + @index / 5 / 9 * 152 + @index % 5 * 28
      y = @index / 5 % 9 * 32
      self.cursor_rect.set(x, y, 28, 32)
    end
  end
  #
  # 刷新画面
  #
  #
  def update
    super
    # 光标位置在 [确定] 的情况下
    if @index >= 180
      # 光标下
      if Input.trigger?(Input::DOWN)
        $game_system.se_play($data_system.cursor_se)
        @index -= 180
      end
      # 光标上
      if Input.repeat?(Input::UP)
        $game_system.se_play($data_system.cursor_se)
        @index -= 180 - 40
      end
    # 光标位置在 [确定] 以外的情况下
    else
      # 按下方向键右的情况下
      if Input.repeat?(Input::RIGHT)
        # 按下状态不是重复的情况下、
        # 光标位置不在右端的情况下
        if Input.trigger?(Input::RIGHT) or
           @index / 45 < 3 or @index % 5 < 4
          # 光标向右移动
          $game_system.se_play($data_system.cursor_se)
          if @index % 5 < 4
            @index += 1
          else
            @index += 45 - 4
          end
          if @index >= 180
            @index -= 180
          end
        end
      end
      # 按下方向键左的情况下
      if Input.repeat?(Input::LEFT)
        # 按下状态不是重复的情况下、
        # 光标位置不在左端的情况下
        if Input.trigger?(Input::LEFT) or
           @index / 45 > 0 or @index % 5 > 0
          # 光标向右移动
          $game_system.se_play($data_system.cursor_se)
          if @index % 5 > 0
            @index -= 1
          else
            @index -= 45 - 4
          end
          if @index < 0
            @index += 180
          end
        end
      end
      # 按下方向键下的情况下
      if Input.repeat?(Input::DOWN)
        # 光标向下移动
        $game_system.se_play($data_system.cursor_se)
        if @index % 45 < 40
          @index += 5
        else
          @index += 180 - 40
        end
      end
      # 按下方向键上的情况下
      if Input.repeat?(Input::UP)
        # 按下状态不是重复的情况下、
        # 光标位置不在上端的情况下
        if Input.trigger?(Input::UP) or @index % 45 >= 5
          # 光标向上移动
          $game_system.se_play($data_system.cursor_se)
          if @index % 45 >= 5
            @index -= 5
          else
            @index += 180
          end
        end
      end
      # L 键与 R 键被按下的情况下
      if Input.repeat?(Input::L) or Input.repeat?(Input::R)
        # 平假名 / 片假名 之间移动
        $game_system.se_play($data_system.cursor_se)
        if @index / 45 < 2
          @index += 90
        else
          @index -= 90
        end
      end
    end
    update_cursor_rect
  end
end
