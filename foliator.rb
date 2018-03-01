#!/usr/bin/env ruby
require 'json'
require 'document/foliator'
require 'combine_pdf'
require 'open-uri'

puts JSON.parse('{ "we" : "love", "using" : "Lambda" }')

if ARGV.length > 0
  options = JSON.parse( ARGV[0] )
  puts options
end

file_url = 'https://s1.q4cdn.com/806093406/files/doc_downloads/test.pdf'
file = open file_url
pdf = CombinePDF.parse file.read
foliated_pdf = Document::Foliator.foliate(pdf, 1, false, 0, false, false)
puts "Pages of foliated document: #{foliated_pdf.pages.count}"
