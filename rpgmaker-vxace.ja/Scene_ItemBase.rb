#
# アイテム画面とスキル画面の共通処理を行うクラスです。
#

class Scene_ItemBase < Scene_MenuBase
  #
  # 開始処理
  #
  #
  def start
    super
    create_actor_window
  end
  #
  # アクターウィンドウの作成
  #
  #
  def create_actor_window
    @actor_window = Window_MenuActor.new
    @actor_window.set_handler(:ok,     method(:on_actor_ok))
    @actor_window.set_handler(:cancel, method(:on_actor_cancel))
  end
  #
  # 現在選択されているアイテムの取得
  #
  #
  def item
    @item_window.item
  end
  #
  # アイテムの使用者を取得
  #
  #
  def user
    $game_party.movable_members.max_by {|member| member.pha }
  end
  #
  # カーソルが左列にあるかの判定
  #
  #
  def cursor_left?
    @item_window.index % 2 == 0
  end
  #
  # サブウィンドウの表示
  #
  #
  def show_sub_window(window)
    width_remain = Graphics.width - window.width
    window.x = cursor_left? ? width_remain : 0
    @viewport.rect.x = @viewport.ox = cursor_left? ? 0 : window.width
    @viewport.rect.width = width_remain
    window.show.activate
  end
  #
  # サブウィンドウの非表示
  #
  #
  def hide_sub_window(window)
    @viewport.rect.x = @viewport.ox = 0
    @viewport.rect.width = Graphics.width
    window.hide.deactivate
    activate_item_window
  end
  #
  # アクター［決定］
  #
  #
  def on_actor_ok
    if item_usable?
      use_item
    else
      Sound.play_buzzer
    end
  end
  #
  # アクター［キャンセル］
  #
  #
  def on_actor_cancel
    hide_sub_window(@actor_window)
  end
  #
  # アイテムの決定
  #
  #
  def determine_item
    if item.for_friend?
      show_sub_window(@actor_window)
      @actor_window.select_for_item(item)
    else
      use_item
      activate_item_window
    end
  end
  #
  # アイテムウィンドウのアクティブ化
  #
  #
  def activate_item_window
    @item_window.refresh
    @item_window.activate
  end
  #
  # アイテムの使用対象となるアクターを配列で取得
  #
  #
  def item_target_actors
    if !item.for_friend?
      []
    elsif item.for_all?
      $game_party.members
    else
      [$game_party.members[@actor_window.index]]
    end
  end
  #
  # アイテムの使用可能判定
  #
  #
  def item_usable?
    user.usable?(item) && item_effects_valid?
  end
  #
  # アイテムの効果が有効かを判定
  #
  #
  def item_effects_valid?
    item_target_actors.any? do |target|
      target.item_test(user, item)
    end
  end
  #
  # アイテムをアクターに対して使用
  #
  #
  def use_item_to_actors
    item_target_actors.each do |target|
      item.repeats.times { target.item_apply(user, item) }
    end
  end
  #
  # アイテムの使用
  #
  #
  def use_item
    play_se_for_item
    user.use_item(item)
    use_item_to_actors
    check_common_event
    check_gameover
    @actor_window.refresh
  end
  #
  # コモンイベント予約判定
  #
  # イベントの呼び出しが予約されているならマップ画面へ遷移する。
  #
  def check_common_event
    SceneManager.goto(Scene_Map) if $game_temp.common_event_reserved?
  end
end