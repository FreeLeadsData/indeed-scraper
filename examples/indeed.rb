# This example takes an Indeed page and parse it.

require 'nokogiri'
require 'colorize'
require 'simple_cloud_logging'
require 'pry'

l = BlackStack::LocalLogger.new('indeed.log')
filename = 'data/St. Petersburg-410.html'

# load html
l.logs "Loading #{filename.to_s.blue}... "
nokogiri = Nokogiri::HTML(File.open(filename))
l.logf 'done'.green

# get title
l.logs "Getting title... "
title = nokogiri.css('title').text
l.logf 'done'.green + " (#{title.to_s.blue})"

# get the unique ul child of the div with id="mosaic-provider-jobcards"
l.logs "Getting posts... "
posts = nokogiri.css('div#mosaic-provider-jobcards > ul > li')
l.logf 'done'.green + " (#{posts.length.to_s.blue} posts)"

a = []
i = 0
posts.each { |li|
    i += 1

    l.logs "Parsing post #{i.to_s.blue}... "
    links = li.css('a.jcs-JobTitle')
    if links.size != 1
        l.logf 'skipped'.yellow
    else
        h = {}
        link = links.first
        h[:title] = link.text
        h[:url] = link[:href]

        o = li.css('span.companyName').first
        o = li.css( '[data-testid="company-name"]').first unless o
        h[:company] = o ? o.text : ''

        o = li.css('div.companyLocation').first
        o = li.css( '[data-testid="text-location"]').first unless o
        h[:location] = o ? o.text.split('}').last : ''
        
        o = li.css('div.salary-snippet-container').first
        h[:salary] = o ? o.text : ''
        
        o = li.css('span.date').first
        h[:posted] = o ? o.text.gsub("Posted\nPosted", '').strip : ''
        
        h[:snippets] = li.css('div.job-snippet > ul > li').map { |li| li.text }

        a << h

        l.logf 'done'.green
    end
} # posts.each

# print results
l.log "Results: #{a.size.to_s.blue}"