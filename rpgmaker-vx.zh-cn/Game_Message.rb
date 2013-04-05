#
# 处理文章和选择项等显示信息窗口状态的类。这个类的实例请参考$game_message
# 这个类的实例请参考$game_message
#

class Game_Message
  #
  # 定量
  #
  #
  MAX_LINE = 4                            # 最大行数
  #
  # 定义实例变量
  #
  #
  attr_accessor :texts                    # 文章的排列 (行单位)
  attr_accessor :face_name                # 头像 文件名
  attr_accessor :face_index               # 头像 索引
  attr_accessor :background               # 背景类型
  attr_accessor :position                 # 表示位置
  attr_accessor :main_proc                # Main 返回调用 (Proc)
  attr_accessor :choice_proc              # 选择项 返回调用 (Proc)
  attr_accessor :choice_start             # 选择项 开始行
  attr_accessor :choice_max               # 选择项 项目数
  attr_accessor :choice_cancel_type       # 选择项 取消的情况
  attr_accessor :num_input_variable_id    # 数值输入 变量 ID
  attr_accessor :num_input_digits_max     # 数值输入 行数
  attr_accessor :visible                  # 信息表示中
  #
  # 初始化对象
  #
  #
  def initialize
    clear
    @visible = false
  end
  #
  # 清除
  #
  #
  def clear
    @texts = []
    @face_name = ""
    @face_index = 0
    @background = 0
    @position = 2
    @main_proc = nil
    @choice_start = 99
    @choice_max = 0
    @choice_cancel_type = 0
    @choice_proc = nil
    @num_input_variable_id = 0
    @num_input_digits_max = 0
  end
  #
  # 繁忙状态判断
  #
  #
  def busy
    return @texts.size > 0
  end
  #
  # 更改页面
  #
  #
  def new_page
    while @texts.size % MAX_LINE > 0
      @texts.push("")
    end
  end
end
