require 'open-uri'
require 'nokogiri'
require 'csv'
require 'pry'
require_relative 'senators'

binding.pry

def csv_init
  CSV.open('senate.csv', 'wb') do |csv|
    csv << ['senator', 'party', 'bill', 'description', 'date', 'status', 'statuscode', 'islaw']
  end
end

def is_law?(text)
  if text == "Signed by Governor"
    return "Yes"
  else
    return "No"
  end
end

def parse_bills(array)
  array.each do |b|
    binding.pry
    bill = array[array.index(b)].children.css('h3.c-bill-num').text.strip.gsub("Bill", "").gsub(" ", "")
    description = array[array.index(b)].children.css('p.c-bill-descript').text.strip
    date = array[array.index(b)].children.css('p.c-bill-update--date').text.split("|")[0].strip.gsub("  ", "")
    status = array[array.index(b)].children.css('p.c-bill-update--date').text.split("|")[1].strip.gsub("  ", "")
    islaw = is_law?(status)
  end
end

def add_senator(senator)
  page = 1
  binding.pry
  senator_code = SharedVariables.senators_list[senator][:id]
  party = SharedVariables.senators_list[senator][:party]
  conference = SharedVariables.senators_list[senator][:conference]
  district = SharedVariables.senators_list[senator][:district]
  html = Nokogiri::HTML(open("https://www.nysenate.gov/search/legislation?sort=asc&type=f_bill&searched=true&bill_printno=&bill_session_year=2017&bill_sponsor=#{senator_code}&bill_status=&bill_committee=&bill_text=&bill_issue=&resolution_printno=&resolution_text=&resolution_sponsor=&resolution_session_year=&calendar_month=&calendar_year=2018&agenda_month=&agenda_year=2018&agenda_committee=&session_trans_month=&session_trans_year=2018&session_trans_text=&hearing_trans_month=&hearing_trans_year=2017&hearing_trans_text=&page=#{page}"))

  bills = html.css('div.c-block')

  parse_bills(bills)

  CSV.open('senate.csv', 'a+') do |csv|
    csv << ['senator', 'party', 'bill', 'description', 'date', 'status', 'statuscode', 'islaw']
  end
end

add_senator("Jeffrey D. Klein")
