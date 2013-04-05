#
# スキル画面の処理を行うクラスです。
#

class Scene_Skill < Scene_Base
  #
  # オブジェクト初期化
  #
  # actor_index : アクターインデックス
  #
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
  end
  #
  # 開始処理
  #
  #
  def start
    super
    create_menu_background
    @actor = $game_party.members[@actor_index]
    @viewport = Viewport.new(0, 0, 544, 416)
    @help_window = Window_Help.new
    @help_window.viewport = @viewport
    @status_window = Window_SkillStatus.new(0, 56, @actor)
    @status_window.viewport = @viewport
    @skill_window = Window_Skill.new(0, 112, 544, 304, @actor)
    @skill_window.viewport = @viewport
    @skill_window.help_window = @help_window
    @target_window = Window_MenuStatus.new(0, 0)
    hide_target_window
  end
  #
  # 終了処理
  #
  #
  def terminate
    super
    dispose_menu_background
    @help_window.dispose
    @status_window.dispose
    @skill_window.dispose
    @target_window.dispose
  end
  #
  # 元の画面へ戻る
  #
  #
  def return_scene
    $scene = Scene_Menu.new(1)
  end
  #
  # 次のアクターの画面に切り替え
  #
  #
  def next_actor
    @actor_index += 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Skill.new(@actor_index)
  end
  #
  # 前のアクターの画面に切り替え
  #
  #
  def prev_actor
    @actor_index += $game_party.members.size - 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Skill.new(@actor_index)
  end
  #
  # フレーム更新
  #
  #
  def update
    super
    update_menu_background
    @help_window.update
    @status_window.update
    @skill_window.update
    @target_window.update
    if @skill_window.active
      update_skill_selection
    elsif @target_window.active
      update_target_selection
    end
  end
  #
  # スキル選択の更新
  #
  #
  def update_skill_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::R)
      Sound.play_cursor
      next_actor
    elsif Input.trigger?(Input::L)
      Sound.play_cursor
      prev_actor
    elsif Input.trigger?(Input::C)
      @skill = @skill_window.skill
      if @skill != nil
        @actor.last_skill_id = @skill.id
      end
      if @actor.skill_can_use?(@skill)
        Sound.play_decision
        determine_skill
      else
        Sound.play_buzzer
      end
    end
  end
  #
  # スキルの決定
  #
  #
  def determine_skill
    if @skill.for_friend?
      show_target_window(@skill_window.index % 2 == 0)
      if @skill.for_all?
        @target_window.index = 99
      elsif @skill.for_user?
        @target_window.index = @actor_index + 100
      else
        if $game_party.last_target_index < @target_window.item_max
          @target_window.index = $game_party.last_target_index
        else
          @target_window.index = 0
        end
      end
    else
      use_skill_nontarget
    end
  end
  #
  # ターゲット選択の更新
  #
  #
  def update_target_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      hide_target_window
    elsif Input.trigger?(Input::C)
      if not @actor.skill_can_use?(@skill)
        Sound.play_buzzer
      else
        determine_target
      end
    end
  end
  #
  # ターゲットの決定
  #
  # 効果なしの場合 (戦闘不能にポーションなど) ブザー SE を演奏。
  #
  def determine_target
    used = false
    if @skill.for_all?
      for target in $game_party.members
        target.skill_effect(@actor, @skill)
        used = true unless target.skipped
      end
    elsif @skill.for_user?
      target = $game_party.members[@target_window.index - 100]
      target.skill_effect(@actor, @skill)
      used = true unless target.skipped
    else
      $game_party.last_target_index = @target_window.index
      target = $game_party.members[@target_window.index]
      target.skill_effect(@actor, @skill)
      used = true unless target.skipped
    end
    if used
      use_skill_nontarget
    else
      Sound.play_buzzer
    end
  end
  #
  # ターゲットウィンドウの表示
  #
  # right : 右寄せフラグ (false なら左寄せ)
  #
  def show_target_window(right)
    @skill_window.active = false
    width_remain = 544 - @target_window.width
    @target_window.x = right ? width_remain : 0
    @target_window.visible = true
    @target_window.active = true
    if right
      @viewport.rect.set(0, 0, width_remain, 416)
      @viewport.ox = 0
    else
      @viewport.rect.set(@target_window.width, 0, width_remain, 416)
      @viewport.ox = @target_window.width
    end
  end
  #
  # ターゲットウィンドウの非表示
  #
  #
  def hide_target_window
    @skill_window.active = true
    @target_window.visible = false
    @target_window.active = false
    @viewport.rect.set(0, 0, 544, 416)
    @viewport.ox = 0
  end
  #
  # スキルの使用 (味方対象以外の使用効果を適用)
  #
  #
  def use_skill_nontarget
    Sound.play_use_skill
    @actor.mp -= @actor.calc_mp_cost(@skill)
    @status_window.refresh
    @skill_window.refresh
    @target_window.refresh
    if $game_party.all_dead?
      $scene = Scene_Gameover.new
    elsif @skill.common_event_id > 0
      $game_temp.common_event_id = @skill.common_event_id
      $scene = Scene_Map.new
    end
  end
end
