# encoding: utf-8
def download url, filename
  STDERR.puts "downloading #{url} into #{filename}"
	Net::HTTP rescue require 'net/http'
	Net::HTTP.start(URI(url).host) { |http|
	        resp = http.get(URI(url).path)
	        open(filename, "wb") { |file|
	                file.write(resp.body)
	        }
	}
end

def load_rgssscript(name)
  Zlib rescue require 'zlib'
  rgss_scripts = open(name, "rb") do |f| Marshal.load(f) end.map {|i| [i[1], ((a=Zlib::Inflate.inflate(i[2])).force_encoding("UTF-8") rescue a)]}
  rgss_scripts
end

task :default => [:doc]

task :doc => [:scripts] do |t|
  Dir.mkdir '_docs' rescue nil
  Dir['_sources/*'].each do |j|
    i = File.basename(j)
    Dir.chdir("#{i}")
    system("sdoc --op=../_docs/#{i} --debug")
    Dir.chdir("..")
  end
end

task :scripts => ["_sources"] do |t|
  Dir['_sources/*'].each do |i|
    scripts = load_rgssscript i
    building = File.basename(i)
    FileUtils.mkdir_p(File.basename(i)) rescue nil
    files = {}
    scripts.each do |k, v|
      next if k[/\(|\)/] || k.length == 0 || (k[/\s/] && !k[/\s\d+$/])
      v.gsub!(/\r\n/, "\n")
      v.gsub!(/\r/, "\n")
      v.gsub!(/#={10,}/, "#")
      v.gsub!(/#-{10,}/, "#")
      v.gsub!(/\n# ■ (.*)\n#/, "")
      v.gsub!(/\n# \*\*(.*)\n#/, "")
      v.gsub!(/( *)# \* (.*)\n/) { "#$1# #$2\n#$1#\n" }
      v.gsub!(/( *)# ● (.*)\n/) { "#$1# #$2\n#$1#\n" }
      while v[/#.*?　+/]
        v.gsub!(/(#.*?　+)/) { $1.gsub("　", "  ") }
      end
      v.gsub!(/# {2,}/, "# ")
      while v[/(#.*?) (@[a-zA-Z._0-9]*) /]
        v.gsub!(/(#.*?) (@[a-zA-Z._0-9]*) /) { "#$1 `#$2` "}
      end
      k.gsub!(/\s+\d+$/, "")
      if files[k]
        files[k] += "\n\n" << v
      else
        files[k] = v
      end
    end
    files.each do |k, v|
      File.open("#{File.basename(i)}/#{k}.rb", "w") do |io|
        io.write v
      end
    end
  end
end
