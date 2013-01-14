#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'csv'

require './lib/PardonParser.rb'

HEADER = 'BOE,Fecha,Departamento,Nombre,Tribunal,Fecha condena,Papel,Crimen,Categoría crimen,Sentencia,Año crimen,Tipo indulto,Reducción/Nueva condena,Condición,Fecha concesión,Ministro'
LOG_SUBDIR = 'logs'
OUTPUT_FILES_SUBDIR = 'output'
YEAR = ARGV[0]
PATH = ARGV[1]
FileUtils.makedirs(LOG_SUBDIR)
FileUtils.makedirs(OUTPUT_FILES_SUBDIR)

$log_file = File.open("#{LOG_SUBDIR}/parse_pardons#{YEAR}.log", 'w')
#Detected pardon statements file
$output_file = File.open("#{OUTPUT_FILES_SUBDIR}/Indultos#{YEAR}.csv", 'w')
$output_file.puts HEADER
#Detected pardon statements with unhandled fields file for manual review
$output_debug_file = File.open("#{OUTPUT_FILES_SUBDIR}/IndultosDebug#{YEAR}.csv", 'w')
$output_debug_file.puts HEADER
count = 1
pardons_ok = 0
pardons_nok = 0
Dir["#{PATH}/*.html"].each do |filename| 
  puts "parsed #{count} BOE documents: found #{pardons_ok} OkPardons and #{pardons_nok} DebugPardons." if (count % 1000 == 0)
  result = PardonParser.parse_file Nokogiri::HTML(open(filename))
  if !result.nil?
    if result 
      pardons_ok += 1
    else
      pardons_nok += 1
    end
  end
  count += 1
end
puts "found #{pardons_ok} OkPardons and #{pardons_nok} DebugPardons."
$log_file.close
$output_file.close
$output_debug_file.close

