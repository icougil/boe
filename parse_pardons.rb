require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'

require './lib/PardonParser.rb'

# So I can tail the output file in real time when redirecting
STDOUT.sync = true

puts 'File,Title'
Dir['data/*.html'].each do |filename| 
  PardonParser.parse_file Nokogiri::HTML(open(filename))
end
