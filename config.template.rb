FREELEADSDATA_API_KEY = 'a9c089ef-****-****-****-********7f7e'

OPENAI_API_KEY = '****DDAIr'
MODEL_TO_USE = 'gpt-3.5-turbo-16k-0613'

# For scraping Indeed, we recommend to use StormProxies' Backconnect Rotating Proxies,
# 1 Access IP at $14/month.
# https://stormproxies.com/rotating_reverse_proxies.html
# 
PROXY = {
    :ip => 'xxx.xxx.xxx.xxx',
    :port_from => 4000,
    :port_to => 4000,
}

SEARCH_TEMPLATE = {
    #'name' => ,
    'status' => true,
    'stop_limit' => 400000000,
    'earning_per_verified_email' => 0.018,
    'verify_email' => false, # RECOMMENDED: Run pull.rb before verify results 
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