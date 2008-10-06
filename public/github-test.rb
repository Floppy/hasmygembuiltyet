#!/usr/bin/env ruby

if ARGV.size < 1
  puts "Usage: github-test.rb my-project.gemspec"
  exit
end

require 'rubygems/specification'
data = File.read(ARGV[0])
spec = nil
Thread.new { spec = eval("$SAFE = 3\n#{data}") }.join
puts spec
puts "OK"
