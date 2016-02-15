#!/usr/bin/env ruby -w
# ----------------------------------------------------------------------------- #
#         File: html2csv.rb
#  Description: 
#       Author:  r kumar
#         Date: 2016-02-04 - 20:43
#  Last update: 2016-02-10 20:46
#      License: MIT License
# ----------------------------------------------------------------------------- #
#
# XXX French open uses a th scope = row for the winner, so we don't get the winner at all !

require 'nokogiri'

file=ARGV[0]
delim = "\t"
table_string = File.open(file,"r").readlines.join("\n")
doc = Nokogiri::HTML(table_string)

doc.xpath('//table//tr').each do |row|
  arr=[]
  row.xpath('td').each do |cell|
    cell.search("span.sortkey").remove
    # this forces a space in country which strip does not remove
    cell.search("span.flagicon").remove
    #print '"', cell.text.gsub("\n", ' ').gsub('"', '\"').gsub(/(\s){2,}/m, '\1'), "\", "
    val = cell.text.gsub("\n", ' ').gsub(/(\s){2,}/m, '\1').strip
    arr << val
  end
  puts arr.join(delim)
end
