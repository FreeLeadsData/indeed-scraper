# Testing Zyte.com for scraping jobs

require 'uri'
require 'net/http'
require 'json'
require 'pry'
require 'blackstack-core'

def zyte(url)
    ret = `curl \
    --user xxxxxxxxxxxxxxxxxxxxxx: \
    --header 'Content-Type: application/json' \
    --data '{ 
    "url": "#{url}",
    "browserHtml": true
    }' \
    --compressed "https://api.zyte.com/v1/extract"`.to_s
    # return
    ret
end

url = 'https://www.indeed.com/jobs?q=%2435%2C000&l=Jacksonville%2C+FL&radius=25&vjk=4d50a7da37ac13e8?start=60'
puts zyte(url)
  
 