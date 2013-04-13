require 'nokogiri'
require 'open-uri'

URLs = []

source_url = ARGV[0]
source_location = "http://localhost:3000"

URLs << source_url

def check_for_exists url
  matched_url = /(^\/.*\?|^\/.*)/.match(url)
  return unless matched_url
  url = matched_url[0].gsub("?", "")
  already_exist = URLs.detect do |parsed_url|
    parsed_url.start_with? url
  end
  return url unless already_exist
end

for url in URLs do
  doc = Nokogiri::HTML(open([source_location, url].join))
  p doc.content
  doc.css('a').each do |anchor|
    next_url = anchor.get_attribute("href")
    URLs << next_url if check_for_exists next_url
  end
end

