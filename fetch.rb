#!/usr/bin/env ruby
# encoding: UTF-8
# NOTE: Currently we are only fetching the BOE-A series

require 'rubygems'
require 'mechanize'
require 'fastercsv'
require 'nokogiri'
require 'open-uri'

YEAR = ARGV[0]

class BOESpider
  def initialize
    @agent = Mechanize.new
  end

  def get_latest_announcement_number(year)
    # Get a link to the latest available BOE of the year
    puts "Fetching publication calendar for year #{year}..."
    calendar = @agent.get("http://www.boe.es/diario_boe/calendarios.php?a=#{year}")
    latest_boe_link = calendar.links_with(:href => /dias/).last

    # The link is just to a section of the BOE, not the full summary, so add a parameter
    puts "Fetching latest BOE for year #{year}..."
    latest_boe_link.uri.query='s=c'
    latest_boe = @agent.get(latest_boe_link.uri)
    latest_announcement = latest_boe.links_with(:href => /BOE-A/).last

    # We got it, the link to the last announcement. Extract the announcement number.
    latest_announcement.href =~ /-(\d+)$/
    $1.to_i
  end

  def fetch_year(year)
    latest_announcement = get_latest_announcement_number(year)
    puts "Got latest announcement id for year #{year}: #{latest_announcement}..."

    1.upto(latest_announcement) do |i|
      filename = "data/BOE-A-#{year}-#{i}.html"
      unless File.exists?(filename)
        puts "Downloading BOE item BOE-A-#{year}-#{i}..."
        boe_page = @agent.get("http://www.boe.es/buscar/doc.php?id=BOE-A-#{year}-#{i}")
        File.open(filename, 'w') {|f| f.write( boe_page.content ) }
        sleep(2)
      end
    end
  end
end

spider = BOESpider.new()
spider.fetch_year(YEAR)