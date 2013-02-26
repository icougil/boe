#!/usr/bin/env ruby
# encoding: UTF-8
# NOTE: Currently we are only fetching the BOE-A series

require 'rubygems'
require 'mechanize'
require 'csv' 
require 'nokogiri'
require 'open-uri'
require 'fileutils'

YEAR = ARGV[0]
BASE_URL='http://www.boe.es/buscar/boe.php?'
PREFFIX_URL='frases=no&campo[0]=ORI&dato[0]=&operador[0]=and&campo[1]=DOC&dato[1]=Indulto&operador[1]=and&campo[6]=FPU'
SUFFIX_URL='&operador[6]=and&sort_field[0]=fpu&sort_order[0]=asc&sort_field[1]=ref&sort_order[1]=asc&accion=Buscar'
# We will always try to get as many page_hits as possible
PREFIX_SEARCH_URL='accion=Mas&coleccion=boe&page_hits=1000'
CK_SUBDIR = 'crosscheck'
FileUtils.makedirs(CK_SUBDIR)

class BOESearchSpider
  def initialize
    @agent = Mechanize.new
    @output_file = File.open("#{CK_SUBDIR}/crosscheck#{YEAR}.csv", 'w')
    @output_file.puts CSV::generate_line(["boe","url"])
  end

  def get_search_id(year)
    # Get the hidden search id for this search params
    dates_params="&dato[6][0]=01/01/#{YEAR}&dato[6][1]=31/12/#{YEAR}"
    results = @agent.get("#{BASE_URL}#{PREFFIX_URL}#{dates_params}#{SUFFIX_URL}")
    id_busqueda = results.form.field_with(:name => 'id_busqueda').value
    return id_busqueda
  end

  def get_search_results(year)
    id_busqueda = get_search_id(year)
    fetch_results(id_busqueda,0)
    t_num_results = @agent.page.parser.css('div.paginar li')[0].text =~ /\s*de\s*(\d+)$/
    num_results = $1.to_i
    # If more than 1000 search results fetch next 1000.
    fetch_results(id_busqueda,1000) if (num_results > 1000)      
    @output_file.close
  end
  
  def fetch_results(id,start)
    params = "&start=#{start}&id_busqueda=#{id}"
    @agent.get("#{BASE_URL}#{PREFIX_SEARCH_URL}#{params}")
    results = @agent.page.parser.css('div.listadoResult div.enlacesMas a').map { |link| link['href'] }.uniq
    results.each {|result|
      result.gsub!(/\.\.\//,"http://www.boe.es/")
      result =~ /id=(.*)$/
      @output_file.puts CSV::generate_line([$1,result])
    }
  end
end

spider = BOESearchSpider.new()
spider.get_search_results(YEAR)
