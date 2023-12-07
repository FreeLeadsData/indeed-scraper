# Testing Zyte.com for scraping jobs

require 'uri'
require 'net/http'
require 'json'
require 'pry'
require 'blackstack-core'
require 'simple_cloud_logging'
require 'colorize'
require_relative './searches.rb'
require_relative './config.rb' # ZAITE_API_KEY is in this file - see above

# NOTES:
# Install the following packages:
#
# - sudo apt install jq
# - sudo apt install curl
# 
# Zyte Pricing:
# - https://www.zyte.com/pricing/
# - 10 Indeed searches = 640 pages ~= 0.25$
#
# Zyte API:
# - https://docs.zyte.com/zyte-api/usage/http.html
# 


l = BlackStack::LocalLogger.new('zyte.log')

def zyte(url)
    input = "{
        \"url\": \"#{url}\",
        \"httpResponseBody\": true
    }
    "

    File.open('input.json', 'w') { |file| file.write(input) }

    ret = `curl \
    --silent \
    --user #{ZAITE_API_KEY}: \
    --header 'Content-Type: application/json' \
    --data @input.json \
    --compressed \
    https://api.zyte.com/v1/extract \
    | jq --raw-output .httpResponseBody \
    | base64 --decode \
    `

    return ret
end

MAX = 640
SEARCHES.each { |h|
    i = 0
    while i<=MAX
        s = ("%03d" % i).to_s
        l.logs "Scraping #{h[:name].blue} #{s.blue}... "
        name = h[:name]
        url = h[:url]
        html = zyte(url)
        File.open("data/#{name}-#{s}.html", 'w') { |file| file.write(html) }
        i += 10
        l.logf "done".green
    end # while
}
  
 