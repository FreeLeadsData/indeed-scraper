require 'simple_command_line_parser'
require 'simple_cloud_logging'
require 'blackstack-core'
require 'colorize'
require 'csv'
require 'pry'
require "open-uri"
require 'freeleadsdata-api'
require_relative '../config.rb'

def download(url, id)
  f = URI.open(url)
  s = f.read
  o = File.open("/tmp/#{id}.csv", "wb")
  o.write(s)
  o.close
  f.close
end

# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command download all the exports from all the searches with a name like /#{id}/, remove duplicated (job-position, company-names), and append the job position listed at indeed.', 
  :configuration => [{
    :name=>'id', 
    :mandatory=>true, 
    :description=>'Label the searches we are running. Mandatory.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }]
)

l = BlackStack::LocalLogger.new('push.log')

l.log 'PULL FROM FREELEADSDATA'.yellow

l.logs 'ID: ' 
id = parser.value('id').to_s
l.logf id.blue

l.logs "Initializing variables... "
l.logf 'done'.green

# creating the client
l.logs "Creating the client... "
client = BlackStack::FreeLeadsData::API.new(FREELEADSDATA_API_KEY)
l.logf 'done'.green

# list all searches matching with 
l.logs "List all searches... "
ret = client.get("#{id} - ")
if ret['status'] != 'success'
  l.logf "Error: #{ret['success']}".red
  exit
end
a = ret['searches']
l.logf 'done'.green + " (#{a.size.to_s.blue} searches found)"
=begin
# download all the exports
l.logs "Downloading... "
a.each { |h|
  l.logs "#{h['id'].blue}... "
  url = h['export']['export_download_url']
  sid = h['id']
  download(url, sid)
  l.logf 'done'.green
}
l.logf 'done'.green
=end
# bundle all CSV files into one single array
l.logs "Bundling... "
b = []
a.each { |h|
  l.logs "#{h['id'].blue}... "
  sid = h['id']
  x = CSV.read("/tmp/#{sid}.csv").to_a
  x.shift # remove the header
  b += x
  l.logf 'done'.green
}
l.logf 'done'.green + " (#{b.size.to_s.blue} records found)"

l.logs "Finding duplicates... "
blacklist = b.select { |c| 
  fname = c[2]
  lname = c[3]
  title = c[5]
  cname = c[10]
  b.select { |d|
    title.strip.downcase == d[5].strip.downcase && 
    cname.strip.downcase == d[10].strip.downcase
  }.size > 1
}
l.logf 'done'.green + " (#{blacklist.size.to_s.blue} records found)"

l.logs "Removing duplicates... "
b = b - blacklist
l.logf 'done'.green + " (#{b.size.to_s.blue} records found)"