require 'simple_command_line_parser'
require 'simple_cloud_logging'
require 'blackstack-core'
require 'colorize'
require 'csv'
require 'freeleadsdata-api'
require_relative '../config.rb'

# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command upload a list of companies to FreeLeadsData for enrichment.', 
  :configuration => [{
    :name=>'name', 
    :mandatory=>true, 
    :description=>'Name of the search(es) that will be created. Mandatory.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }, {
    :name=>'template', 
    :mandatory=>true, 
    :description=>'JSON file with the search template to add the list of companies. Mandatory.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }, {
    :name=>'files', 
    :mandatory=>false, 
    :description=>'Filter the files you want to process. Default: .*', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => '.*',
  }]
)

l = BlackStack::LocalLogger.new('push.log')
BATCH_SIZE = 100
cnames = []

# list all files into the csv folder with name matching with /#{PARSER.value('files')}/ 
l.logs "Loading files... "
files = Dir.glob('../csv/*.csv').select {|f| f =~ /#{parser.value('files')}/}
l.logf 'done'.green + " (#{files.count.to_s.blue} files found)"

files.each do |file|
    l.logs "Processing file #{file.blue}... "
    # read the file
    csv = CSV.read(file, :headers=>true)
    # iterate over the rows
    cnames += csv.map {|row| row[2].to_s.strip.downcase}
    l.logf 'done'.green + " (#{csv.count.to_s.blue} companies found)"
end

l.logs 'Total companies found: '
l.logf cnames.count.to_s.blue

# remove duplicates
l.logs "Removing duplicates... "
cnames = cnames.uniq
l.logf 'done'.green + " (#{cnames.count.to_s.blue} companies found)"

l.logs "Removing fake values... "
cnames = cnames.reject { |cname| cname.to_s.empty? }
cnames = cnames.reject { |cname| cname == 'company' }
l.logf 'done'.green + " (#{cnames.count.to_s.blue} companies found)"

l.logs "Sorting... "
cnames = cnames.sort
l.logf 'done'.green

l.logs 'Building batches... '
batches = cnames.each_slice(BATCH_SIZE).to_a
l.logf 'done'.green + " (#{batches.count.to_s.blue} batches found)"
