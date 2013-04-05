#
# 名前入力画面で、文字を選択するウィンドウです。
#

class Window_NameInput < Window_Base
  #
  # 文字表
  #
  #
  HIRAGANA = [ 'あ','い','う','え','お',  'が','ぎ','ぐ','げ','ご',
               'か','き','く','け','こ',  'ざ','じ','ず','ぜ','ぞ',
               'さ','し','す','せ','そ',  'だ','ぢ','づ','で','ど',
               'た','ち','つ','て','と',  'ば','び','ぶ','べ','ぼ',
               'な','に','ぬ','ね','の',  'ぱ','ぴ','ぷ','ぺ','ぽ',
               'は','ひ','ふ','へ','ほ',  'ぁ','ぃ','ぅ','ぇ','ぉ',
               'ま','み','む','め','も',  'っ','ゃ','ゅ','ょ','ゎ',
               'や','ゆ','よ','わ','ん',  'ー','～','・','＝','☆',
               'ら','り','る','れ','ろ',  'ゔ','を','','カナ','決定']
  KATAKANA = [ 'ア','イ','ウ','エ','オ',  'ガ','ギ','グ','ゲ','ゴ',
               'カ','キ','ク','ケ','コ',  'ザ','ジ','ズ','ゼ','ゾ',
               'サ','シ','ス','セ','ソ',  'ダ','ヂ','ヅ','デ','ド',
               'タ','チ','ツ','テ','ト',  'バ','ビ','ブ','ベ','ボ',
               'ナ','ニ','ヌ','ネ','ノ',  'パ','ピ','プ','ペ','ポ',
               'ハ','ヒ','フ','ヘ','ホ',  'ァ','ィ','ゥ','ェ','ォ',
               'マ','ミ','ム','メ','モ',  'ッ','ャ','ュ','ョ','ヮ',
               'ヤ','ユ','ヨ','ワ','ン',  'ー','～','・','＝','☆',
               'ラ','リ','ル','レ','ロ',  'ヴ','ヲ','','かな','決定']
  TABLE = [HIRAGANA, KATAKANA]
  #
  # オブジェクト初期化
  #
  # mode : 初期入力モード (0 = ひらがな、1 = カタカナ)
  #
  def initialize(mode = 0)
    super(88, 148, 368, 248)
    @mode = mode
    @index = 0
    refresh
    update_cursor
  end
  #
  # 文字の取得
  #
  #
  def character
    if @index < 88
      return TABLE[@mode][@index]
    else
      return ""
    end
  end
  #
  # カーソル位置 モード切り替え判定 (かな/カナ)
  #
  #
  def is_mode_change
    return (@index == 88)
  end
  #
  # カーソル位置 決定判定
  #
  #
  def is_decision
    return (@index == 89)
  end
  #
  # 項目を描画する矩形の取得
  #
  # index : 項目番号
  #
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.x = index % 10 * 32 + index % 10 / 5 * 16
    rect.y = index / 10 * WLH
    rect.width = 32
    rect.height = WLH
    return rect
  end
  #
  # リフレッシュ
  #
  #
  def refresh
    self.contents.clear
    for i in 0..89
      rect = item_rect(i)
      rect.x += 2
      rect.width -= 4
      self.contents.draw_text(rect, TABLE[@mode][i], 1)
    end
  end
  #
  # カーソルの更新
  #
  #
  def update_cursor
    self.cursor_rect = item_rect(@index)
  end
  #
  # カーソルを下に移動
  #
  # wrap : ラップアラウンド許可
  #
  def cursor_down(wrap)
    if @index < 80
      @index += 10
    elsif wrap
      @index -= 80
    end
  end
  #
  # カーソルを上に移動
  #
  # wrap : ラップアラウンド許可
  #
  def cursor_up(wrap)
    if @index >= 10
      @index -= 10
    elsif wrap
      @index += 80
    end
  end
  #
  # カーソルを右に移動
  #
  # wrap : ラップアラウンド許可
  #
  def cursor_right(wrap)
    if @index % 10 < 9
      @index += 1
    elsif wrap
      @index -= 9
    end
  end
  #
  # カーソルを左に移動
  #
  # wrap : ラップアラウンド許可
  #
  def cursor_left(wrap)
    if @index % 10 > 0
      @index -= 1
    elsif wrap
      @index += 9
    end
  end
  #
  # カーソルを決定へ移動
  #
  #
  def cursor_to_decision
    @index = 89
  end
  #
  # 次のページへ移動
  #
  #
  def cursor_pagedown
    @mode = (@mode + 1) % TABLE.size
    refresh
  end
  #
  # 前のページへ移動
  #
  #
  def cursor_pageup
    @mode = (@mode + TABLE.size - 1) % TABLE.size
    refresh
  end
  #
  # フレーム更新
  #
  #
  def update
    super
    last_mode = @mode
    last_index = @index
    if Input.repeat?(Input::DOWN)
      cursor_down(Input.trigger?(Input::DOWN))
    end
    if Input.repeat?(Input::UP)
      cursor_up(Input.trigger?(Input::UP))
    end
    if Input.repeat?(Input::RIGHT)
      cursor_right(Input.trigger?(Input::RIGHT))
    end
    if Input.repeat?(Input::LEFT)
      cursor_left(Input.trigger?(Input::LEFT))
    end
    if Input.trigger?(Input::A)
      cursor_to_decision
    end
    if Input.trigger?(Input::R)
      cursor_pagedown
    end
    if Input.trigger?(Input::L)
      cursor_pageup
    end
    if Input.trigger?(Input::C) and is_mode_change
      cursor_pagedown
    end
    if @index != last_index or @mode != last_mode
      Sound.play_cursor
    end
    update_cursor
  end
end
