#
# 装備画面で、アクターの能力値変化を表示するウィンドウです。
#

class Window_EquipStatus < Window_Base
  #
  # オブジェクト初期化
  #
  # x     : ウィンドウの X 座標
  # y     : ウィンドウの Y 座標
  # actor : アクター
  #
  def initialize(x, y, actor)
    super(x, y, 208, WLH * 5 + 32)
    @actor = actor
    refresh
  end
  #
  # リフレッシュ
  #
  #
  def refresh
    self.contents.clear
    draw_actor_name(@actor, 4, 0)
    draw_parameter(0, WLH * 1, 0)
    draw_parameter(0, WLH * 2, 1)
    draw_parameter(0, WLH * 3, 2)
    draw_parameter(0, WLH * 4, 3)
  end
  #
  # 装備変更後の能力値設定
  #
  # new_atk : 装備変更後の攻撃力
  # new_def : 装備変更後の防御力
  # new_spi : 装備変更後の精神力
  # new_agi : 装備変更後の敏捷性
  #
  def set_new_parameters(new_atk, new_def, new_spi, new_agi)
    if @new_atk != new_atk or @new_def != new_def or
       @new_spi != new_spi or @new_agi != new_agi
      @new_atk = new_atk
      @new_def = new_def
      @new_spi = new_spi
      @new_agi = new_agi
      refresh
    end
  end
  #
  # 装備変更後の能力値の描画色取得
  #
  # old_value : 装備変更前の能力値
  # new_value : 装備変更後の能力値
  #
  def new_parameter_color(old_value, new_value)
    if new_value > old_value      # 強くなる
      return power_up_color
    elsif new_value == old_value  # 変わらず
      return normal_color
    else                          # 弱くなる
      return power_down_color
    end
  end
  #
  # 能力値の描画
  #
  # x    : 描画先 X 座標
  # y    : 描画先 Y 座標
  # type : 能力値の種類 (0～3)
  #
  def draw_parameter(x, y, type)
    case type
    when 0
      name = Vocab::atk
      value = @actor.atk
      new_value = @new_atk
    when 1
      name = Vocab::def
      value = @actor.def
      new_value = @new_def
    when 2
      name = Vocab::spi
      value = @actor.spi
      new_value = @new_spi
    when 3
      name = Vocab::agi
      value = @actor.agi
      new_value = @new_agi
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x + 4, y, 80, WLH, name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 90, y, 30, WLH, value, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(x + 122, y, 20, WLH, "→", 1)
    if new_value != nil
      self.contents.font.color = new_parameter_color(value, new_value)
      self.contents.draw_text(x + 142, y, 30, WLH, new_value, 2)
    end
  end
end
