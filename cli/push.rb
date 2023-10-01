require 'simple_cloud_logging'
require 'blackstack-core'

# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command upload a list of companies to FreeLeadsData for enrichment.', 
  :configuration => [{
    :name=>'name', 
    :mandatory=>true, 
    :description=>'Name of the search(es) that will be created. Mandatory.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }, {
    :name=>'filter', 
    :mandatory=>false, 
    :description=>'Filter the files you want to process. Default: .*', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => '.*',
  }]
)

l = BlackStack::LocalLogger.new('push.log')

# list all files into the csv folder with name matching with /#{PARSER.value('filter')}/ 
files = Dir.glob('./csv/*.csv').select {|f| f =~ /#{parser.value('filter')}/}
binding.pry

