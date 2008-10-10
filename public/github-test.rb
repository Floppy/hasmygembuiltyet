#!/usr/bin/env ruby
 
# An improved GitHub gemspec checker.
# GitHub accepts YAML dumps for the gemspecs, which helps keep your gem generation tasks DRY
 
if ARGV.size < 1
  puts "Usage: github-test.rb my-project.gemspec"
  exit
end
 
require 'rubygems/specification'
data = File.read(ARGV[0])
spec = nil
begin
  Thread.new { spec = eval("$SAFE = 3\n#{data}") }.join
rescue SyntaxError
  #Output in YAML format, then?
  require 'yaml'
  Thread.new { spec = YAML.load(data) }.join
end
puts spec
puts "OK"
