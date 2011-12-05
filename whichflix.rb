require 'rubygems'
require 'sinatra'
require 'mechanize'

def netflix_search(title)
  results = ''
  agent = Mechanize.new
  page = agent.get('http://www.netflix.com/Search?v1='+title)
  results << '<table>'
  page.search('.//div[@class="agMovie"]').each do |result|
    if result.at('.//img[@class="boxShotImg"]//@src')
      results << '<tr><td><a href="' + result.search('.//a[@class="mdpLink"]//@href').text + '"><img src="'+result.search('.//img[@class="boxShotImg"]//@src').text+'"></a></td>'
    else
      results << '<tr><td><a href="' + result.search('.//a[@class="mdpLink"]//@href').text + '"><img src="no-image.png"></a></td>'
    end
    results << '<td><a href="' + result.search('.//a[@class="mdpLink"]//@href').text + '">' + result.search('.//a[@class="mdpLink"]').text + '</a>'
    if result.at('.//dl[@class="availFormats"]//dd')
      results << '<div class="format">' + result.search('.//dl[@class="availFormats"]//dd').text + '</div></td></tr>'
    else
      results << '<div class="format">DVD</div></td></tr>'
    end
  end
  results << '</table>'
  return results
end

def amazon_search(title)
  titles = []
  links = []
  images = []
  prices = []
  results = ''
  agent = Mechanize.new
  page = agent.get('http://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Dinstant-video&field-keywords='+title)
  page.search('.//div[@class="data"]//a[@class="title"]').each do |result|
    titles << result.text
  end
  page.search('.//div[@class="data"]//a[@class="title"]//@href').each do |result|
    links << result.text
  end
  page.search('img[@class="productImage"]//@src').each do |result|
    images << result.text
  end
  i = 0
  page.search('.//div[@class="mvOneCol"]//div[@class="indent"]//div[@class="priceListFirstSet"]').each do |result|
    if result.at('.//span[@class="primeHelp"]')
      prices << i
    end
    i += 1
  end
  results << '<table>'
  for i in (0..titles.length-1)
    results << '<tr>'
    if not images[i].nil?
      results << '<td><a href="' + links[i] + '"><img src="' + images[i] + '"></a></td>'
    end
    if not titles[i].nil?
      results << '<td><a href="' + links[i] + '">' + titles[i] + "</a>"
    end
    if prices.include?(i)
      results << '<div class="format">Prime</div></td>'
    else
      results << '</td>'
    end
    results << '</tr>'
  end
  results << '</table>'
  return results
end

get '/' do
  erb :index
end

post '/' do
  film = params[:film]
  erb :search,
  :locals => {:netflix => netflix_search(film),
              :amazon => amazon_search(film),
              }
end