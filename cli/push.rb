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
  #}, {
  #  :name=>'template', 
  #  :mandatory=>true, 
  #  :description=>'JSON file with the search template to add the list of companies. Mandatory.', 
  #  :type=>BlackStack::SimpleCommandLineParser::STRING,
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
templ = {
  #'name' => ,
  'status' => true,
  'stop_limit' => 400000000,
  'earning_per_verified_email' => 0.018,
  'verify_email' => true, 
  'direct_phone_number_only' => false,
  'auto_drain' => true,
  'keywords' => [
      # keywords to include
      { 'value' => '[company_name]', 'type' => 0 },
  ],
  'job_titles' => [
      # job positions to include
      { 'value' => 'Owner', 'positive' => true },
      { 'value' => 'CEO', 'positive' => true },
      { 'value' => 'Founder', 'positive' => true },
      { 'value' => 'President', 'positive' => true },
      { 'value' => 'Director', 'positive' => true },
      { 'value' => 'Human Resources Manager', 'positive' => true },
      { 'value' => 'HR Manager', 'positive' => true },
      { 'value' => 'Recruiting Manager', 'positive' => true },
      # job positions to exclude
      { 'value' => 'Vice', 'positive' => false },
    ],
  #'states' => [
  #    # locations to include
  #    { 'value' => 'NC', 'positive' => true }, # North Carolina
  #],
  'company_headcounts' => [
      # headcounts to include
      { 'value' => '1 to 10', 'positive' => true },
      { 'value' => '11 to 25', 'positive' => true },
      { 'value' => '26 to 50', 'positive' => true },
  ],
}

# creating the client
l.logs "Creating the client... "
client = BlackStack::FreeLeadsData::API.new(FREELEADSDATA_API_KEY)
l.logf 'done'.green

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

batches.each_with_index do |batch, i|
  l.logs "Uploading batch #{i}... "
  h = templ.clone
  name = "#{parser.value('name')} - #{batch.size} companies - #{i+1}/#{batches.count}"
  ret = client.get(name)
  if ret['status'] != 'success'
    l.logf "error: #{ret['status']}".red
  elsif [5,10].include?(i) == false
    l.logf 'skipped'.yellow
  elsif ret['searches'].size > 0
    l.logf 'already exists'.yellow
  else
    h['name'] = name
    h['company_names'] = batch.map { |s| { 'value' => s, 'positive' => true } }
    client.new(h)
    l.logf 'done'.green
  end
end