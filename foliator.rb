#!/usr/bin/env ruby
require 'json'
require 'document/foliator'
require 'net/http'
require 'uri'
require 'mime/types'
require 'net/http/post/multipart'

def send_file_to_s3(file_path, s3_options)
  puts "send_file_to_s3 multipart"

  key = s3_options[:key]
  success_action_redirect = s3_options[:success_action_redirect]
  direct_fog_url = s3_options[:direct_fog_url]
  aws_access_key_id = s3_options[:aws_access_key_id]
  acl = s3_options[:acl]
  policy = s3_options[:policy]
  signature = s3_options[:signature]

  filename = File.basename(file_path)
  mime_type = MIME::Types.type_for(file_path)

  params = {
    "key" => key,
    "AWSAccessKeyId" => aws_access_key_id,
    "acl" => acl,
    "policy" => policy,
    "signature" => signature,
    "success_action_redirect" => success_action_redirect,
    "Content-Type" => mime_type,
    "utf8" => "✓",
    "file" => UploadIO.new(File.open(file_path), mime_type, filename)
  }

  url = URI.parse(direct_fog_url)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = (url.scheme == "https")
  http.start do
    req = Net::HTTP::Post::Multipart.new(url, params)
    response = http.request(req)

    puts response.code
    puts response.body
  end
end

def save_temp_pdf foliated_pdf
  tmp_foliated_pdf = Tempfile.new(['tempfile-', '.pdf'])
  tmp_foliated_pdf.binmode
  tmp_foliated_pdf.write foliated_pdf.to_pdf
  tmp_foliated_pdf.close

  tmp_foliated_pdf.path
end


if ARGV.length > 0
  options = JSON.parse( ARGV[0], {symbolize_names: true} )
  puts options
  file_options = options[:file]
  s3_options = options[:s3]

  file_url = file_options[:file_url]
  start_folio = file_options[:start_folio] || 1
  just_folios = file_options[:just_folios]
  pixels_to_left = file_options[:pixels_to_left] || 0
  double_sided = file_options[:double_sided]
  every_other_page = file_options[:every_other_page]
  stamp_url = file_options[:stamp_url]
  issue_date = file_options[:issue_date]

  if file_url
    foliated_pdf = Document::Foliator.foliate_from_url(
      file_url, start_folio, just_folios, pixels_to_left, double_sided,
      every_other_page, stamp_url, issue_date
    )
    if foliated_pdf
      puts "File at #{file_url}. Pages of foliated document: #{foliated_pdf.pages.count}"

      temp_file_path = save_temp_pdf(foliated_pdf)
      puts temp_file_path

      send_file_to_s3(temp_file_path, s3_options)
    else
      puts "File at #{file_url} could not be foliated"
    end
  end
end

puts 'Finished'
