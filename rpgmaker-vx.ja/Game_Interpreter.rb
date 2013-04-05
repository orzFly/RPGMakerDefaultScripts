#
# イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#

class Game_Interpreter
  #
  # オブジェクト初期化
  #
  # depth : ネストの深さ
  # main  : メインフラグ
  #
  def initialize(depth = 0, main = false)
    @depth = depth
    @main = main
    if @depth > 100
      print("コモンイベントの呼び出しが上限を超えました。")
      exit
    end
    clear
  end
  #
  # クリア
  #
  #
  def clear
    @map_id = 0                       # 起動時のマップ ID
    @original_event_id = 0            # 起動時のイベント ID
    @event_id = 0                     # イベント ID
    @list = nil                       # 実行内容
    @index = 0                        # インデックス
    @message_waiting = false          # メッセージ終了待機中
    @moving_character = nil           # 移動中のキャラクター
    @wait_count = 0                   # ウェイトカウント
    @child_interpreter = nil          # 子インタプリタ
    @branch = {}                      # 分岐データ
  end
  #
  # イベントのセットアップ
  #
  # list     : 実行内容
  # event_id : イベント ID
  #
  def setup(list, event_id = 0)
    clear                             # インタプリタの内部状態をクリア
    @map_id = $game_map.map_id        # マップ ID を記憶
    @original_event_id = event_id     # イベント ID を記憶
    @event_id = event_id              # イベント ID を記憶
    @list = list                      # 実行内容を記憶
    @index = 0                        # インデックスを初期化
    cancel_menu_call                  # メニュー呼び出しの取り消し
  end
  #
  # メニュー呼び出しの取り消し
  #
  # プレイヤーの移動中にキャンセルボタンが押され、メニュー画面の呼び出し
  # が予約された状態でイベントが起動した場合の対策を行う。
  #
  def cancel_menu_call
    if @main and $game_temp.next_scene == "menu" and $game_temp.menu_beep
      $game_temp.next_scene = nil
      $game_temp.menu_beep = false
    end
  end
  #
  # 実行中判定
  #
  #
  def running?
    return @list != nil
  end
  #
  # 起動中イベントのセットアップ
  #
  #
  def setup_starting_event
    if $game_map.need_refresh             # 必要ならマップをリフレッシュ
      $game_map.refresh
    end
    if $game_temp.common_event_id > 0     # コモンイベントの呼び出し予約？
      setup($data_common_events[$game_temp.common_event_id].list)
      $game_temp.common_event_id = 0
      return
    end
    for event in $game_map.events.values  # マップイベント
      if event.starting                   # 起動中のイベントが見つかった場合
        event.clear_starting              # 起動中フラグをクリア
        setup(event.list, event.id)       # イベントをセットアップ
        return
      end
    end
    for event in $data_common_events.compact      # コモンイベント
      if event.trigger == 1 and           # トリガーが自動実行かつ
         $game_switches[event.switch_id] == true  # 条件スイッチが ON の場合
        setup(event.list)                 # イベントをセットアップ
        return
      end
    end
  end
  #
  # フレーム更新
  #
  #
  def update
    loop do
      if $game_map.map_id != @map_id        # マップがイベント起動時と異なる
        @event_id = 0                       # イベント ID を 0 にする
      end
      if @child_interpreter != nil          # 子インタプリタが存在する場合
        @child_interpreter.update           # 子インタプリタを更新
        if @child_interpreter.running?      # 実行中の場合
          return                            # 戻る
        else                                # 実行が終わった場合
          @child_interpreter = nil          # 子インタプリタを消去
        end
      end
      if @message_waiting                   # メッセージ終了待機中
        return
      end
      if @moving_character != nil           # 移動完了待機中
        if @moving_character.move_route_forcing
          return
        end
        @moving_character = nil
      end
      if @wait_count > 0                    # ウェイト中
        @wait_count -= 1
        return
      end
      if $game_troop.forcing_battler != nil # 戦闘行動の強制中
        return
      end
      if $game_temp.next_scene != nil       # 各種画面を開く途中
        return
      end
      if @list == nil                       # 実行内容リストが空の場合
        setup_starting_event if @main       # 起動中のイベントをセットアップ
        return if @list == nil              # 何もセットアップされなかった
      end
      return if execute_command == false    # イベントコマンドの実行
      @index += 1                           # インデックスを進める
    end
  end
  #
  # アクター用イテレータ (ID)
  #
  # param : 1 以上なら ID、0 なら全体
  #
  def iterate_actor_id(param)
    if param == 0       # 全体
      for actor in $game_party.members do yield actor end
    else                # 単体
      actor = $game_actors[param]
      yield actor unless actor == nil
    end
  end
  #
  # アクター用イテレータ (インデックス)
  #
  # param : 0 以上ならインデックス、-1 なら全体
  #
  def iterate_actor_index(param)
    if param == -1      # 全体
      for actor in $game_party.members do yield actor end
    else                # 単体
      actor = $game_party.members[param]
      yield actor unless actor == nil
    end
  end
  #
  # 敵キャラ用イテレータ (インデックス)
  #
  # param : 0 以上ならインデックス、-1 なら全体
  #
  def iterate_enemy_index(param)
    if param == -1      # 全体
      for enemy in $game_troop.members do yield enemy end
    else                # 単体
      enemy = $game_troop.members[param]
      yield enemy unless enemy == nil
    end
  end
  #
  # バトラー用イテレータ (敵グループ全体、パーティ全体を考慮)
  #
  # param1 : 0 なら敵キャラ、1 ならアクター
  # param2 : 0 以上ならインデックス、-1 なら全体
  #
  def iterate_battler(param1, param2)
    if $game_temp.in_battle
      if param1 == 0      # 敵キャラ
        iterate_enemy_index(param2) do |enemy| yield enemy end
      else                # アクター
        iterate_actor_index(param2) do |enemy| yield enemy end
      end
    end
  end
  #
  # 画面系コマンドの対象取得
  #
  #
  def screen
    if $game_temp.in_battle
      return $game_troop.screen
    else
      return $game_map.screen
    end
  end
  #
  # イベントコマンドの実行
  #
  #
  def execute_command
    if @index >= @list.size-1
      command_end
      return true
    else
      @params = @list[@index].parameters
      @indent = @list[@index].indent
      case @list[@index].code
      when 101  # 文章の表示
        return command_101
      when 102  # 選択肢の表示
        return command_102
      when 402  # [**] の場合
        return command_402
      when 403  # キャンセルの場合
        return command_403
      when 103  # 数値入力の処理
        return command_103
      when 111  # 条件分岐
        return command_111
      when 411  # それ以外の場合
        return command_411
      when 112  # ループ
        return command_112
      when 413  # 以上繰り返し
        return command_413
      when 113  # ループの中断
        return command_113
      when 115  # イベント処理の中断
        return command_115
      when 117  # コモンイベント
        return command_117
      when 118  # ラベル
        return command_118
      when 119  # ラベルジャンプ
        return command_119
      when 121  # スイッチの操作
        return command_121
      when 122  # 変数の操作
        return command_122
      when 123  # セルフスイッチの操作
        return command_123
      when 124  # タイマーの操作
        return command_124
      when 125  # 所持金の増減
        return command_125
      when 126  # アイテムの増減
        return command_126
      when 127  # 武器の増減
        return command_127
      when 128  # 防具の増減
        return command_128
      when 129  # メンバーの入れ替え
        return command_129
      when 132  # バトル BGM の変更
        return command_132
      when 133  # バトル終了 ME の変更
        return command_133
      when 134  # セーブ禁止の変更
        return command_134
      when 135  # メニュー禁止の変更
        return command_135
      when 136  # エンカウント禁止の変更
        return command_136
      when 201  # 場所移動
        return command_201
      when 202  # 乗り物の位置設定
        return command_202
      when 203  # イベントの位置設定
        return command_203
      when 204  # マップのスクロール
        return command_204
      when 205  # 移動ルートの設定
        return command_205
      when 206  # 乗り物の乗降
        return command_206
      when 211  # 透明状態の変更
        return command_211
      when 212  # アニメーションの表示
        return command_212
      when 213  # フキダシアイコンの表示
        return command_213
      when 214  # イベントの一時消去
        return command_214
      when 221  # 画面のフェードアウト
        return command_221
      when 222  # 画面のフェードイン
        return command_222
      when 223  # 画面の色調変更
        return command_223
      when 224  # 画面のフラッシュ
        return command_224
      when 225  # 画面のシェイク
        return command_225
      when 230  # ウェイト
        return command_230
      when 231  # ピクチャの表示
        return command_231
      when 232  # ピクチャの移動
        return command_232
      when 233  # ピクチャの回転
        return command_233
      when 234  # ピクチャの色調変更
        return command_234
      when 235  # ピクチャの消去
        return command_235
      when 236  # 天候の設定
        return command_236
      when 241  # BGM の演奏
        return command_241
      when 242  # BGM のフェードアウト
        return command_242
      when 245  # BGS の演奏
        return command_245
      when 246  # BGS のフェードアウト
        return command_246
      when 249  # ME の演奏
        return command_249
      when 250  # SE の演奏
        return command_250
      when 251  # SE の停止
        return command_251
      when 301  # バトルの処理
        return command_301
      when 601  # 勝った場合
        return command_601
      when 602  # 逃げた場合
        return command_602
      when 603  # 負けた場合
        return command_603
      when 302  # ショップの処理
        return command_302
      when 303  # 名前入力の処理
        return command_303
      when 311  # HP の増減
        return command_311
      when 312  # MP の増減
        return command_312
      when 313  # ステートの変更
        return command_313
      when 314  # 全回復
        return command_314
      when 315  # 経験値の増減
        return command_315
      when 316  # レベルの増減
        return command_316
      when 317  # 能力値の増減
        return command_317
      when 318  # スキルの増減
        return command_318
      when 319  # 装備の変更
        return command_319
      when 320  # 名前の変更
        return command_320
      when 321  # 職業の変更
        return command_321
      when 322  # アクターのグラフィック変更
        return command_322
      when 323  # 乗り物のグラフィック変更
        return command_323
      when 331  # 敵キャラの HP 増減
        return command_331
      when 332  # 敵キャラの MP 増減
        return command_332
      when 333  # 敵キャラのステート変更
        return command_333
      when 334  # 敵キャラの全回復
        return command_334
      when 335  # 敵キャラの出現
        return command_335
      when 336  # 敵キャラの変身
        return command_336
      when 337  # 戦闘アニメーションの表示
        return command_337
      when 339  # 戦闘行動の強制
        return command_339
      when 340  # バトルの中断
        return command_340
      when 351  # メニュー画面を開く
        return command_351
      when 352  # セーブ画面を開く
        return command_352
      when 353  # ゲームオーバー
        return command_353
      when 354  # タイトル画面に戻す
        return command_354
      when 355  # スクリプト
        return command_355
      else      # その他
        return true
      end
    end
  end
  #
  # イベントの終了
  #
  #
  def command_end
    @list = nil                             # 実行内容リストをクリア
    if @main and @event_id > 0              # メインのマップイベントの場合
      $game_map.events[@event_id].unlock    # イベントのロックを解除
    end
  end
  #
  # コマンドスキップ
  #
  #
  def command_skip
    while @list[@index+1].indent > @indent  # 次のインデントが基準より深い間
      @index += 1                           # インデックスを進める
    end
  end
  #
  # キャラクターの取得
  #
  # param : -1 ならプレイヤー、0 ならこのイベント、それ以外はイベント ID
  #
  def get_character(param)
    case param
    when -1   # プレイヤー
      return $game_player
    when 0    # このイベント
      events = $game_map.events
      return events == nil ? nil : events[@event_id]
    else      # 特定のイベント
      events = $game_map.events
      return events == nil ? nil : events[param]
    end
  end
  #
  # 操作する値の計算
  #
  # operation    : 操作 (0:増やす 1:減らす)
  # operand_type : オペランドタイプ (0:定数 1:変数)
  # operand      : オペランド (数値または変数 ID)
  #
  def operate_value(operation, operand_type, operand)
    if operand_type == 0
      value = operand
    else
      value = $game_variables[operand]
    end
    if operation == 1
      value = -value
    end
    return value
  end
  #
  # 文章の表示
  #
  #
  def command_101
    unless $game_message.busy
      $game_message.face_name = @params[0]
      $game_message.face_index = @params[1]
      $game_message.background = @params[2]
      $game_message.position = @params[3]
      @index += 1
      while @list[@index].code == 401       # 文章データ
        $game_message.texts.push(@list[@index].parameters[0])
        @index += 1
      end
      if @list[@index].code == 102          # 選択肢の表示
        setup_choices(@list[@index].parameters)
      elsif @list[@index].code == 103       # 数値入力の処理
        setup_num_input(@list[@index].parameters)
      end
      set_message_waiting                   # メッセージ待機状態にする
    end
    return false
  end
  #
  # メッセージ待機中フラグおよびコールバックの設定
  #
  #
  def set_message_waiting
    @message_waiting = true
    $game_message.main_proc = Proc.new { @message_waiting = false }
  end
  #
  # 選択肢の表示
  #
  #
  def command_102
    unless $game_message.busy
      setup_choices(@params)                # セットアップ
      set_message_waiting                   # メッセージ待機状態にする
    end
    return false
  end
  #
  # 選択肢のセットアップ
  #
  #
  def setup_choices(params)
    if $game_message.texts.size <= 4 - params[0].size
      $game_message.choice_start = $game_message.texts.size
      $game_message.choice_max = params[0].size
      for s in params[0]
        $game_message.texts.push(s)
      end
      $game_message.choice_cancel_type = params[1]
      $game_message.choice_proc = Proc.new { |n| @branch[@indent] = n }
      @index += 1
    end
  end
  #
  # [**] の場合
  #
  #
  def command_402
    if @branch[@indent] == @params[0]       # 該当する選択肢の場合
      @branch.delete(@indent)               # 分岐データを削除
      return true                           # 継続
    else                                    # 条件に該当しない場合
      return command_skip                   # コマンドスキップ
    end
  end
  #
  # キャンセルの場合
  #
  #
  def command_403
    if @branch[@indent] == 4                # 選択肢キャンセルの場合
      @branch.delete(@indent)               # 分岐データを削除
      return true                           # 継続
    else                                    # 条件に該当しない場合
      return command_skip                   # コマンドスキップ
    end
  end
  #
  # 数値入力の処理
  #
  #
  def command_103
    unless $game_message.busy
      setup_num_input(@params)              # セットアップ
      set_message_waiting                   # メッセージ待機状態にする
    end
    return false
  end
  #
  # 数値入力のセットアップ
  #
  #
  def setup_num_input(params)
    if $game_message.texts.size < 4
      $game_message.num_input_variable_id = params[0]
      $game_message.num_input_digits_max = params[1]
      @index += 1
    end
  end
  #
  # 条件分岐
  #
  #
  def command_111
    result = false
    case @params[0]
    when 0  # スイッチ
      result = ($game_switches[@params[1]] == (@params[2] == 0))
    when 1  # 変数
      value1 = $game_variables[@params[1]]
      if @params[2] == 0
        value2 = @params[3]
      else
        value2 = $game_variables[@params[3]]
      end
      case @params[4]
      when 0  # と同値
        result = (value1 == value2)
      when 1  # 以上
        result = (value1 >= value2)
      when 2  # 以下
        result = (value1 <= value2)
      when 3  # 超
        result = (value1 > value2)
      when 4  # 未満
        result = (value1 < value2)
      when 5  # 以外
        result = (value1 != value2)
      end
    when 2  # セルフスイッチ
      if @original_event_id > 0
        key = [@map_id, @original_event_id, @params[1]]
        if @params[2] == 0
          result = ($game_self_switches[key] == true)
        else
          result = ($game_self_switches[key] != true)
        end
      end
    when 3  # タイマー
      if $game_system.timer_working
        sec = $game_system.timer / Graphics.frame_rate
        if @params[2] == 0
          result = (sec >= @params[1])
        else
          result = (sec <= @params[1])
        end
      end
    when 4  # アクター
      actor = $game_actors[@params[1]]
      if actor != nil
        case @params[2]
        when 0  # パーティにいる
          result = ($game_party.members.include?(actor))
        when 1  # 名前
          result = (actor.name == @params[3])
        when 2  # スキル
          result = (actor.skill_learn?($data_skills[@params[3]]))
        when 3  # 武器
          result = (actor.weapons.include?($data_weapons[@params[3]]))
        when 4  # 防具
          result = (actor.armors.include?($data_armors[@params[3]]))
        when 5  # ステート
          result = (actor.state?(@params[3]))
        end
      end
    when 5  # 敵キャラ
      enemy = $game_troop.members[@params[1]]
      if enemy != nil
        case @params[2]
        when 0  # 出現している
          result = (enemy.exist?)
        when 1  # ステート
          result = (enemy.state?(@params[3]))
        end
      end
    when 6  # キャラクター
      character = get_character(@params[1])
      if character != nil
        result = (character.direction == @params[2])
      end
    when 7  # ゴールド
      if @params[2] == 0
        result = ($game_party.gold >= @params[1])
      else
        result = ($game_party.gold <= @params[1])
      end
    when 8  # アイテム
      result = $game_party.has_item?($data_items[@params[1]])
    when 9  # 武器
      result = $game_party.has_item?($data_weapons[@params[1]], @params[2])
    when 10  # 防具
      result = $game_party.has_item?($data_armors[@params[1]], @params[2])
    when 11  # ボタン
      result = Input.press?(@params[1])
    when 12  # スクリプト
      result = eval(@params[1])
    when 13  # 乗り物
      result = ($game_player.vehicle_type == @params[1])
    end
    @branch[@indent] = result     # 判定結果をハッシュに格納
    if @branch[@indent] == true
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #
  # それ以外の場合
  #
  #
  def command_411
    if @branch[@indent] == false
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #
  # ループ
  #
  #
  def command_112
    return true
  end
  #
  # 以上繰り返し
  #
  #
  def command_413
    begin
      @index -= 1
    end until @list[@index].indent == @indent
    return true
  end
  #
  # ループの中断
  #
  #
  def command_113
    loop do
      @index += 1
      if @index >= @list.size-1
        return true
      end
      if @list[@index].code == 413 and    # コマンド [以上繰り返し]
         @list[@index].indent < @indent   # インデントが浅い
        return true
      end
    end
  end
  #
  # イベント処理の中断
  #
  #
  def command_115
    command_end
    return true
  end
  #
  # コモンイベント
  #
  #
  def command_117
    common_event = $data_common_events[@params[0]]
    if common_event != nil
      @child_interpreter = Game_Interpreter.new(@depth + 1)
      @child_interpreter.setup(common_event.list, @event_id)
    end
    return true
  end
  #
  # ラベル
  #
  #
  def command_118
    return true
  end
  #
  # ラベルジャンプ
  #
  #
  def command_119
    label_name = @params[0]
    for i in 0...@list.size
      if @list[i].code == 118 and @list[i].parameters[0] == label_name
        @index = i
        return true
      end
    end
    return true
  end
  #
  # スイッチの操作
  #
  #
  def command_121
    for i in @params[0] .. @params[1]   # 一括操作ループ
      $game_switches[i] = (@params[2] == 0)
    end
    $game_map.need_refresh = true
    return true
  end
  #
  # 変数の操作
  #
  #
  def command_122
    value = 0
    case @params[3]  # オペランド
    when 0  # 定数
      value = @params[4]
    when 1  # 変数
      value = $game_variables[@params[4]]
    when 2  # 乱数
      value = @params[4] + rand(@params[5] - @params[4] + 1)
    when 3  # アイテム
      value = $game_party.item_number($data_items[@params[4]])
    when 4  # アクター
      actor = $game_actors[@params[4]]
      if actor != nil
        case @params[5]
        when 0  # レベル
          value = actor.level
        when 1  # 経験値
          value = actor.exp
        when 2  # HP
          value = actor.hp
        when 3  # MP
          value = actor.mp
        when 4  # MaxHP
          value = actor.maxhp
        when 5  # MaxMP
          value = actor.maxmp
        when 6  # 攻撃力
          value = actor.atk
        when 7  # 防御力
          value = actor.def
        when 8  # 精神力
          value = actor.spi
        when 9  # 敏捷性
          value = actor.agi
        end
      end
    when 5  # 敵キャラ
      enemy = $game_troop.members[@params[4]]
      if enemy != nil
        case @params[5]
        when 0  # HP
          value = enemy.hp
        when 1  # MP
          value = enemy.mp
        when 2  # MaxHP
          value = enemy.maxhp
        when 3  # MaxMP
          value = enemy.maxmp
        when 4  # 攻撃力
          value = enemy.atk
        when 5  # 防御力
          value = enemy.def
        when 6  # 精神力
          value = enemy.spi
        when 7  # 敏捷性
          value = enemy.agi
        end
      end
    when 6  # キャラクター
      character = get_character(@params[4])
      if character != nil
        case @params[5]
        when 0  # X 座標
          value = character.x
        when 1  # Y 座標
          value = character.y
        when 2  # 向き
          value = character.direction
        when 3  # 画面 X 座標
          value = character.screen_x
        when 4  # 画面 Y 座標
          value = character.screen_y
        end
      end
    when 7  # その他
      case @params[4]
      when 0  # マップ ID
        value = $game_map.map_id
      when 1  # パーティ人数
        value = $game_party.members.size
      when 2  # ゴールド
        value = $game_party.gold
      when 3  # 歩数
        value = $game_party.steps
      when 4  # プレイ時間
        value = Graphics.frame_count / Graphics.frame_rate
      when 5  # タイマー
        value = $game_system.timer / Graphics.frame_rate
      when 6  # セーブ回数
        value = $game_system.save_count
      end
    end
    for i in @params[0] .. @params[1]   # 一括操作ループ
      case @params[2]  # 操作
      when 0  # 代入
        $game_variables[i] = value
      when 1  # 加算
        $game_variables[i] += value
      when 2  # 減算
        $game_variables[i] -= value
      when 3  # 乗算
        $game_variables[i] *= value
      when 4  # 除算
        $game_variables[i] /= value if value != 0
      when 5  # 剰余
        $game_variables[i] %= value if value != 0
      end
      if $game_variables[i] > 99999999    # 上限チェック
        $game_variables[i] = 99999999
      end
      if $game_variables[i] < -99999999   # 下限チェック
        $game_variables[i] = -99999999
      end
    end
    $game_map.need_refresh = true
    return true
  end
  #
  # セルフスイッチの操作
  #
  #
  def command_123
    if @original_event_id > 0
      key = [@map_id, @original_event_id, @params[0]]
      $game_self_switches[key] = (@params[1] == 0)
    end
    $game_map.need_refresh = true
    return true
  end
  #
  # タイマーの操作
  #
  #
  def command_124
    if @params[0] == 0  # 始動
      $game_system.timer = @params[1] * Graphics.frame_rate
      $game_system.timer_working = true
    end
    if @params[0] == 1  # 停止
      $game_system.timer_working = false
    end
    return true
  end
  #
  # 所持金の増減
  #
  #
  def command_125
    value = operate_value(@params[0], @params[1], @params[2])
    $game_party.gain_gold(value)
    return true
  end
  #
  # アイテムの増減
  #
  #
  def command_126
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_items[@params[0]], value)
    $game_map.need_refresh = true
    return true
  end
  #
  # 武器の増減
  #
  #
  def command_127
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_weapons[@params[0]], value, @params[4])
    return true
  end
  #
  # 防具の増減
  #
  #
  def command_128
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_armors[@params[0]], value, @params[4])
    return true
  end
  #
  # メンバーの入れ替え
  #
  #
  def command_129
    actor = $game_actors[@params[0]]
    if actor != nil
      if @params[1] == 0    # 加える
        if @params[2] == 1  # 初期化
          $game_actors[@params[0]].setup(@params[0])
        end
        $game_party.add_actor(@params[0])
      else                  # 外す
        $game_party.remove_actor(@params[0])
      end
      $game_map.need_refresh = true
    end
    return true
  end
  #
  # バトル BGM の変更
  #
  #
  def command_132
    $game_system.battle_bgm = @params[0]
    return true
  end
  #
  # バトル終了 ME の変更
  #
  #
  def command_133
    $game_system.battle_end_me = @params[0]
    return true
  end
  #
  # セーブ禁止の変更
  #
  #
  def command_134
    $game_system.save_disabled = (@params[0] == 0)
    return true
  end
  #
  # メニュー禁止の変更
  #
  #
  def command_135
    $game_system.menu_disabled = (@params[0] == 0)
    return true
  end
  #
  # エンカウント禁止の変更
  #
  #
  def command_136
    $game_system.encounter_disabled = (@params[0] == 0)
    $game_player.make_encounter_count
    return true
  end
  #
  # 場所移動
  #
  #
  def command_201
    return true if $game_temp.in_battle
    if $game_player.transfer? or            # 場所移動中
       $game_message.visible                # メッセージ表示中
      return false
    end
    if @params[0] == 0                      # 直接指定
      map_id = @params[1]
      x = @params[2]
      y = @params[3]
      direction = @params[4]
    else                                    # 変数で指定
      map_id = $game_variables[@params[1]]
      x = $game_variables[@params[2]]
      y = $game_variables[@params[3]]
      direction = @params[4]
    end
    $game_player.reserve_transfer(map_id, x, y, direction)
    @index += 1
    return false
  end
  #
  # 乗り物の位置設定
  #
  #
  def command_202
    if @params[1] == 0                      # 直接指定
      map_id = @params[2]
      x = @params[3]
      y = @params[4]
    else                                    # 変数で指定
      map_id = $game_variables[@params[2]]
      x = $game_variables[@params[3]]
      y = $game_variables[@params[4]]
    end
    if @params[0] == 0                      # 小型船
      $game_map.boat.set_location(map_id, x, y)
    elsif @params[0] == 1                   # 大型船
      $game_map.ship.set_location(map_id, x, y)
    else                                    # 飛行船
      $game_map.airship.set_location(map_id, x, y)
    end
    return true
  end
  #
  # イベントの位置設定
  #
  #
  def command_203
    character = get_character(@params[0])
    if character != nil
      if @params[1] == 0                      # 直接指定
        character.moveto(@params[2], @params[3])
      elsif @params[1] == 1                   # 変数で指定
        new_x = $game_variables[@params[2]]
        new_y = $game_variables[@params[3]]
        character.moveto(new_x, new_y)
      else                                    # 他のイベントと交換
        old_x = character.x
        old_y = character.y
        character2 = get_character(@params[2])
        if character2 != nil
          character.moveto(character2.x, character2.y)
          character2.moveto(old_x, old_y)
        end
      end
      case @params[4]   # 向き
      when 8  # 上
        character.turn_up
      when 6  # 右
        character.turn_right
      when 2  # 下
        character.turn_down
      when 4  # 左
        character.turn_left
      end
    end
    return true
  end
  #
  # マップのスクロール
  #
  #
  def command_204
    return true if $game_temp.in_battle
    return false if $game_map.scrolling?
    $game_map.start_scroll(@params[0], @params[1], @params[2])
    return true
  end
  #
  # 移動ルートの設定
  #
  #
  def command_205
    if $game_map.need_refresh
      $game_map.refresh
    end
    character = get_character(@params[0])
    if character != nil
      character.force_move_route(@params[1])
      @moving_character = character if @params[1].wait
    end
    return true
  end
  #
  # 乗り物の乗降
  #
  #
  def command_206
    $game_player.get_on_off_vehicle
    return true
  end
  #
  # 透明状態の変更
  #
  #
  def command_211
    $game_player.transparent = (@params[0] == 0)
    return true
  end
  #
  # アニメーションの表示
  #
  #
  def command_212
    character = get_character(@params[0])
    if character != nil
      character.animation_id = @params[1]
    end
    return true
  end
  #
  # フキダシアイコンの表示
  #
  #
  def command_213
    character = get_character(@params[0])
    if character != nil
      character.balloon_id = @params[1]
    end
    return true
  end
  #
  # イベントの一時消去
  #
  #
  def command_214
    if @event_id > 0
      $game_map.events[@event_id].erase
    end
    @index += 1
    return false
  end
  #
  # 画面のフェードアウト
  #
  #
  def command_221
    if $game_message.visible
      return false
    else
      screen.start_fadeout(30)
      @wait_count = 30
      return true
    end
  end
  #
  # 画面のフェードイン
  #
  #
  def command_222
    if $game_message.visible
      return false
    else
      screen.start_fadein(30)
      @wait_count = 30
      return true
    end
  end
  #
  # 画面の色調変更
  #
  #
  def command_223
    screen.start_tone_change(@params[0], @params[1])
    @wait_count = @params[1] if @params[2]
    return true
  end
  #
  # 画面のフラッシュ
  #
  #
  def command_224
    screen.start_flash(@params[0], @params[1])
    @wait_count = @params[1] if @params[2]
    return true
  end
  #
  # 画面のシェイク
  #
  #
  def command_225
    screen.start_shake(@params[0], @params[1], @params[2])
    @wait_count = @params[2] if @params[3]
    return true
  end
  #
  # ウェイト
  #
  #
  def command_230
    @wait_count = @params[0]
    return true
  end
  #
  # ピクチャの表示
  #
  #
  def command_231
    if @params[3] == 0    # 直接指定
      x = @params[4]
      y = @params[5]
    else                  # 変数で指定
      x = $game_variables[@params[4]]
      y = $game_variables[@params[5]]
    end
    screen.pictures[@params[0]].show(@params[1], @params[2],
      x, y, @params[6], @params[7], @params[8], @params[9])
    return true
  end
  #
  # ピクチャの移動
  #
  #
  def command_232
    if @params[3] == 0    # 直接指定
      x = @params[4]
      y = @params[5]
    else                  # 変数で指定
      x = $game_variables[@params[4]]
      y = $game_variables[@params[5]]
    end
    screen.pictures[@params[0]].move(@params[2], x, y, @params[6],
      @params[7], @params[8], @params[9], @params[10])
    @wait_count = @params[10] if @params[11]
    return true
  end
  #
  # ピクチャの回転
  #
  #
  def command_233
    screen.pictures[@params[0]].rotate(@params[1])
    return true
  end
  #
  # ピクチャの色調変更
  #
  #
  def command_234
    screen.pictures[@params[0]].start_tone_change(@params[1], @params[2])
    @wait_count = @params[2] if @params[3]
    return true
  end
  #
  # ピクチャの消去
  #
  #
  def command_235
    screen.pictures[@params[0]].erase
    return true
  end
  #
  # 天候の設定
  #
  #
  def command_236
    return true if $game_temp.in_battle
    screen.weather(@params[0], @params[1], @params[2])
    @wait_count = @params[2] if @params[3]
    return true
  end
  #
  # BGM の演奏
  #
  #
  def command_241
    @params[0].play
    return true
  end
  #
  # BGM のフェードアウト
  #
  #
  def command_242
    RPG::BGM.fade(@params[0] * 1000)
    return true
  end
  #
  # BGS の演奏
  #
  #
  def command_245
    @params[0].play
    return true
  end
  #
  # BGS のフェードアウト
  #
  #
  def command_246
    RPG::BGS.fade(@params[0] * 1000)
    return true
  end
  #
  # ME の演奏
  #
  #
  def command_249
    @params[0].play
    return true
  end
  #
  # SE の演奏
  #
  #
  def command_250
    @params[0].play
    return true
  end
  #
  # SE の停止
  #
  #
  def command_251
    RPG::SE.stop
    return true
  end
  #
  # バトルの処理
  #
  #
  def command_301
    return true if $game_temp.in_battle
    if @params[0] == 0                      # 直接指定
      troop_id = @params[1]
    else                                    # 変数で指定
      troop_id = $game_variables[@params[1]]
    end
    if $data_troops[troop_id] != nil
      $game_troop.setup(troop_id)
      $game_troop.can_escape = @params[2]
      $game_troop.can_lose = @params[3]
      $game_temp.battle_proc = Proc.new { |n| @branch[@indent] = n }
      $game_temp.next_scene = "battle"
    end
    @index += 1
    return false
  end
  #
  # 勝った場合
  #
  #
  def command_601
    if @branch[@indent] == 0
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #
  # 逃げた場合
  #
  #
  def command_602
    if @branch[@indent] == 1
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #
  # 負けた場合
  #
  #
  def command_603
    if @branch[@indent] == 2
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #
  # ショップの処理
  #
  #
  def command_302
    $game_temp.next_scene = "shop"
    $game_temp.shop_goods = [@params]
    $game_temp.shop_purchase_only = @params[2]
    loop do
      @index += 1
      if @list[@index].code == 605          # ショップ 2 行目以降
        $game_temp.shop_goods.push(@list[@index].parameters)
      else
        return false
      end
    end
  end
  #
  # 名前入力の処理
  #
  #
  def command_303
    if $data_actors[@params[0]] != nil
      $game_temp.next_scene = "name"
      $game_temp.name_actor_id = @params[0]
      $game_temp.name_max_char = @params[1]
    end
    @index += 1
    return false
  end
  #
  # HP の増減
  #
  #
  def command_311
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      next if actor.dead?
      if @params[4] == false and actor.hp + value <= 0
        actor.hp = 1    # 戦闘不能が許可されていなければ 1 にする
      else
        actor.hp += value
      end
      actor.perform_collapse
    end
    if $game_party.all_dead?
      $game_temp.next_scene = "gameover"
    end
    return true
  end
  #
  # MP の増減
  #
  #
  def command_312
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      actor.mp += value
    end
    return true
  end
  #
  # ステートの変更
  #
  #
  def command_313
    iterate_actor_id(@params[0]) do |actor|
      if @params[1] == 0
        actor.add_state(@params[2])
        actor.perform_collapse
      else
        actor.remove_state(@params[2])
      end
    end
    return true
  end
  #
  # 全回復
  #
  #
  def command_314
    iterate_actor_id(@params[0]) do |actor|
      actor.recover_all
    end
    return true
  end
  #
  # 経験値の増減
  #
  #
  def command_315
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      actor.change_exp(actor.exp + value, @params[4])
    end
    return true
  end
  #
  # レベルの増減
  #
  #
  def command_316
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      actor.change_level(actor.level + value, @params[4])
    end
    return true
  end
  #
  # 能力値の増減
  #
  #
  def command_317
    value = operate_value(@params[2], @params[3], @params[4])
    actor = $game_actors[@params[0]]
    if actor != nil
      case @params[1]
      when 0  # MaxHP
        actor.maxhp += value
      when 1  # MaxMP
        actor.maxmp += value
      when 2  # 攻撃力
        actor.atk += value
      when 3  # 防御力
        actor.def += value
      when 4  # 精神力
        actor.spi += value
      when 5  # 敏捷性
        actor.agi += value
      end
    end
    return true
  end
  #
  # スキルの増減
  #
  #
  def command_318
    actor = $game_actors[@params[0]]
    if actor != nil
      if @params[1] == 0
        actor.learn_skill(@params[2])
      else
        actor.forget_skill(@params[2])
      end
    end
    return true
  end
  #
  # 装備の変更
  #
  #
  def command_319
    actor = $game_actors[@params[0]]
    if actor != nil
      actor.change_equip_by_id(@params[1], @params[2])
    end
    return true
  end
  #
  # 名前の変更
  #
  #
  def command_320
    actor = $game_actors[@params[0]]
    if actor != nil
      actor.name = @params[1]
    end
    return true
  end
  #
  # 職業の変更
  #
  #
  def command_321
    actor = $game_actors[@params[0]]
    if actor != nil and $data_classes[@params[1]] != nil
      actor.class_id = @params[1]
    end
    return true
  end
  #
  # アクターのグラフィック変更
  #
  #
  def command_322
    actor = $game_actors[@params[0]]
    if actor != nil
      actor.set_graphic(@params[1], @params[2], @params[3], @params[4])
    end
    $game_player.refresh
    return true
  end
  #
  # 乗り物のグラフィック変更
  #
  #
  def command_323
    if @params[0] == 0                      # 小型船
      $game_map.boat.set_graphic(@params[1], @params[2])
    elsif @params[0] == 1                   # 大型船
      $game_map.ship.set_graphic(@params[1], @params[2])
    else                                    # 飛行船
      $game_map.airship.set_graphic(@params[1], @params[2])
    end
    return true
  end
  #
  # 敵キャラの HP 増減
  #
  #
  def command_331
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      if enemy.hp > 0
        if @params[4] == false and enemy.hp + value <= 0
          enemy.hp = 1    # 戦闘不能が許可されていなければ 1 にする
        else
          enemy.hp += value
        end
        enemy.perform_collapse
      end
    end
    return true
  end
  #
  # 敵キャラの MP 増減
  #
  #
  def command_332
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.mp += value
    end
    return true
  end
  #
  # 敵キャラのステート変更
  #
  #
  def command_333
    iterate_enemy_index(@params[0]) do |enemy|
      if @params[2] == 1                    # 戦闘不能の変更なら
        enemy.immortal = false              # 不死身フラグをクリア
      end
      if @params[1] == 0
        enemy.add_state(@params[2])
        enemy.perform_collapse
      else
        enemy.remove_state(@params[2])
      end
    end
    return true
  end
  #
  # 敵キャラの全回復
  #
  #
  def command_334
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.recover_all
    end
    return true
  end
  #
  # 敵キャラの出現
  #
  #
  def command_335
    enemy = $game_troop.members[@params[0]]
    if enemy != nil and enemy.hidden
      enemy.hidden = false
      $game_troop.make_unique_names
    end
    return true
  end
  #
  # 敵キャラの変身
  #
  #
  def command_336
    enemy = $game_troop.members[@params[0]]
    if enemy != nil
      enemy.transform(@params[1])
      $game_troop.make_unique_names
    end
    return true
  end
  #
  # 戦闘アニメーションの表示
  #
  #
  def command_337
    iterate_battler(0, @params[0]) do |battler|
      next unless battler.exist?
      battler.animation_id = @params[1]
    end
    return true
  end
  #
  # 戦闘行動の強制
  #
  #
  def command_339
    iterate_battler(@params[0], @params[1]) do |battler|
      next unless battler.exist?
      battler.action.kind = @params[2]
      if battler.action.kind == 0
        battler.action.basic = @params[3]
      else
        battler.action.skill_id = @params[3]
      end
      if @params[4] == -2                   # ラストターゲット
        battler.action.decide_last_target
      elsif @params[4] == -1                # ランダム
        battler.action.decide_random_target
      elsif @params[4] >= 0                 # インデックス指定
        battler.action.target_index = @params[4]
      end
      battler.action.forcing = true
      $game_troop.forcing_battler = battler
      @index += 1
      return false
    end
    return true
  end
  #
  # バトルの中断
  #
  #
  def command_340
    $game_temp.next_scene = "map"
    @index += 1
    return false
  end
  #
  # メニュー画面を開く
  #
  #
  def command_351
    $game_temp.next_scene = "menu"
    $game_temp.menu_beep = false
    @index += 1
    return false
  end
  #
  # セーブ画面を開く
  #
  #
  def command_352
    $game_temp.next_scene = "save"
    @index += 1
    return false
  end
  #
  # ゲームオーバー
  #
  #
  def command_353
    $game_temp.next_scene = "gameover"
    return false
  end
  #
  # タイトル画面に戻す
  #
  #
  def command_354
    $game_temp.next_scene = "title"
    return false
  end
  #
  # スクリプト
  #
  #
  def command_355
    script = @list[@index].parameters[0] + "\n"
    loop do
      if @list[@index+1].code == 655        # スクリプト 2 行目以降
        script += @list[@index+1].parameters[0] + "\n"
      else
        break
      end
      @index += 1
    end
    eval(script)
    return true
  end
end
