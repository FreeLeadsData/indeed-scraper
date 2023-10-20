require 'bots'

l = BlackStack::LocalLogger.new('./indeed1.log')

puts "\n\nEXAMPLE 1".blue
puts "Find domain of a company using Google Search API.\nCount the number of 'not-found' and 'error' cases.\n".yellow

l.logs 'initialize GoogleBot... '
bot = BlackStack::Bots::Indeed.new(proxy: nil)
l.done

a = [
    {
        output_filename: 'indeed03',
        search: "https://www.indeed.com/jobs?q=full+time&l=Medford%2C+OR&radius=35&vjk=5f70c02d46c70c65",
    }, {
        output_filename: 'indeed04',
        search: "https://www.indeed.com/q-full-time-$50,000-l-Charleston,-SC-jobs.html?vjk=d66cee732eb0d03b",
    }, {
        output_filename: 'indeed05',
        search: "https://www.indeed.com/jobs?q=full+time+%2450%2C000&l=Raleigh-Durham%2C+NC&vjk=67ca1a2862f9fa28",
    }, {
        output_filename: 'indeed06',
        search: "https://www.indeed.com/jobs?q=full+time+%2450%2C000&l=Reno%2C+NV&vjk=bbe66fed429fcf4b",
    },
] 

a.each { |h|
    output_filename = h[:output_filename]
    search = h[:search]
    start = 0
    while start <= 640
        l.logs "start=#{start}... "
        begin
            url = "#{search}&start=#{start}"
            ret = bot.results(url)
            # save ret into a json file
            #File.open("./#{output_filename}.start-#{start.to_s}.json", 'w') { |f| f.write(ret.to_json) }
            # save into a CSV file
            CSV.open("./#{output_filename}.all.csv", 'a+b') { |csv|
                csv << ['title', 'url', 'company', 'location', 'salary', 'posted', 'snippets']
                ret.each { |h|
                    csv << [h[:title], h[:url], h[:company], h[:location], h[:salary], h[:posted], h[:snippets].join(' / ')]
                }        
            }
            l.done
        rescue => e
            l.logf "error: #{e.message}".red
        end
        # increase start
        start += 10
    end
}