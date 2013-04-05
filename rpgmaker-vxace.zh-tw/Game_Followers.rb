#encoding:utf-8
#
# 包裝跟隨角色的數組的外殼。本類在 Game_Player 類的內定使用。
#

class Game_Followers
  #
  # 定義案例變量
  #
  #
  attr_accessor :visible                  # 可視狀態 (true 則開啟人物跟隨)
  #
  # 初始化物件
  #
  # leader : 帶隊的角色
  #
  def initialize(leader)
    @visible = $data_system.opt_followers
    @gathering = false                    # 集合處理中的標志
    @data = []
    @data.push(Game_Follower.new(1, leader))
    (2...$game_party.max_battle_members).each do |index|
      @data.push(Game_Follower.new(index, @data[-1]))
    end
  end
  #
  # 取得跟隨角色
  #
  #
  def [](index)
    @data[index]
  end
  #
  # 迭代
  #
  #
  def each
    @data.each {|follower| yield follower } if block_given?
  end
  #
  # 迭代（逆向）
  #
  #
  def reverse_each
    @data.reverse.each {|follower| yield follower } if block_given?
  end
  #
  # 重新整理
  #
  #
  def refresh
    each {|follower| follower.refresh }
  end
  #
  # 更新畫面
  #
  #
  def update
    if gathering?
      move unless moving? || moving?
      @gathering = false if gather?
    end
    each {|follower| follower.update }
  end
  #
  # 搬移
  #
  #
  def move
    reverse_each {|follower| follower.chase_preceding_character }
  end
  #
  # 同步
  #
  #
  def synchronize(x, y, d)
    each do |follower|
      follower.moveto(x, y)
      follower.set_direction(d)
    end
  end
  #
  # 集合
  #
  #
  def gather
    @gathering = true
  end
  #
  # 判定是否集合當中
  #
  #
  def gathering?
    @gathering
  end
  #
  # 取得顯示中的跟隨角色的數組
  #
  #
  def visible_folloers
    @data.select {|follower| follower.visible? }
  end
  #
  # 判定是否搬移中
  #
  #
  def moving?
    visible_folloers.any? {|follower| follower.moving? }
  end
  #
  # 判定是否集合完畢
  #
  #
  def gather?
    visible_folloers.all? {|follower| follower.gather? }
  end
  #
  # 碰撞的判定
  #
  #
  def collide?(x, y)
    visible_folloers.any? {|follower| follower.pos?(x, y) }
  end
end
