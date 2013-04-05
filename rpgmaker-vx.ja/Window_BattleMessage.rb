#
# 戦闘中に表示するメッセージウィンドウです。通常のメッセージウィンドウの機能
# に加え、戦闘進行のナレーションを表示する機能を持ちます。
#

class Window_BattleMessage < Window_Message
  #
  # オブジェクト初期化
  #
  #
  def initialize
    super
    self.openness = 255
    @lines = []
    refresh
  end
  #
  # 解放
  #
  #
  def dispose
    super
  end
  #
  # フレーム更新
  #
  #
  def update
    super
  end
  #
  # ウィンドウを開く (無効化)
  #
  #
  def open
  end
  #
  # ウィンドウを閉じる (無効化)
  #
  #
  def close
  end
  #
  # ウィンドウの背景と位置の設定 (無効化)
  #
  #
  def reset_window
  end
  #
  # クリア
  #
  #
  def clear
    @lines.clear
    refresh
  end
  #
  # 行数の取得
  #
  #
  def line_number
    return @lines.size
  end
  #
  # 一行戻る
  #
  #
  def back_one
    @lines.pop
    refresh
  end
  #
  # 指定した行に戻る
  #
  # line_number : 行番号
  #
  def back_to(line_number)
    while @lines.size > line_number
      @lines.pop
    end
    refresh
  end
  #
  # 文章の追加
  #
  # text : 追加する文章
  #
  def add_instant_text(text)
    @lines.push(text)
    refresh
  end
  #
  # 文章の置き換え
  #
  # text : 置き換える文章
  # 最下行を別の文章に置き換える。
  #
  def replace_instant_text(text)
    @lines.pop
    @lines.push(text)
    refresh
  end
  #
  # 最下行の文章の取得
  #
  #
  def last_instant_text
    return @lines[-1]
  end
  #
  # リフレッシュ
  #
  #
  def refresh
    self.contents.clear
    for i in 0...@lines.size
      draw_line(i)
    end
  end
  #
  # 行の描画
  #
  # index : 行番号
  #
  def draw_line(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.x += 4
    rect.y += index * WLH
    rect.width = contents.width - 8
    rect.height = WLH
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.draw_text(rect, @lines[index])
  end
end
