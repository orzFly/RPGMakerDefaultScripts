#
# 色調変更やフラッシュなど、画面全体に関係する処理のデータを保持するクラスで
# す。このクラスは Game_Map クラス、Game_Troop クラスの内部で使用されます。
#

class Game_Screen
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :brightness               # 明るさ
  attr_reader   :tone                     # 色調
  attr_reader   :flash_color              # フラッシュ色
  attr_reader   :shake                    # シェイク位置
  attr_reader   :pictures                 # ピクチャ
  attr_reader   :weather_type             # 天候 タイプ
  attr_reader   :weather_max              # 天候 画像の最大数
  #
  # オブジェクト初期化
  #
  #
  def initialize
    clear
  end
  #
  # クリア
  #
  #
  def clear
    @brightness = 255
    @fadeout_duration = 0
    @fadein_duration = 0
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @flash_color = Color.new(0, 0, 0, 0)
    @flash_duration = 0
    @shake_power = 0
    @shake_speed = 0
    @shake_duration = 0
    @shake_direction = 1
    @shake = 0
    @pictures = []
    for i in 0..20
      @pictures.push(Game_Picture.new(i))
    end
    @weather_type = 0
    @weather_max = 0.0
    @weather_type_target = 0
    @weather_max_target = 0.0
    @weather_duration = 0
  end
  #
  # フェードアウトの開始
  #
  # duration : 時間
  #
  def start_fadeout(duration)
    @fadeout_duration = duration
    @fadein_duration = 0
  end
  #
  # フェードインの開始
  #
  # duration : 時間
  #
  def start_fadein(duration)
    @fadein_duration = duration
    @fadeout_duration = 0
  end
  #
  # 色調変更の開始
  #
  # tone     : 色調
  # duration : 時間
  #
  def start_tone_change(tone, duration)
    @tone_target = tone.clone
    @tone_duration = duration
    if @tone_duration == 0
      @tone = @tone_target.clone
    end
  end
  #
  # フラッシュの開始
  #
  # color    : 色
  # duration : 時間
  #
  def start_flash(color, duration)
    @flash_color = color.clone
    @flash_duration = duration
  end
  #
  # シェイクの開始
  #
  # power    : 強さ
  # speed    : 速さ
  # duration : 時間
  #
  def start_shake(power, speed, duration)
    @shake_power = power
    @shake_speed = speed
    @shake_duration = duration
  end
  #
  # 天候の設定
  #
  # type     : タイプ
  # power    : 強さ
  # duration : 時間
  #
  def weather(type, power, duration)
    @weather_type_target = type
    if @weather_type_target != 0
      @weather_type = @weather_type_target
    end
    if @weather_type_target == 0
      @weather_max_target = 0.0
    else
      @weather_max_target = (power + 1) * 4.0
    end
    @weather_duration = duration
    if @weather_duration == 0
      @weather_type = @weather_type_target
      @weather_max = @weather_max_target
    end
  end
  #
  # フレーム更新
  #
  #
  def update
    update_fadeout
    update_fadein
    update_tone
    update_flash
    update_shake
    update_weather
    update_pictures
  end
  #
  # フェードアウトの更新
  #
  #
  def update_fadeout
    if @fadeout_duration >= 1
      d = @fadeout_duration
      @brightness = (@brightness * (d - 1)) / d
      @fadeout_duration -= 1
    end
  end
  #
  # フェードインの更新
  #
  #
  def update_fadein
    if @fadein_duration >= 1
      d = @fadein_duration
      @brightness = (@brightness * (d - 1) + 255) / d
      @fadein_duration -= 1
    end
  end
  #
  # 色調の更新
  #
  #
  def update_tone
    if @tone_duration >= 1
      d = @tone_duration
      @tone.red = (@tone.red * (d - 1) + @tone_target.red) / d
      @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
      @tone.blue = (@tone.blue * (d - 1) + @tone_target.blue) / d
      @tone.gray = (@tone.gray * (d - 1) + @tone_target.gray) / d
      @tone_duration -= 1
    end
  end
  #
  # フラッシュの更新
  #
  #
  def update_flash
    if @flash_duration >= 1
      d = @flash_duration
      @flash_color.alpha = @flash_color.alpha * (d - 1) / d
      @flash_duration -= 1
    end
  end
  #
  # シェイクの更新
  #
  #
  def update_shake
    if @shake_duration >= 1 or @shake != 0
      delta = (@shake_power * @shake_speed * @shake_direction) / 10.0
      if @shake_duration <= 1 and @shake * (@shake + delta) < 0
        @shake = 0
      else
        @shake += delta
      end
      if @shake > @shake_power * 2
        @shake_direction = -1
      end
      if @shake < - @shake_power * 2
        @shake_direction = 1
      end
      if @shake_duration >= 1
        @shake_duration -= 1
      end
    end
  end
  #
  # 天候の更新
  #
  #
  def update_weather
    if @weather_duration >= 1
      d = @weather_duration
      @weather_max = (@weather_max * (d - 1) + @weather_max_target) / d
      @weather_duration -= 1
      if @weather_duration == 0
        @weather_type = @weather_type_target
      end
    end
  end
  #
  # ピクチャの更新
  #
  #
  def update_pictures
    for picture in @pictures
      picture.update
    end
  end
end
