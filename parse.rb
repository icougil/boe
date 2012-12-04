require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'

def get_BOE_id(filename)
  filename =~ /(BOE-.-\d{4}-\d+)/
  $1
end

def parse_file(filename)
  doc = Nokogiri::HTML(open(filename))
  title = doc.search(".documento-tit").text

  # TODO: Pardon text doc.search("p.parrafo"). Signature: doc.search("p.parrafo_2")


  if title =~ /se indulta a (.*)\./
    puts "#{get_BOE_id(filename)},#{$1}"
  end
end

puts 'File,Title'
Dir['data/*.html'].each {|filename| parse_file(filename)}
