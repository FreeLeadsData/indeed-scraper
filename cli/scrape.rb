#require 'bots'
require_relative '../../../bots/lib/bots.rb'

require 'pry'
require 'simple_command_line_parser'
require 'simple_cloud_logging'
require 'blackstack-core'
require 'colorize'
require 'csv'
require_relative '../config.rb'

# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command scrapes Indeed searches and place the job-postings in the file /csv/#{id}.csv.', 
  :configuration => [{
    :name=>'id', 
    :mandatory=>true, 
    :description=>'Label the searches we are running. Mandatory.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }]
)

l = BlackStack::LocalLogger.new('scrape.log')

l.log 'INDEED SCRAPER'.yellow

l.logs 'ID: ' 
id = parser.value('id').to_s
output_filename = "../csv/#{id}.csv"
l.logf id.blue

l.logs 'initialize IndeedBot... '
bot = BlackStack::Bots::Indeed.new(nil)
l.logf 'done'.green

# load urls from ../urls/#{id}.txt
l.logs 'Load URLs... '
a = File.readlines("../urls/#{id}.txt").map { |line| line.strip }
l.logf 'done'.green + " (#{a.length.to_s.blue} URLs)"

a.each { |s|
    l.logs "searching: #{s.to_s.blue}... "
    search = s
    start = 0
    while start <= 640
        l.logs "start=#{start}... "
        begin
            url = "#{search}&start=#{start}"
            ret = bot.results(url)
            CSV.open("./#{output_filename}", 'a+b') { |csv|
                csv << ['title', 'url', 'company', 'location', 'salary', 'posted', 'snippets']
                ret.each { |h|
                    csv << [h[:title], h[:url], h[:company], h[:location], h[:salary], h[:posted], h[:snippets].join(' / ')]
                }        
            }
            l.logf 'done'.green + " (#{ret.length.to_s.blue} results)"
        rescue => e
            l.logf "error: #{e.message}".red
        end
        # increase start
        start += 10
    end
    l.logf 'done'.green
}
