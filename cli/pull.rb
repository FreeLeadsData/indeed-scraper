require 'simple_command_line_parser'
require 'simple_cloud_logging'
require 'blackstack-core'
require 'colorize'
require 'csv'
require 'freeleadsdata-api'
require_relative '../config.rb'

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

