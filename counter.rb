require 'open-uri'
require 'nokogiri'
require 'csv'
require 'pry'
require_relative 'senators'

def csv_init
  CSV.open('senate_counts.csv', 'wb') do |csv|
    csv << ['senator', 'party', 'conference', 'district', 'lost_stricken', 'committee', 'floor_calendar', 'assembly', 'senate', 'full_leg', 'sent_to_gov', 'vetoed', 'signed', 'total']
  end
end

def bill(bill)
  stages = bill.css('ul.nys-bill-status__sml')[0].children.css('li')

  if stages[7].attr('class') == 'passed'
    return 7 if stages[7].text.strip == "Signed by Governor"
    return 8 if stages[7].text.strip == "Vetoed by Governor"
  elsif stages[6].attr('class') == 'passed'
    return 6
  elsif stages[5].attr('class') == 'passed' && stages[4].attr('class') == 'passed'
    return 3
  elsif stages[5].attr('class') == 'passed'
    return 5
  elsif stages[4].attr('class') == 'passed'
    return 4
  elsif stages[2].attr('class') == 'passed'
    return 2
  elsif stages[1].attr('class') == 'passed'
    return 1
  elsif stages[0].attr('class') == 'passed'
    return 0
  else
    return -1
  end
end

def parse_bills(array)
  obj = {
    lost_stricken: 0,
    committee: 0,
    floor_calendar: 0,
    assembly: 0,
    senate: 0,
    sent_to_gov: 0,
    vetoed: 0,
    signed: 0,
    total: 0
  }

  array.each do |b|
    bill(b)
  end
end

def add_senator(senator)
  page = 1
  senator_code = SharedVariables.senators_list[senator][:id]
  party = SharedVariables.senators_list[senator][:party]
  conference = SharedVariables.senators_list[senator][:conference]
  district = SharedVariables.senators_list[senator][:district]
  html = Nokogiri::HTML(open("https://www.nysenate.gov/search/legislation?searched=true&type=f_bill&bill_session_year=2017&bill_sponsor=#{senator_code}&page=#{page}"))
  bills = html.css('div.c-block')

  parse_bills(bills)

  CSV.open('senate.csv', 'a+') do |csv|
    csv << ['senator', 'party', 'bill', 'description', 'date', 'status', 'statuscode', 'islaw']
  end
end

csv_init
add_senator("Kenneth P. LaValle")
