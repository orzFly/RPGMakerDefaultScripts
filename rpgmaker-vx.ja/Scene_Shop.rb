#
# ショップ画面の処理を行うクラスです。
#

class Scene_Shop < Scene_Base
  #
  # 開始処理
  #
  #
  def start
    super
    create_menu_background
    create_command_window
    @help_window = Window_Help.new
    @gold_window = Window_Gold.new(384, 56)
    @dummy_window = Window_Base.new(0, 112, 544, 304)
    @buy_window = Window_ShopBuy.new(0, 112)
    @buy_window.active = false
    @buy_window.visible = false
    @buy_window.help_window = @help_window
    @sell_window = Window_ShopSell.new(0, 112, 544, 304)
    @sell_window.active = false
    @sell_window.visible = false
    @sell_window.help_window = @help_window
    @number_window = Window_ShopNumber.new(0, 112)
    @number_window.active = false
    @number_window.visible = false
    @status_window = Window_ShopStatus.new(304, 112)
    @status_window.visible = false
  end
  #
  # 終了処理
  #
  #
  def terminate
    super
    dispose_menu_background
    dispose_command_window
    @help_window.dispose
    @gold_window.dispose
    @dummy_window.dispose
    @buy_window.dispose
    @sell_window.dispose
    @number_window.dispose
    @status_window.dispose
  end
  #
  # フレーム更新
  #
  #
  def update
    super
    update_menu_background
    @help_window.update
    @command_window.update
    @gold_window.update
    @dummy_window.update
    @buy_window.update
    @sell_window.update
    @number_window.update
    @status_window.update
    if @command_window.active
      update_command_selection
    elsif @buy_window.active
      update_buy_selection
    elsif @sell_window.active
      update_sell_selection
    elsif @number_window.active
      update_number_input
    end
  end
  #
  # コマンドウィンドウの作成
  #
  #
  def create_command_window
    s1 = Vocab::ShopBuy
    s2 = Vocab::ShopSell
    s3 = Vocab::ShopCancel
    @command_window = Window_Command.new(384, [s1, s2, s3], 3)
    @command_window.y = 56
    if $game_temp.shop_purchase_only
      @command_window.draw_item(1, false)
    end
  end
  #
  # コマンドウィンドウの解放
  #
  #
  def dispose_command_window
    @command_window.dispose
  end
  #
  # コマンド選択の更新
  #
  #
  def update_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::C)
      case @command_window.index
      when 0  # 購入する
        Sound.play_decision
        @command_window.active = false
        @dummy_window.visible = false
        @buy_window.active = true
        @buy_window.visible = true
        @buy_window.refresh
        @status_window.visible = true
      when 1  # 売却する
        if $game_temp.shop_purchase_only
          Sound.play_buzzer
        else
          Sound.play_decision
          @command_window.active = false
          @dummy_window.visible = false
          @sell_window.active = true
          @sell_window.visible = true
          @sell_window.refresh
        end
      when 2  # やめる
        Sound.play_decision
        $scene = Scene_Map.new
      end
    end
  end
  #
  # 購入アイテム選択の更新
  #
  #
  def update_buy_selection
    @status_window.item = @buy_window.item
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.active = true
      @dummy_window.visible = true
      @buy_window.active = false
      @buy_window.visible = false
      @status_window.visible = false
      @status_window.item = nil
      @help_window.set_text("")
      return
    end
    if Input.trigger?(Input::C)
      @item = @buy_window.item
      number = $game_party.item_number(@item)
      if @item == nil or @item.price > $game_party.gold or number == 99
        Sound.play_buzzer
      else
        Sound.play_decision
        max = @item.price == 0 ? 99 : $game_party.gold / @item.price
        max = [max, 99 - number].min
        @buy_window.active = false
        @buy_window.visible = false
        @number_window.set(@item, max, @item.price)
        @number_window.active = true
        @number_window.visible = true
      end
    end
  end
  #
  # 売却アイテム選択の更新
  #
  #
  def update_sell_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.active = true
      @dummy_window.visible = true
      @sell_window.active = false
      @sell_window.visible = false
      @status_window.item = nil
      @help_window.set_text("")
    elsif Input.trigger?(Input::C)
      @item = @sell_window.item
      @status_window.item = @item
      if @item == nil or @item.price == 0
        Sound.play_buzzer
      else
        Sound.play_decision
        max = $game_party.item_number(@item)
        @sell_window.active = false
        @sell_window.visible = false
        @number_window.set(@item, max, @item.price / 2)
        @number_window.active = true
        @number_window.visible = true
        @status_window.visible = true
      end
    end
  end
  #
  # 個数入力の更新
  #
  #
  def update_number_input
    if Input.trigger?(Input::B)
      cancel_number_input
    elsif Input.trigger?(Input::C)
      decide_number_input
    end
  end
  #
  # 個数入力のキャンセル
  #
  #
  def cancel_number_input
    Sound.play_cancel
    @number_window.active = false
    @number_window.visible = false
    case @command_window.index
    when 0  # 購入する
      @buy_window.active = true
      @buy_window.visible = true
    when 1  # 売却する
      @sell_window.active = true
      @sell_window.visible = true
      @status_window.visible = false
    end
  end
  #
  # 個数入力の決定
  #
  #
  def decide_number_input
    Sound.play_shop
    @number_window.active = false
    @number_window.visible = false
    case @command_window.index
    when 0  # 購入する
      $game_party.lose_gold(@number_window.number * @item.price)
      $game_party.gain_item(@item, @number_window.number)
      @gold_window.refresh
      @buy_window.refresh
      @status_window.refresh
      @buy_window.active = true
      @buy_window.visible = true
    when 1  # 売却する
      $game_party.gain_gold(@number_window.number * (@item.price / 2))
      $game_party.lose_item(@item, @number_window.number)
      @gold_window.refresh
      @sell_window.refresh
      @status_window.refresh
      @sell_window.active = true
      @sell_window.visible = true
      @status_window.visible = false
    end
  end
end
