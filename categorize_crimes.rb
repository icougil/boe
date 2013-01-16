#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'fileutils'
require 'csv'

def load_crime_category_matching_pairs()
  csv_data = CSV.read "#{MATCH_FILE}"
  headers = csv_data.shift.map {|i| i.to_s }
  string_data = csv_data.map {|row| row.map {|cell| cell.to_s } }
  cat_pairs = string_data.map {|row| Hash[*headers.zip(row).flatten] }
  return cat_pairs
end

LOG_SUBDIR = 'logs'
INPUT_FILES_SUBDIR = 'csv'
MATCH_FILE = 'crime_category_matching.csv'
INPUT_FILE = 'pardons.csv'
OUTPUT_FILES_SUBDIR = 'output'
OUTPUT_FILE = 'pardons_categorized.csv'
FileUtils.makedirs(LOG_SUBDIR)
FileUtils.makedirs(OUTPUT_FILES_SUBDIR)

log_file = File.open("#{LOG_SUBDIR}/categorize_crimes.log", 'w')
output_file = File.open("#{OUTPUT_FILES_SUBDIR}/#{OUTPUT_FILE}", 'w')

crime_category_pairs = load_crime_category_matching_pairs()
count = 1
CSV.foreach("#{INPUT_FILES_SUBDIR}/#{INPUT_FILE}",:headers => true, :quote_char => '"', :row_sep =>:auto) do |row|
  puts "processed #{count} pardons." if (count % 1000 == 0)
  # Write the header to the output_file
  output_file.puts row.headers().join(",") if count == 1
  
  if !(row["Departamento"].eql? "Ministerio de Defensa")
    # TODO Split into individual crimes
    crimes = [] 
    crimes = row["Crime_list"].split(";") if row["Crime_list"]
    cat = []
    #for (crime in crimes) do
    crimes.each {|c|
      hash = crime_category_pairs.detect {|f| f["Crime"].casecmp(c.strip) == 0}
      if hash
        cat.push(hash["Category"])
      else
        log_file.puts("#{row["BOE"]}: no category found on crime '#{c}'")
      end
    }
    # Remove category duplicates
    cat = cat.uniq
    row["Categorías crimen"] = cat.join(";")
  else
    # If it is a military pardon clasify them all together.
    row["Categorías crimen"] = "90"
  end
  output_file.puts row.to_csv()
  count += 1
end
# We start at one so adjust to appropiate number
puts "processed #{count-1} pardons."
output_file.close
log_file.close