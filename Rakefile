require "yast/rake"

Yast::Tasks.configuration do |conf|
  #lets ignore license check for now
  conf.skip_license_check << /.*/
end

task :doc do
  rm_rf "autodoc"
  mkdir "autodoc"
  sh "doc/generate_index.rb"
  sh "doxygen Doxyfile"
end
