#!/usr/bin/env ruby
require 'json'
require 'document/foliator'

if ARGV.length > 0
  options = JSON.parse( ARGV[0], {symbolize_names: true} )
  puts options
  file_url = options[:file_url]
  start_folio = options[:start_folio] || 1
  just_folios = options[:just_folios]
  pixels_to_left = options[:pixels_to_left] || 0
  double_sided = options[:double_sided]
  every_other_page = options[:every_other_page]
  stamp_url = options[:stamp_url]
  issue_date = options[:issue_date]

  if file_url
    foliated_pdf = Document::Foliator.foliate_from_url(
      file_url, start_folio, just_folios, pixels_to_left, double_sided,
      every_other_page, stamp_url, issue_date
    )
    if foliated_pdf
      puts "File at #{file_url}. Pages of foliated document: #{foliated_pdf.pages.count}"
    else
      puts "File at #{file_url} could not be foliated"
    end
  end
end

puts 'Finished'
