**THIS PROJECT IS UNDER CONSTRUCTION**

# indeed-scraper

[FreeLeadsData](https://freeleadsdata.com) Extensions to Scrape Indeed Searches and Push Results to [FreeLeadsData.com](https://freeleadsdata.com)

**Outline:**

1. [Setup Environment](#1-setup-environment)
2. [Installation](#2-installation)
3. [Indeed Scraping](#3-indeed-scraping)
4. [Results Submission](#4-results-submission)
5. [Enrichment Curation](#5-enrichment-curation)


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

Install required gems.

```bash
cd ~/code/indeed-scraper
bundler update
```


## 3. Indeed Scraping

_(pending)_


## 4. Results Submission

In the `./csv` folder of this project you place all the CSV files scraped in the previous section.

The process of setting up **FreeLeadsData** searches for enrich your list of companies is composed by 2 steps:

1. list curation, and
2. list submission.

**List Curation**

Usually you will want to:

1. join all the CSVs into one single **results-set**;
2. build a list with unique names of companies, removing duplications;
and
3. remove some fake company names (like `company` or `llc`).

**List Submission**

You split the **curated list of companies** into chunks of `N` company names each one, and you will create `M` searches.

The reason of such a splitting is because **FreeLeadsData** accept up to 100 company names per search.

**Running Sumission**

```ruby

```

## 5. Enrichment Curation

Since you splitted the list of companies in the previous section, you have to download the many **result-files** from FreeLeadsData and join the results.

_(pending)_
