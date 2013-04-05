#
# 更改色调以及画面闪烁、保存画面全体关系处理数据的类。
# 这个类是Game_Map类、Game_Troop类的内部所使用的。
#

class Game_Screen
  #
  # 定义实例变量
  #
  #
  attr_reader   :brightness               # 模糊
  attr_reader   :tone                     # 色调
  attr_reader   :flash_color              # 闪烁色
  attr_reader   :shake                    # 震动未知
  attr_reader   :pictures                 # 图片
  attr_reader   :weather_type             # 天气 类型
  attr_reader   :weather_max              # 天气 图像的最大数
  #
  # 初始化对象
  #
  #
  def initialize
    clear
  end
  #
  # 清除
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
  # 开始淡出
  #
  # duration : 时间
  #
  def start_fadeout(duration)
    @fadeout_duration = duration
    @fadein_duration = 0
  end
  #
  # 开始淡入
  #
  # duration : 时间
  #
  def start_fadein(duration)
    @fadein_duration = duration
    @fadeout_duration = 0
  end
  #
  # 开始更改色调
  #
  # tone     : 色调
  # duration : 时间
  #
  def start_tone_change(tone, duration)
    @tone_target = tone.clone
    @tone_duration = duration
    if @tone_duration == 0
      @tone = @tone_target.clone
    end
  end
  #
  # 开始画面闪烁
  #
  # color    : 色
  # duration : 时间
  #
  def start_flash(color, duration)
    @flash_color = color.clone
    @flash_duration = duration
  end
  #
  # 开始震动
  #
  # power    : 强度
  # speed    : 速度
  # duration : 时间
  #
  def start_shake(power, speed, duration)
    @shake_power = power
    @shake_speed = speed
    @shake_duration = duration
  end
  #
  # 设定天气
  #
  # type     : 类型
  # power    : 强度
  # duration : 时间
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
  # 刷新画面
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
  # 刷新淡出
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
  # 刷新淡入
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
  # 刷新色调
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
  # 刷新闪烁
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
  # 刷新震动
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
  # 刷新天气
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
  # 刷新图片
  #
  #
  def update_pictures
    for picture in @pictures
      picture.update
    end
  end
end
