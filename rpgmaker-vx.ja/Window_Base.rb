#
# ゲーム中のすべてのウィンドウのスーパークラスです。
#

class Window_Base < Window
  #
  # 定数
  #
  #
  WLH = 24                  # 行の高さ基準値 (Window Line Height)
  #
  # オブジェクト初期化
  #
  # x      : ウィンドウの X 座標
  # y      : ウィンドウの Y 座標
  # width  : ウィンドウの幅
  # height : ウィンドウの高さ
  #
  def initialize(x, y, width, height)
    super()
    self.windowskin = Cache.system("Window")
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.z = 100
    self.back_opacity = 200
    self.openness = 255
    create_contents
    @opening = false
    @closing = false
  end
  #
  # 解放
  #
  #
  def dispose
    self.contents.dispose
    super
  end
  #
  # ウィンドウ内容の作成
  #
  #
  def create_contents
    self.contents.dispose
    self.contents = Bitmap.new(width - 32, height - 32)
  end
  #
  # フレーム更新
  #
  #
  def update
    super
    if @opening
      self.openness += 48
      @opening = false if self.openness == 255
    elsif @closing
      self.openness -= 48
      @closing = false if self.openness == 0
    end
  end
  #
  # ウィンドウを開く
  #
  #
  def open
    @opening = true if self.openness < 255
    @closing = false
  end
  #
  # ウィンドウを閉じる
  #
  #
  def close
    @closing = true if self.openness > 0
    @opening = false
  end
  #
  # 文字色取得
  #
  # n : 文字色番号 (0～31)
  #
  def text_color(n)
    x = 64 + (n % 8) * 8
    y = 96 + (n / 8) * 8
    return windowskin.get_pixel(x, y)
  end
  #
  # 通常文字色の取得
  #
  #
  def normal_color
    return text_color(0)
  end
  #
  # システム文字色の取得
  #
  #
  def system_color
    return text_color(16)
  end
  #
  # ピンチ文字色の取得
  #
  #
  def crisis_color
    return text_color(17)
  end
  #
  # 戦闘不能文字色の取得
  #
  #
  def knockout_color
    return text_color(18)
  end
  #
  # ゲージ背景色の取得
  #
  #
  def gauge_back_color
    return text_color(19)
  end
  #
  # HP ゲージの色 1 の取得
  #
  #
  def hp_gauge_color1
    return text_color(20)
  end
  #
  # HP ゲージの色 2 の取得
  #
  #
  def hp_gauge_color2
    return text_color(21)
  end
  #
  # MP ゲージの色 1 の取得
  #
  #
  def mp_gauge_color1
    return text_color(22)
  end
  #
  # MP ゲージの色 2 の取得
  #
  #
  def mp_gauge_color2
    return text_color(23)
  end
  #
  # 装備画面のパワーアップ色の取得
  #
  #
  def power_up_color
    return text_color(24)
  end
  #
  # 装備画面のパワーダウン色の取得
  #
  #
  def power_down_color
    return text_color(25)
  end
  #
  # アイコンの描画
  #
  # icon_index : アイコン番号
  # x          : 描画先 X 座標
  # y          : 描画先 Y 座標
  # enabled    : 有効フラグ。false のとき半透明で描画
  #
  def draw_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    self.contents.blt(x, y, bitmap, rect, enabled ? 255 : 128)
  end
  #
  # 顔グラフィックの描画
  #
  # face_name  : 顔グラフィック ファイル名
  # face_index : 顔グラフィック インデックス
  # x          : 描画先 X 座標
  # y          : 描画先 Y 座標
  # size       : 表示サイズ
  #
  def draw_face(face_name, face_index, x, y, size = 96)
    bitmap = Cache.face(face_name)
    rect = Rect.new(0, 0, 0, 0)
    rect.x = face_index % 4 * 96 + (96 - size) / 2
    rect.y = face_index / 4 * 96 + (96 - size) / 2
    rect.width = size
    rect.height = size
    self.contents.blt(x, y, bitmap, rect)
    bitmap.dispose
  end
  #
  # 歩行グラフィックの描画
  #
  # character_name  : 歩行グラフィック ファイル名
  # character_index : 歩行グラフィック インデックス
  # x               : 描画先 X 座標
  # y               : 描画先 Y 座標
  #
  def draw_character(character_name, character_index, x, y)
    return if character_name == nil
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
  #
  # HP の文字色を取得
  #
  # actor : アクター
  #
  def hp_color(actor)
    return knockout_color if actor.hp == 0
    return crisis_color if actor.hp < actor.maxhp / 4
    return normal_color
  end
  #
  # MP の文字色を取得
  #
  # actor : アクター
  #
  def mp_color(actor)
    return crisis_color if actor.mp < actor.maxmp / 4
    return normal_color
  end
  #
  # アクターの歩行グラフィック描画
  #
  # actor : アクター
  # x     : 描画先 X 座標
  # y     : 描画先 Y 座標
  #
  def draw_actor_graphic(actor, x, y)
    draw_character(actor.character_name, actor.character_index, x, y)
  end
  #
  # アクターの顔グラフィック描画
  #
  # actor : アクター
  # x     : 描画先 X 座標
  # y     : 描画先 Y 座標
  # size  : 表示サイズ
  #
  def draw_actor_face(actor, x, y, size = 96)
    draw_face(actor.face_name, actor.face_index, x, y, size)
  end
  #
  # 名前の描画
  #
  # actor : アクター
  # x     : 描画先 X 座標
  # y     : 描画先 Y 座標
  #
  def draw_actor_name(actor, x, y)
    self.contents.font.color = hp_color(actor)
    self.contents.draw_text(x, y, 108, WLH, actor.name)
  end
  #
  # クラスの描画
  #
  # actor : アクター
  # x     : 描画先 X 座標
  # y     : 描画先 Y 座標
  #
  def draw_actor_class(actor, x, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, 108, WLH, actor.class.name)
  end
  #
  # レベルの描画
  #
  # actor : アクター
  # x     : 描画先 X 座標
  # y     : 描画先 Y 座標
  #
  def draw_actor_level(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, WLH, Vocab::level_a)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 32, y, 24, WLH, actor.level, 2)
  end
  #
  # ステートの描画
  #
  # actor : アクター
  # x     : 描画先 X 座標
  # y     : 描画先 Y 座標
  # width : 描画先の幅
  #
  def draw_actor_state(actor, x, y, width = 96)
    count = 0
    for state in actor.states
      draw_icon(state.icon_index, x + 24 * count, y)
      count += 1
      break if (24 * count > width - 24)
    end
  end
  #
  # HP の描画
  #
  # actor : アクター
  # x     : 描画先 X 座標
  # y     : 描画先 Y 座標
  # width : 幅
  #
  def draw_actor_hp(actor, x, y, width = 120)
    draw_actor_hp_gauge(actor, x, y, width)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 30, WLH, Vocab::hp_a)
    self.contents.font.color = hp_color(actor)
    xr = x + width
    if width < 120
      self.contents.draw_text(xr - 40, y, 40, WLH, actor.hp, 2)
    else
      self.contents.draw_text(xr - 90, y, 40, WLH, actor.hp, 2)
      self.contents.font.color = normal_color
      self.contents.draw_text(xr - 50, y, 10, WLH, "/", 2)
      self.contents.draw_text(xr - 40, y, 40, WLH, actor.maxhp, 2)
    end
  end
  #
  # HP ゲージの描画
  #
  # actor : アクター
  # x     : 描画先 X 座標
  # y     : 描画先 Y 座標
  # width : 幅
  #
  def draw_actor_hp_gauge(actor, x, y, width = 120)
    gw = width * actor.hp / actor.maxhp
    gc1 = hp_gauge_color1
    gc2 = hp_gauge_color2
    self.contents.fill_rect(x, y + WLH - 8, width, 6, gauge_back_color)
    self.contents.gradient_fill_rect(x, y + WLH - 8, gw, 6, gc1, gc2)
  end
  #
  # MP の描画
  #
  # actor : アクター
  # x     : 描画先 X 座標
  # y     : 描画先 Y 座標
  # width : 幅
  #
  def draw_actor_mp(actor, x, y, width = 120)
    draw_actor_mp_gauge(actor, x, y, width)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 30, WLH, Vocab::mp_a)
    self.contents.font.color = mp_color(actor)
    xr = x + width
    if width < 120
      self.contents.draw_text(xr - 40, y, 40, WLH, actor.mp, 2)
    else
      self.contents.draw_text(xr - 90, y, 40, WLH, actor.mp, 2)
      self.contents.font.color = normal_color
      self.contents.draw_text(xr - 50, y, 10, WLH, "/", 2)
      self.contents.draw_text(xr - 40, y, 40, WLH, actor.maxmp, 2)
    end
  end
  #
  # MP ゲージの描画
  #
  # actor : アクター
  # x     : 描画先 X 座標
  # y     : 描画先 Y 座標
  # width : 幅
  #
  def draw_actor_mp_gauge(actor, x, y, width = 120)
    gw = width * actor.mp / [actor.maxmp, 1].max
    gc1 = mp_gauge_color1
    gc2 = mp_gauge_color2
    self.contents.fill_rect(x, y + WLH - 8, width, 6, gauge_back_color)
    self.contents.gradient_fill_rect(x, y + WLH - 8, gw, 6, gc1, gc2)
  end
  #
  # 能力値の描画
  #
  # actor : アクター
  # x     : 描画先 X 座標
  # y     : 描画先 Y 座標
  # type  : 能力値の種類 (0～3)
  #
  def draw_actor_parameter(actor, x, y, type)
    case type
    when 0
      parameter_name = Vocab::atk
      parameter_value = actor.atk
    when 1
      parameter_name = Vocab::def
      parameter_value = actor.def
    when 2
      parameter_name = Vocab::spi
      parameter_value = actor.spi
    when 3
      parameter_name = Vocab::agi
      parameter_value = actor.agi
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, WLH, parameter_name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 120, y, 36, WLH, parameter_value, 2)
  end
  #
  # アイテム名の描画
  #
  # item    : アイテム (スキル、武器、防具でも可)
  # x       : 描画先 X 座標
  # y       : 描画先 Y 座標
  # enabled : 有効フラグ。false のとき半透明で描画
  #
  def draw_item_name(item, x, y, enabled = true)
    if item != nil
      draw_icon(item.icon_index, x, y, enabled)
      self.contents.font.color = normal_color
      self.contents.font.color.alpha = enabled ? 255 : 128
      self.contents.draw_text(x + 24, y, 172, WLH, item.name)
    end
  end
  #
  # 通貨単位つきの数値描画
  #
  # value : 数値 (所持金など)
  # x     : 描画先 X 座標
  # y     : 描画先 Y 座標
  # width : 幅
  #
  def draw_currency_value(value, x, y, width)
    cx = contents.text_size(Vocab::gold).width
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, width-cx-2, WLH, value, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, width, WLH, Vocab::gold, 2)
  end
end
