require 'nokogiri'
require 'open-uri'

URLs = []
ERRORs = []

source_location = "http://localhost:3000"

def construct_hash url
  base_url, params = url.split("?")[0], url.split("?")[1]
  params_key = params.split("&").map {|p| p[0...p.index('=')]} if params
  url_hash = {base_url: base_url, params: params_key, url:url}
  url_hash
end

ARGV.each do |arg_url|
  URLs << construct_hash(arg_url)
end

def check_for_exists url
  return unless /^\/.*/.match(url)
  url_hash = construct_hash url
  already_exist = URLs.detect do |parsed_url|
    parsed_url[:base_url] == url_hash[:base_url] && parsed_url[:params] == url_hash[:params]
  end
  return url_hash unless already_exist
end

for url in URLs do
  begin
    doc = Nokogiri::HTML(open([source_location, url[:url]].join))
  rescue
    ERRORs << url
    next
  end
  p "URL:#{url}"
  doc.css('a').each do |anchor|
    next_url = anchor.get_attribute("href")
    next if next_url.nil?
    url_to_append = check_for_exists next_url
    next if url_to_append.nil?
    URLs << url_to_append
  end
end

p ERRORs


