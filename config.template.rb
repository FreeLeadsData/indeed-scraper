FREELEADSDATA_API_KEY = 'a9c089ef-****-****-****-********7f7e'

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