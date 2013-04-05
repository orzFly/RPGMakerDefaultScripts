#
# 文章表示に使うメッセージウィンドウです。
#

class Window_Message < Window_Selectable
  #
  # 定数
  #
  #
  MAX_LINE = 4                            # 最大行数
  #
  # オブジェクト初期化
  #
  #
  def initialize
    super(0, 288, 544, 128)
    self.z = 200
    self.active = false
    self.index = -1
    self.openness = 0
    @opening = false            # ウィンドウのオープン中フラグ
    @closing = false            # ウィンドウのクローズ中フラグ
    @text = nil                 # 表示すべき残りの文章
    @contents_x = 0             # 次の文字を描画する X 座標
    @contents_y = 0             # 次の文字を描画する Y 座標
    @line_count = 0             # 現在までに描画した行数
    @wait_count = 0             # ウェイトカウント
    @background = 0             # 背景タイプ
    @position = 2               # 表示位置
    @show_fast = false          # 早送りフラグ
    @line_show_fast = false     # 行単位早送りフラグ
    @pause_skip = false         # 入力待ち省略フラグ
    create_gold_window
    create_number_input_window
    create_back_sprite
  end
  #
  # 解放
  #
  #
  def dispose
    super
    dispose_gold_window
    dispose_number_input_window
    dispose_back_sprite
  end
  #
  # フレーム更新
  #
  #
  def update
    super
    update_gold_window
    update_number_input_window
    update_back_sprite
    update_show_fast
    unless @opening or @closing             # ウィンドウの開閉中以外
      if @wait_count > 0                    # 文章内ウェイト中
        @wait_count -= 1
      elsif self.pause                      # 文章送り待機中
        input_pause
      elsif self.active                     # 選択肢入力中
        input_choice
      elsif @number_input_window.visible    # 数値入力中
        input_number
      elsif @text != nil                    # 残りの文章が存在
        update_message                        # メッセージの更新
      elsif continue?                       # 続ける場合
        start_message                         # メッセージの開始
        open                                  # ウィンドウを開く
        $game_message.visible = true
      else                                  # 続けない場合
        close                                 # ウィンドウを閉じる
        $game_message.visible = @closing
      end
    end
  end
  #
  # 所持金ウィンドウの作成
  #
  #
  def create_gold_window
    @gold_window = Window_Gold.new(384, 0)
    @gold_window.openness = 0
  end
  #
  # 数値入力ウィンドウの作成
  #
  #
  def create_number_input_window
    @number_input_window = Window_NumberInput.new
    @number_input_window.visible = false
  end
  #
  # 背景スプライトの作成
  #
  #
  def create_back_sprite
    @back_sprite = Sprite.new
    @back_sprite.bitmap = Cache.system("MessageBack")
    @back_sprite.visible = (@background == 1)
    @back_sprite.z = 190
  end
  #
  # 所持金ウィンドウの解放
  #
  #
  def dispose_gold_window
    @gold_window.dispose
  end
  #
  # 数値入力ウィンドウの解放
  #
  #
  def dispose_number_input_window
    @number_input_window.dispose
  end
  #
  # 背景スプライトの解放
  #
  #
  def dispose_back_sprite
    @back_sprite.dispose
  end
  #
  # 所持金ウィンドウの更新
  #
  #
  def update_gold_window
    @gold_window.update
  end
  #
  # 数値入力ウィンドウの更新
  #
  #
  def update_number_input_window
    @number_input_window.update
  end
  #
  # 背景スプライトの更新
  #
  #
  def update_back_sprite
    @back_sprite.visible = (@background == 1)
    @back_sprite.y = y - 16
    @back_sprite.opacity = openness
    @back_sprite.update
  end
  #
  # 早送りフラグの更新
  #
  #
  def update_show_fast
    if self.pause or self.openness < 255
      @show_fast = false
    elsif Input.trigger?(Input::C) and @wait_count < 2
      @show_fast = true
    elsif not Input.press?(Input::C)
      @show_fast = false
    end
    if @show_fast and @wait_count > 0
      @wait_count -= 1
    end
  end
  #
  # 次のメッセージを続けて表示するべきか判定
  #
  #
  def continue?
    return true if $game_message.num_input_variable_id > 0
    return false if $game_message.texts.empty?
    if self.openness > 0 and not $game_temp.in_battle
      return false if @background != $game_message.background
      return false if @position != $game_message.position
    end
    return true
  end
  #
  # メッセージの開始
  #
  #
  def start_message
    @text = ""
    for i in 0...$game_message.texts.size
      @text += "　　" if i >= $game_message.choice_start
      @text += $game_message.texts[i].clone + "\x00"
    end
    @item_max = $game_message.choice_max
    convert_special_characters
    reset_window
    new_page
  end
  #
  # 改ページ処理
  #
  #
  def new_page
    contents.clear
    if $game_message.face_name.empty?
      @contents_x = 0
    else
      name = $game_message.face_name
      index = $game_message.face_index
      draw_face(name, index, 0, 0)
      @contents_x = 112
    end
    @contents_y = 0
    @line_count = 0
    @show_fast = false
    @line_show_fast = false
    @pause_skip = false
    contents.font.color = text_color(0)
  end
  #
  # 改行処理
  #
  #
  def new_line
    if $game_message.face_name.empty?
      @contents_x = 0
    else
      @contents_x = 112
    end
    @contents_y += WLH
    @line_count += 1
    @line_show_fast = false
  end
  #
  # 特殊文字の変換
  #
  #
  def convert_special_characters
    @text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    @text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    @text.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
    @text.gsub!(/\\C\[([0-9]+)\]/i) { "\x01[#{$1}]" }
    @text.gsub!(/\\G/)              { "\x02" }
    @text.gsub!(/\\\./)             { "\x03" }
    @text.gsub!(/\\\|/)             { "\x04" }
    @text.gsub!(/\\!/)              { "\x05" }
    @text.gsub!(/\\>/)              { "\x06" }
    @text.gsub!(/\\</)              { "\x07" }
    @text.gsub!(/\\\^/)             { "\x08" }
    @text.gsub!(/\\\\/)             { "\\" }
  end
  #
  # ウィンドウの背景と位置の設定
  #
  #
  def reset_window
    @background = $game_message.background
    @position = $game_message.position
    if @background == 0   # 通常ウィンドウ
      self.opacity = 255
    else                  # 背景を暗くする、透明にする
      self.opacity = 0
    end
    case @position
    when 0  # 上
      self.y = 0
      @gold_window.y = 360
    when 1  # 中
      self.y = 144
      @gold_window.y = 0
    when 2  # 下
      self.y = 288
      @gold_window.y = 0
    end
  end
  #
  # メッセージの終了
  #
  #
  def terminate_message
    self.active = false
    self.pause = false
    self.index = -1
    @gold_window.close
    @number_input_window.active = false
    @number_input_window.visible = false
    $game_message.main_proc.call if $game_message.main_proc != nil
    $game_message.clear
  end
  #
  # メッセージの更新
  #
  #
  def update_message
    loop do
      c = @text.slice!(/./m)            # 次の文字を取得
      case c
      when nil                          # 描画すべき文字がない
        finish_message                  # 更新終了
        break
      when "\x00"                       # 改行
        new_line
        if @line_count >= MAX_LINE      # 行数が最大のとき
          unless @text.empty?           # さらに続きがあるなら
            self.pause = true           # 入力待ちを入れる
            break
          end
        end
      when "\x01"                       # \C[n]  (文字色変更)
        @text.sub!(/\[([0-9]+)\]/, "")
        contents.font.color = text_color($1.to_i)
        next
      when "\x02"                       # \G  (所持金表示)
        @gold_window.refresh
        @gold_window.open
      when "\x03"                       # \.  (ウェイト 1/4 秒)
        @wait_count = 15
        break
      when "\x04"                       # \|  (ウェイト 1 秒)
        @wait_count = 60
        break
      when "\x05"                       # \!  (入力待ち)
        self.pause = true
        break
      when "\x06"                       # \>  (瞬間表示 ON)
        @line_show_fast = true
      when "\x07"                       # \<  (瞬間表示 OFF)
        @line_show_fast = false
      when "\x08"                       # \^  (入力待ちなし)
        @pause_skip = true
      else                              # 普通の文字
        contents.draw_text(@contents_x, @contents_y, 40, WLH, c)
        c_width = contents.text_size(c).width
        @contents_x += c_width
      end
      break unless @show_fast or @line_show_fast
    end
  end
  #
  # メッセージの更新終了
  #
  #
  def finish_message
    if $game_message.choice_max > 0
      start_choice
    elsif $game_message.num_input_variable_id > 0
      start_number_input
    elsif @pause_skip
      terminate_message
    else
      self.pause = true
    end
    @wait_count = 10
    @text = nil
  end
  #
  # 選択肢の開始
  #
  #
  def start_choice
    self.active = true
    self.index = 0
  end
  #
  # 数値入力の開始
  #
  #
  def start_number_input
    digits_max = $game_message.num_input_digits_max
    number = $game_variables[$game_message.num_input_variable_id]
    @number_input_window.digits_max = digits_max
    @number_input_window.number = number
    if $game_message.face_name.empty?
      @number_input_window.x = x
    else
      @number_input_window.x = x + 112
    end
    @number_input_window.y = y + @contents_y
    @number_input_window.active = true
    @number_input_window.visible = true
    @number_input_window.update
  end
  #
  # カーソルの更新
  #
  #
  def update_cursor
    if @index >= 0
      x = $game_message.face_name.empty? ? 0 : 112
      y = ($game_message.choice_start + @index) * WLH
      self.cursor_rect.set(x, y, contents.width - x, WLH)
    else
      self.cursor_rect.empty
    end
  end
  #
  # 文章送りの入力処理
  #
  #
  def input_pause
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      self.pause = false
      if @text != nil and not @text.empty?
        new_page if @line_count >= MAX_LINE
      else
        terminate_message
      end
    end
  end
  #
  # 選択肢の入力処理
  #
  #
  def input_choice
    if Input.trigger?(Input::B)
      if $game_message.choice_cancel_type > 0
        Sound.play_cancel
        $game_message.choice_proc.call($game_message.choice_cancel_type - 1)
        terminate_message
      end
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      $game_message.choice_proc.call(self.index)
      terminate_message
    end
  end
  #
  # 数値入力の処理
  #
  #
  def input_number
    if Input.trigger?(Input::C)
      Sound.play_decision
      $game_variables[$game_message.num_input_variable_id] =
        @number_input_window.number
      $game_map.need_refresh = true
      terminate_message
    end
  end
end
