#! /usr/bin/ruby

# @return [Hash] hash of widget names and class implementing it
def widget_mapping
  source_path = File.expand_path("../../src/YCPDialogParser.cc", __FILE__)
  lines = File.readlines(source_path)
  res = {}
  curr_widgets = nil
  lines.each do |l|
    case l
    when /@widget/
      widgets = l[/@widget\s+(.*\S)\s*$/, 1]
      curr_widgets = widgets.split
    when /@class/
      klass = l[/@class\s+(\S+)\s*$/, 1]
      curr_widgets.each do |w|
        res[w] = klass
      end
    end
  end

  res
end

# @return [Array] list of builtns
def builtins
  source_path = File.expand_path("../../src/YCP_UI.cc", __FILE__)
  lines = File.readlines(source_path)
  res = []
  lines.each do |l|
    case l
    when /@builtin/
      builtin = l[/@builtin\s+(.*\S)\s*$/, 1]
      res << builtin
    end
  end

  res
end

path = File.expand_path("../../doc/index.md", __FILE__)
File.open(path, "w") do |file|
  file.puts "Widgets list:"
  file.puts "-------------"
  file.puts ""
  widgets = widget_mapping
  widgets.keys.sort.each do |widget|
    file.puts "- [#{widget}](@ref #{widgets[widget]})"
  end

  file.puts ""
  file.puts "Yast::UI methods:"
  file.puts "-------------"
  file.puts ""
  builtins.sort.each do |builtin|
    file.puts "- [#{builtin}](@ref YCP_UI::#{builtin})"
  end

end
