#
# スキルやアイテムの説明、アクターのステータスなどを表示するウィンドウです。
#

class Window_Help < Window_Base
  #
  # オブジェクト初期化
  #
  #
  def initialize
    super(0, 0, 544, WLH + 32)
  end
  #
  # テキスト設定
  #
  # text  : ウィンドウに表示する文字列
  # align : アラインメント (0..左揃え、1..中央揃え、2..右揃え)
  #
  def set_text(text, align = 0)
    if text != @text or align != @align
      self.contents.clear
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, self.width - 40, WLH, text, align)
      @text = text
      @align = align
    end
  end
end
