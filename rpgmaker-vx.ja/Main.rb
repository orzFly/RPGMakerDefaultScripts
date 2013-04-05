#
# 各クラスの定義が終わった後、ここから実際の処理が始まります。
#

unless Font.exist?("UmePlus Gothic")
  print "UmePlus Gothic フォントが見つかりません。"
  exit
end

begin
  Graphics.freeze
  $scene = Scene_Title.new
  $scene.main while $scene != nil
  Graphics.transition(30)
rescue Errno::ENOENT
  filename = $!.message.sub("No such file or directory - ", "")
  print("ファイル #{filename} が見つかりません。")
end
