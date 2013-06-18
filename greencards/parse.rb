#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'csv'

require './lib/GreenCardParser.rb'

fields = [:boe_id, :decree_id, :year, :date, :gender, :name]

PATH = ARGV[0]
Dir["#{PATH}/*.html"].each do |filename| 
  green_card = GreenCardParser.parse_file Nokogiri::HTML(open(filename))

  unless green_card.nil?
    output_record = []
    fields.each {|field| output_record << green_card[field] }
    puts CSV::generate_line output_record
  end
end
