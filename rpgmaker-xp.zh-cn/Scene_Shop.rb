#
# 处理商店画面的类。
#

class Scene_Shop
  #
  # 主处理
  #
  #
  def main
    # 生成帮助窗口
    @help_window = Window_Help.new
    # 生成指令窗口
    @command_window = Window_ShopCommand.new
    # 生成金钱窗口
    @gold_window = Window_Gold.new
    @gold_window.x = 480
    @gold_window.y = 64
    # 生成时间窗口
    @dummy_window = Window_Base.new(0, 128, 640, 352)
    # 生成购买窗口
    @buy_window = Window_ShopBuy.new($game_temp.shop_goods)
    @buy_window.active = false
    @buy_window.visible = false
    @buy_window.help_window = @help_window
    # 生成卖出窗口
    @sell_window = Window_ShopSell.new
    @sell_window.active = false
    @sell_window.visible = false
    @sell_window.help_window = @help_window
    # 生成数量输入窗口
    @number_window = Window_ShopNumber.new
    @number_window.active = false
    @number_window.visible = false
    # 生成状态窗口
    @status_window = Window_ShopStatus.new
    @status_window.visible = false
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @help_window.dispose
    @command_window.dispose
    @gold_window.dispose
    @dummy_window.dispose
    @buy_window.dispose
    @sell_window.dispose
    @number_window.dispose
    @status_window.dispose
  end
  #
  # 刷新画面
  #
  #
  def update
    # 刷新窗口
    @help_window.update
    @command_window.update
    @gold_window.update
    @dummy_window.update
    @buy_window.update
    @sell_window.update
    @number_window.update
    @status_window.update
    # 指令窗口激活的情况下: 调用 update_command
    if @command_window.active
      update_command
      return
    end
    # 购买窗口激活的情况下: 调用 update_buy
    if @buy_window.active
      update_buy
      return
    end
    # 卖出窗口激活的情况下: 调用 update_sell
    if @sell_window.active
      update_sell
      return
    end
    # 个数输入窗口激活的情况下: 调用 update_number
    if @number_window.active
      update_number
      return
    end
  end
  #
  # 刷新画面 (指令窗口激活的情况下)
  #
  #
  def update_command
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到地图画面
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 命令窗口光标位置分支
      case @command_window.index
      when 0  # 购买
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 窗口状态转向购买模式
        @command_window.active = false
        @dummy_window.visible = false
        @buy_window.active = true
        @buy_window.visible = true
        @buy_window.refresh
        @status_window.visible = true
      when 1  # 卖出
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 窗口状态转向卖出模式
        @command_window.active = false
        @dummy_window.visible = false
        @sell_window.active = true
        @sell_window.visible = true
        @sell_window.refresh
      when 2  # 取消
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 切换到地图画面
        $scene = Scene_Map.new
      end
      return
    end
  end
  #
  # 刷新画面 (购买窗口激活的情况下)
  #
  #
  def update_buy
    # 设置状态窗口的物品
    @status_window.item = @buy_window.item
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 窗口状态转向初期模式
      @command_window.active = true
      @dummy_window.visible = true
      @buy_window.active = false
      @buy_window.visible = false
      @status_window.visible = false
      @status_window.item = nil
      # 删除帮助文本
      @help_window.set_text("")
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 获取物品
      @item = @buy_window.item
      # 物品无效的情况下、或者价格在所持金以上的情况下
      if @item == nil or @item.price > $game_party.gold
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 获取物品所持数
      case @item
      when RPG::Item
        number = $game_party.item_number(@item.id)
      when RPG::Weapon
        number = $game_party.weapon_number(@item.id)
      when RPG::Armor
        number = $game_party.armor_number(@item.id)
      end
      # 如果已经拥有了 99 个情况下
      if number == 99
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 计算可以最多购买的数量
      max = @item.price == 0 ? 99 : $game_party.gold / @item.price
      max = [max, 99 - number].min
      # 窗口状态转向数值输入模式
      @buy_window.active = false
      @buy_window.visible = false
      @number_window.set(@item, max, @item.price)
      @number_window.active = true
      @number_window.visible = true
    end
  end
  #
  # 画面更新 (卖出窗口激活的情况下)
  #
  #
  def update_sell
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 窗口状态转向初期模式
      @command_window.active = true
      @dummy_window.visible = true
      @sell_window.active = false
      @sell_window.visible = false
      @status_window.item = nil
      # 删除帮助文本
      @help_window.set_text("")
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 获取物品
      @item = @sell_window.item
      # 设置状态窗口的物品
      @status_window.item = @item
      # 物品无效的情况下、或者价格为 0 (不能卖出) 的情况下
      if @item == nil or @item.price == 0
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 获取物品的所持数
      case @item
      when RPG::Item
        number = $game_party.item_number(@item.id)
      when RPG::Weapon
        number = $game_party.weapon_number(@item.id)
      when RPG::Armor
        number = $game_party.armor_number(@item.id)
      end
      # 最大卖出个数 = 物品的所持数
      max = number
      # 窗口状态转向个数输入模式
      @sell_window.active = false
      @sell_window.visible = false
      @number_window.set(@item, max, @item.price / 2)
      @number_window.active = true
      @number_window.visible = true
      @status_window.visible = true
    end
  end
  #
  # 刷新画面 (个数输入窗口激活的情况下)
  #
  #
  def update_number
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 设置个数输入窗口为不活动·非可视状态
      @number_window.active = false
      @number_window.visible = false
      # 命令窗口光标位置分支
      case @command_window.index
      when 0  # 购买
        # 窗口状态转向购买模式
        @buy_window.active = true
        @buy_window.visible = true
      when 1  # 卖出
        # 窗口状态转向卖出模式
        @sell_window.active = true
        @sell_window.visible = true
        @status_window.visible = false
      end
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 演奏商店 SE
      $game_system.se_play($data_system.shop_se)
      # 设置个数输入窗口为不活动·非可视状态
      @number_window.active = false
      @number_window.visible = false
      # 命令窗口光标位置分支
      case @command_window.index
      when 0  # 购买
        # 购买处理
        $game_party.lose_gold(@number_window.number * @item.price)
        case @item
        when RPG::Item
          $game_party.gain_item(@item.id, @number_window.number)
        when RPG::Weapon
          $game_party.gain_weapon(@item.id, @number_window.number)
        when RPG::Armor
          $game_party.gain_armor(@item.id, @number_window.number)
        end
        # 刷新各窗口
        @gold_window.refresh
        @buy_window.refresh
        @status_window.refresh
        # 窗口状态转向购买模式
        @buy_window.active = true
        @buy_window.visible = true
      when 1  # 卖出
        # 卖出处理
        $game_party.gain_gold(@number_window.number * (@item.price / 2))
        case @item
        when RPG::Item
          $game_party.lose_item(@item.id, @number_window.number)
        when RPG::Weapon
          $game_party.lose_weapon(@item.id, @number_window.number)
        when RPG::Armor
          $game_party.lose_armor(@item.id, @number_window.number)
        end
        # 刷新各窗口
        @gold_window.refresh
        @sell_window.refresh
        @status_window.refresh
        # 窗口状态转向卖出模式
        @sell_window.active = true
        @sell_window.visible = true
        @status_window.visible = false
      end
      return
    end
  end
end
