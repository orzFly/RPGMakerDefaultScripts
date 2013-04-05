#
# 处理存档画面的类。
#

class Scene_Save < Scene_File
  #
  # 初始化对像
  #
  #
  def initialize
    super("要保存到这个文件吗？")
  end
  #
  # 确定时的处理
  #
  #
  def on_decision(filename)
    # 演奏存档 SE
    $game_system.se_play($data_system.save_se)
    # 写入存档数据
    file = File.open(filename, "wb")
    write_save_data(file)
    file.close
    # 如果被事件调用
    if $game_temp.save_calling
      # 清除存档调用标志
      $game_temp.save_calling = false
      # 切换到地图画面
      $scene = Scene_Map.new
      return
    end
    # 切换到菜单画面
    $scene = Scene_Menu.new(4)
  end
  #
  # 取消时的处理
  #
  #
  def on_cancel
    # 演奏取消 SE
    $game_system.se_play($data_system.cancel_se)
    # 如果被事件调用
    if $game_temp.save_calling
      # 清除存档调用标志
      $game_temp.save_calling = false
      # 切换到地图画面
      $scene = Scene_Map.new
      return
    end
    # 切换到菜单画面
    $scene = Scene_Menu.new(4)
  end
  #
  # 写入存档数据
  #
  # file : 写入用文件对像 (已经打开)
  #
  def write_save_data(file)
    # 生成描绘存档文件用的角色图形
    characters = []
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      characters.push([actor.character_name, actor.character_hue])
    end
    # 写入描绘存档文件用的角色数据
    Marshal.dump(characters, file)
    # 写入测量游戏时间用画面计数
    Marshal.dump(Graphics.frame_count, file)
    # 增加 1 次存档次数
    $game_system.save_count += 1
    # 保存魔法编号
    # (将编辑器保存的值以随机值替换)
    $game_system.magic_number = $data_system.magic_number
    # 写入各种游戏对像
    Marshal.dump($game_system, file)
    Marshal.dump($game_switches, file)
    Marshal.dump($game_variables, file)
    Marshal.dump($game_self_switches, file)
    Marshal.dump($game_screen, file)
    Marshal.dump($game_actors, file)
    Marshal.dump($game_party, file)
    Marshal.dump($game_troop, file)
    Marshal.dump($game_map, file)
    Marshal.dump($game_player, file)
  end
end
