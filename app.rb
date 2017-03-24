require 'open-uri'
require 'nokogiri'

URL_ROOT_REGEX = /(\Ahttp|\Ahttps)\:\/\/(?<root>[^\/]*)(\/|\Z)/

def uri_link_builder(href, source)
  if /\Ahttps:\/\//.match(href) || /\Ahttp:\/\//.match(href)
    return(href)
  elsif /\A([a-z]{2}|[a-z]{3})\./.match(href)
    return("http://" + href)
  elsif /\Ahttp:\/\//.match(href).nil? && /\Ahttps:\/\//.match(href).nil? && /\Awww\./.match(href).nil? && !/\A\//.match(href)
    return("http://www." + href)
  elsif /\A\/\//.match(href)
    return("http://www." + href[2..-1])
  elsif /\A\//.match(href)
    # puts("Root is: #{URL_ROOT_REGEX.match(source)['root']}")
    return("http://" + URL_ROOT_REGEX.match(source)['root'] + href)
  else
    raise
  end
end

print("Enter full URL: ")
link = gets.chomp
source_link = link
good_page = Nokogiri::HTML(open(link))

# A good link can be parsed by Nokogiri and contains other links

while true
  sleep(0.1)
  while true
      link = good_page.xpath("//a").to_a.sample['href']

      begin
        tent_link = uri_link_builder(link, source_link)
        tentative_page = Nokogiri::HTML(open(tent_link))
      rescue
        puts("\e[31;1mBAD LINK - FAILURE:\e[0m #{link}")
        break
      end

      if tentative_page.xpath("//a").to_a.length == 0
        puts("\e[31;1mDEAD END - FAILURE:\e[0m #{link}")
        break
      else
        puts("\e[32;1mSUCCESS:\e[0m #{link}")
        good_page = tentative_page
        source_link = link
      end
  end
end
