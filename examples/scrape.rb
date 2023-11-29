#require 'bots'
require_relative '../../../bots/lib/bots.rb'

require 'pry'
require 'simple_command_line_parser'
require 'simple_cloud_logging'
require 'blackstack-core'
require 'colorize'
require 'csv'
require_relative '../config.rb'

l = BlackStack::LocalLogger.new('scrape.log')

#url = 'https://www.indeed.com/q-$40,000-l-Hollywood,-FL-jobs.html' # => currenct URL
url = 'https://www.indeed.com/q-$40,000-l-The-Acreage,-FL-jobs.html' # => failed URL

l.log 'INDEED SCRAPER'.yellow

l.logs 'initialize IndeedBot... '
bot = BlackStack::Bots::Indeed.new(PROXY)
l.logf 'done'.green

l.logs "Scraping: #{url.to_s.blue}... "
ret = bot.results(url)
l.logf 'done'.green + " (#{ret.length.to_s.blue} results)"

#puts
#l.log ret.to_s