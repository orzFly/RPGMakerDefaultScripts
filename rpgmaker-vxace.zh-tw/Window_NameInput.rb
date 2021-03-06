#encoding:utf-8
#
# 名字輸入畫面中，選擇文字的視窗。
#

class Window_NameInput < Window_Selectable
  #
  # 文字表
  #
  #
  TABLE1 = [ 'Ａ','Ｂ','Ｃ','Ｄ','Ｅ',  'ａ','ｂ','ｃ','ｄ','ｅ',
             'Ｆ','Ｇ','Ｈ','Ｉ','Ｊ',  'ｆ','ｇ','ｈ','ｉ','ｊ',
             'Ｋ','Ｌ','Ｍ','Ｎ','Ｏ',  'ｋ','ｌ','ｍ','ｎ','ｏ',
             'Ｐ','Ｑ','Ｒ','Ｓ','Ｔ',  'ｐ','ｑ','ｒ','ｓ','ｔ',
             'Ｕ','Ｖ','Ｗ','Ｘ','Ｙ',  'ｕ','ｖ','ｗ','ｘ','ｙ',
             'Ｚ','〔','〕','','ˍ',  'ｚ','｛','｝','｜','～',
             '０','１','２','３','４',  '！','＃','＄','％','＆',
             '５','６','７','８','９',  '（','）','＊','＋','－',
             '／','＝','＠','＜','＞',  '：','；','　','半角','確定']
  TABLE2 = [ 'A','B','C','D','E',  'a','b','c','d','e',
             'F','G','H','I','J',  'f','g','h','i','j',
             'K','L','M','N','O',  'k','l','m','n','o',
             'P','Q','R','S','T',  'p','q','r','s','t',
             'U','V','W','X','Y',  'u','v','w','x','y',
             'Z','[',']','^','_',  'z','{','}','|','~',
             '0','1','2','3','4',  '!','#','$','%','&',
             '5','6','7','8','9',  '(',')','*','+','-',
             '/','=','@','<','>',  ':',';',' ','其他','確定']
  TABLE3 = [ '','一','二','三','四',  '五','六','七','八','九',
             '十','百','千','萬','億',  '兆','吉','太','拍','艾',
             '賢','者','游','俠','的',  '裡','克','龍','馬','之',
             '娜','塔','麗','瑞','戰',  '泰','倫','斯','愛','絲',
             '阿','奈','思','特','士',  '布','達','諾','亞','金',
             '伊','薩','貝','拉','師',  '斗','魔','法','導','銀',
             '赤','橙','黃','綠','青',  '藍','紫','黑','白','色',
             '騎','斧','劍','弓','槍',  '刀','銃','爪','錘','杖',
             '聖','暗','炎','水','風',  '地','電','冰','全角','確定']
  #
  # 初始化物件
  #
  #
  def initialize(edit_window)
    super(edit_window.x, edit_window.y + edit_window.height + 8,
          edit_window.width, fitting_height(9))
    @edit_window = edit_window
    @page = 0
    @index = 0
    refresh
    update_cursor
    activate
  end
  #
  # 取得字表
  #
  #
  def table
    return [TABLE1, TABLE2, TABLE3]
  end
  #
  # 取得文字
  #
  #
  def character
    @index < 88 ? table[@page][@index] : ""
  end
  #
  # 判定游標位置是否在“切換”上（平假／片假）
  #
  #
  def is_page_change?
    @index == 88
  end
  #
  # 判定游標位置是否在“確定”上
  #
  #
  def is_ok?
    @index == 89
  end
  #
  # 取得專案的繪制矩形
  #
  #
  def item_rect(index)
    rect = Rect.new
    rect.x = index % 10 * 32 + index % 10 / 5 * 16
    rect.y = index / 10 * line_height
    rect.width = 32
    rect.height = line_height
    rect
  end
  #
  # 重新整理
  #
  #
  def refresh
    contents.clear
    change_color(normal_color)
    90.times {|i| draw_text(item_rect(i), table[@page][i], 1) }
  end
  #
  # 更新游標
  #
  #
  def update_cursor
    cursor_rect.set(item_rect(@index))
  end
  #
  # 判定游標是否可以搬移
  #
  #
  def cursor_movable?
    active
  end
  #
  # 游標向下搬移
  #
  # wrap : 容許循環
  #
  def cursor_down(wrap)
    if @index < 80 or wrap
      @index = (index + 10) % 90
    end
  end
  #
  # 游標向上搬移
  #
  # wrap : 容許循環
  #
  def cursor_up(wrap)
    if @index >= 10 or wrap
      @index = (index + 80) % 90
    end
  end
  #
  # 游標向右搬移
  #
  # wrap : 容許循環
  #
  def cursor_right(wrap)
    if @index % 10 < 9
      @index += 1
    elsif wrap
      @index -= 9
    end
  end
  #
  # 游標向左搬移
  #
  # wrap : 容許循環
  #
  def cursor_left(wrap)
    if @index % 10 > 0
      @index -= 1
    elsif wrap
      @index += 9
    end
  end
  #
  # 向下一頁搬移
  #
  #
  def cursor_pagedown
    @page = (@page + 1) % table.size
    refresh
  end
  #
  # 向上一頁搬移
  #
  #
  def cursor_pageup
    @page = (@page + table.size - 1) % table.size
    refresh
  end
  #
  # 處理游標的搬移
  #
  #
  def process_cursor_move
    last_page = @page
    super
    update_cursor
    Sound.play_cursor if @page != last_page
  end
  #
  # “確定”、“刪除字元”和“取消輸入”的處理
  #
  #
  def process_handling
    return unless open? && active
    process_jump if Input.trigger?(:A)
    process_back if Input.repeat?(:B)
    process_ok   if Input.trigger?(:C)
  end
  #
  # 跳轉“確定”
  #
  #
  def process_jump
    if @index != 89
      @index = 89
      Sound.play_cursor
    end
  end
  #
  # 後退一個字元
  #
  #
  def process_back
    Sound.play_cancel if @edit_window.back
  end
  #
  # 按下確定鍵時的處理
  #
  #
  def process_ok
    if !character.empty?
      on_name_add
    elsif is_page_change?
      Sound.play_ok
      cursor_pagedown
    elsif is_ok?
      on_name_ok
    end
  end
  #
  # 加入名字字元
  #
  #
  def on_name_add
    if @edit_window.add(character)
      Sound.play_ok
    else
      Sound.play_buzzer
    end
  end
  #
  # 確定名字
  #
  #
  def on_name_ok
    if @edit_window.name.empty?
      if @edit_window.restore_default
        Sound.play_ok
      else
        Sound.play_buzzer
      end
    else
      Sound.play_ok
      call_ok_handler
    end
  end
end
