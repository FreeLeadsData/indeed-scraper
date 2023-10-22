require 'simple_command_line_parser'
require 'simple_cloud_logging'
require 'blackstack-core'
require 'colorize'
require 'csv'
require 'pry'
require "open-uri"
require "openai"
require 'freeleadsdata-api'
require_relative '../config.rb'

OPENAI_CLIENT = OpenAI::Client.new(access_token: OPENAI_API_KEY)

def download(url, id)
  f = URI.open(url)
  s = f.read
  o = File.open("/tmp/#{id}.csv", "wb")
  o.write(s)
  o.close
  f.close
end

def openai(title)
  prompt = "Return string with 2 to 4 words that I can use to personalize a sentence like 'I saw you are looking for a (job title)'. The merge-tag must looks natural in the sentence. Just return the job title. Don't write the whole sentence. If many many titles are listed choose only one: #{title}"
  ret = OPENAI_CLIENT.chat(
      parameters: {
          model: OPENAI_MODEL, # Required.
          temperature: 0.5,
          messages: [
              { role: "user", content: prompt},
          ], # Required.
      }
  )
  ret['choices'][0]['message']['content']
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

l.logs "Finding redundancies... "
blacklist = b.select { |c| 
  fname = c[2]
  lname = c[3]
  title = c[5]
  cname = c[10]
  b.select { |d|
    # diffrent names
    (
      fname.strip.downcase != d[2].strip.downcase ||
      lname.strip.downcase != d[3].strip.downcase
    ) &&
    # but same title and company name
    title.strip.downcase == d[5].strip.downcase && 
    cname.strip.downcase == d[10].strip.downcase
  }.size > 1
}
b = b - blacklist
l.logf 'done'.green + " (#{b.size.to_s.blue} records found)"

#l.logs "Removing duplications... "
#y = b.map { |c| c[2].strip.downcase+c[3].strip.downcase+c[10].strip.downcase }.uniq
#l.logf 'done'.green + " (#{b.size.to_s.blue} records found - #{y.size.to_s.blue} unique records)"

l.logs "Appending indeed job position... "
i = 0
b.each { |c|
  i += 1
break if i > 10
  fname = c[2]
  lname = c[3]
  title = c[5]
  cname = c[10]
  l.logs "#{i.to_s.blue}. #{fname.blue} #{lname.blue} - #{title.blue} @ #{cname.blue}... "
  files = Dir.glob("../csv/*#{id}.csv")
  files.each { |f|
      # get all lines with company name
      mergetag = nil
      jobtitle = nil
      jobpost = nil
      csv = CSV.parse(File.read(f), headers: true)
      d = csv.select { |row| row.to_s.downcase.include?(cname.to_s.downcase) }
      d.each { |row|
          jobpost = row[1]
          jobtitle = row[0]
          mergetag = openai(jobtitle)
          # update
          #ai_processed_title = mergetag
          #full_indeed_title = jobtitle
          #indeed_post_url = jobpost
          c << mergetag
          c << jobtitle
          c << jobpost
          #
          break
      }
      break if jobtitle && mergetag
  } # files.each
  l.logf 'done'.green + " (#{c[-2].blue} - #{c[-3].blue})"
}

# store the results into a CSV file
l.logs "Storing results... "
CSV.open("../out/#{id}.csv", "wb") do |csv|
  csv << b
end
l.logf 'done'.green