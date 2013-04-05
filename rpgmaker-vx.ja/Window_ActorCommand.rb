#
# バトル画面で、戦うか逃げるかを選択するウィンドウです。
#

class Window_ActorCommand < Window_Command
  #
  # オブジェクト初期化
  #
  #
  def initialize
    super(128, [], 1, 4)
    self.active = false
  end
  #
  # セットアップ
  #
  # actor : アクター
  #
  def setup(actor)
    s1 = Vocab::attack
    s2 = Vocab::skill
    s3 = Vocab::guard
    s4 = Vocab::item
    if actor.class.skill_name_valid     # スキルのコマンド名が有効？
      s2 = actor.class.skill_name       # コマンド名を置き換える
    end
    @commands = [s1, s2, s3, s4]
    @item_max = 4
    refresh
    self.index = 0
  end
end
