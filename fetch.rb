require 'rubygems'
require 'mechanize'
require 'fastercsv'
require 'nokogiri'
require 'open-uri'

agent = Mechanize.new

# TODO: Find out maximum item number dynamically
# TODO: Section B
# TODO: Other years
year = 2012
1.upto(14783) do |i|
  filename = "data/BOE-A-#{year}-#{i}.html"
  unless File.exists?(filename)
    puts "Downloading BOE item BOE-A-#{year}-#{i}..."
    boe_page = agent.get("http://www.boe.es/buscar/doc.php?id=BOE-A-#{year}-#{i}")
    File.open(filename, 'w') {|f| f.write( boe_page.content ) }
    sleep(2)
  end
end