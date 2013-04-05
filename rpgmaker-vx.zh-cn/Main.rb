#
# 各个类定义结束后，从这里开始进行实际处理。
#

begin
  Font.default_name = ["黑体"]
  Graphics.freeze
  $scene = Scene_Title.new
  $scene.main while $scene != nil
  Graphics.transition(30)
rescue Errno::ENOENT
  filename = $!.message.sub("No such file or directory - ", "")
  print("文件 #{filename} 无法找到。")
end
