# indeed-scraper

[FreeLeadsData](https://freeleadsdata.com) Extensions to Scrape Indeed Searches and Push Results to [FreeLeadsData.com](https://freeleadsdata.com)

**Outline:**

1. [Setup Environment](#1-setup-environment)
2. [Installation](#2-installation)
3. [Indeed Scraping](#3-indeed-scraping)
4. [Results Submission](#4-results-submission)

## 1. Setup Environment

MySaaS has been developed and tested on the following environment:
- Ubuntu 20.04
- Ruby 3.1.2
- Bundler 2.3.7

The command below install such an environment in your computer.

```bash
wget https://raw.githubusercontent.com/leandrosardi/my.saas/main/cli/install.sh
bash --login install.sh
```

You need the `--login` parameter for running RVM and Ruby, as is explained [here](https://stackoverflow.com/questions/9336596/rvm-installation-not-working-rvm-is-not-a-function).


## 2. Installation

Clone this project.

```bash
mkdir -p ~/code
cd code
git clone https://github.com/freeleadsdata/indeed-scraper
```

Install required gems

```bash
cd ~/code/indeed-scraper
bundler update
```

## 3. Indeed Scraping



