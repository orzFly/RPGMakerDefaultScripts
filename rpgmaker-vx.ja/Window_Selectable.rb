#
# カーソルの移動やスクロールの機能を持つウィンドウクラスです。
#

class Window_Selectable < Window_Base
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :item_max                 # 項目数
  attr_reader   :column_max               # 桁数
  attr_reader   :index                    # カーソル位置
  attr_reader   :help_window              # ヘルプウィンドウ
  #
  # オブジェクト初期化
  #
  # x       : ウィンドウの X 座標
  # y       : ウィンドウの Y 座標
  # width   : ウィンドウの幅
  # height  : ウィンドウの高さ
  # spacing : 横に項目が並ぶときの空白の幅
  #
  def initialize(x, y, width, height, spacing = 32)
    @item_max = 1
    @column_max = 1
    @index = -1
    @spacing = spacing
    super(x, y, width, height)
  end
  #
  # ウィンドウ内容の作成
  #
  #
  def create_contents
    self.contents.dispose
    self.contents = Bitmap.new(width - 32, [height - 32, row_max * WLH].max)
  end
  #
  # カーソル位置の設定
  #
  # index : 新しいカーソル位置
  #
  def index=(index)
    @index = index
    update_cursor
    call_update_help
  end
  #
  # 行数の取得
  #
  #
  def row_max
    return (@item_max + @column_max - 1) / @column_max
  end
  #
  # 先頭の行の取得
  #
  #
  def top_row
    return self.oy / WLH
  end
  #
  # 先頭の行の設定
  #
  # row : 先頭に表示する行
  #
  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    self.oy = row * WLH
  end
  #
  # 1 ページに表示できる行数の取得
  #
  #
  def page_row_max
    return (self.height - 32) / WLH
  end
  #
  # 1 ページに表示できる項目数の取得
  #
  #
  def page_item_max
    return page_row_max * @column_max
  end
  #
  # 末尾の行の取得
  #
  #
  def bottom_row
    return top_row + page_row_max - 1
  end
  #
  # 末尾の行の設定
  #
  # row : 末尾に表示する行
  #
  def bottom_row=(row)
    self.top_row = row - (page_row_max - 1)
  end
  #
  # 項目を描画する矩形の取得
  #
  # index : 項目番号
  #
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = WLH
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = index / @column_max * WLH
    return rect
  end
  #
  # ヘルプウィンドウの設定
  #
  # help_window : 新しいヘルプウィンドウ
  #
  def help_window=(help_window)
    @help_window = help_window
    call_update_help
  end
  #
  # カーソルの移動可能判定
  #
  #
  def cursor_movable?
    return false if (not visible or not active)
    return false if (index < 0 or index > @item_max or @item_max == 0)
    return false if (@opening or @closing)
    return true
  end
  #
  # カーソルを下に移動
  #
  # wrap : ラップアラウンド許可
  #
  def cursor_down(wrap = false)
    if (@index < @item_max - @column_max) or (wrap and @column_max == 1)
      @index = (@index + @column_max) % @item_max
    end
  end
  #
  # カーソルを上に移動
  #
  # wrap : ラップアラウンド許可
  #
  def cursor_up(wrap = false)
    if (@index >= @column_max) or (wrap and @column_max == 1)
      @index = (@index - @column_max + @item_max) % @item_max
    end
  end
  #
  # カーソルを右に移動
  #
  # wrap : ラップアラウンド許可
  #
  def cursor_right(wrap = false)
    if (@column_max >= 2) and
       (@index < @item_max - 1 or (wrap and page_row_max == 1))
      @index = (@index + 1) % @item_max
    end
  end
  #
  # カーソルを左に移動
  #
  # wrap : ラップアラウンド許可
  #
  def cursor_left(wrap = false)
    if (@column_max >= 2) and
       (@index > 0 or (wrap and page_row_max == 1))
      @index = (@index - 1 + @item_max) % @item_max
    end
  end
  #
  # カーソルを 1 ページ後ろに移動
  #
  #
  def cursor_pagedown
    if top_row + page_row_max < row_max
      @index = [@index + page_item_max, @item_max - 1].min
      self.top_row += page_row_max
    end
  end
  #
  # カーソルを 1 ページ前に移動
  #
  #
  def cursor_pageup
    if top_row > 0
      @index = [@index - page_item_max, 0].max
      self.top_row -= page_row_max
    end
  end
  #
  # フレーム更新
  #
  #
  def update
    super
    if cursor_movable?
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
      if Input.repeat?(Input::R)
        cursor_pagedown
      end
      if Input.repeat?(Input::L)
        cursor_pageup
      end
      if @index != last_index
        Sound.play_cursor
      end
    end
    update_cursor
    call_update_help
  end
  #
  # カーソルの更新
  #
  #
  def update_cursor
    if @index < 0                   # カーソル位置が 0 未満の場合
      self.cursor_rect.empty        # カーソルを無効とする
    else                            # カーソル位置が 0 以上の場合
      row = @index / @column_max    # 現在の行を取得
      if row < top_row              # 表示されている先頭の行より前の場合
        self.top_row = row          # 現在の行が先頭になるようにスクロール
      end
      if row > bottom_row           # 表示されている末尾の行より後ろの場合
        self.bottom_row = row       # 現在の行が末尾になるようにスクロール
      end
      rect = item_rect(@index)      # 選択されている項目の矩形を取得
      rect.y -= self.oy             # 矩形をスクロール位置に合わせる
      self.cursor_rect = rect       # カーソルの矩形を更新
    end
  end
  #
  # ヘルプウィンドウ更新メソッドの呼び出し
  #
  #
  def call_update_help
    if self.active and @help_window != nil
       update_help
    end
  end
  #
  # ヘルプウィンドウの更新 (内容は継承先で定義する)
  #
  #
  def update_help
  end
end
