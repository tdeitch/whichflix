require 'rubygems'
require 'sinatra'
require 'mechanize'

def netflix_search(title)
  results = ''
  agent = Mechanize.new
  page = agent.get('http://www.netflix.com/Search?v1='+title)
  link = './/a[@class="mdpLink"]//@href'
  image = './/img[@class="boxShotImg"]//@src'
  title = './/a[@class="mdpLink"]'
  format = './/dl[@class="availFormats"]//dd'
  results << '<table>'
  page.search('.//div[@class="agMovie"]').each do |result|
    if result.at(image)
      results << '<tr><td><a href="' + result.search(link).text + '"><img src="'+result.search(image).text+'"></a></td>'
    else
      results << '<tr><td><a href="' + result.search(link).text + '"><img src="no-image.png"></a></td>'
    end
    results << '<td><a href="' + result.search(link).text + '">' + result.search(title).text + '</a>'
    if result.at(format)
      results << '<div class="format">' + result.search(format).text + '</div></td></tr>'
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
  link = './/div[@class="data"]//a[@class="title"]//@href'
  image = 'img[@class="productImage"]//@src'
  title = './/div[@class="data"]//a[@class="title"]'
  format = './/div[@class="mvOneCol"]//div[@class="indent"]//div[@class="priceListFirstSet"]'
  page.search(title).each do |result|
    titles << result.text
  end
  page.search(link).each do |result|
    links << result.text
  end
  page.search(image).each do |result|
    images << result.text
  end
  i = 0
  page.search(format).each do |result|
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

def hulu_search(title)
  results = ''
  agent = Mechanize.new
  page = agent.get('http://www.hulu.com/search?query=site%3Ahulu+'+title)
  link = './/div[@class="home-play-container relative"]//span[@class="play-button-hover"]//a//@href'
  image = './/div[@class="home-play-container relative"]//span[@class="play-button-hover"]//a//img[@class="thumbnail"]//@src'
  title = './/div[@class="show-title-container"]//a[@class="show-title-gray info_hover beaconid beacontype"]'
  format = './/span[@style="white-space: nowrap;"]'
  results << '<table>'
  page.search('div[@class="home-thumb"]').each do |result|
    if result.at(title)
      if result.at(image)
        results << '<tr><td><a href="' + result.search(link).text + '"><img src="'+result.search(image).text+'"></a></td>'
      else
        results << '<tr><td><a href="' + result.search(link).text + '"><img src="no-image.png"></a></td>'
      end
      results << '<td><a href="' + result.search(link).text + '">' + result.search(title).text + '</a>'
      results << '<div class="format">' + result.search(format).text + '</div></td></tr>'
    end
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
              :hulu => hulu_search(film)
              }
end