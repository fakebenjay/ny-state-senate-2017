require 'open-uri'
require 'nokogiri'
require 'csv'
require 'pry'
require_relative 'senators'

def csv_init
  CSV.open('senate_counts.csv', 'wb') do |csv|
    csv << ['senator', 'district', 'party', 'conference', 'lost_stricken', 'introduced', 'committee', 'floor_calendar', 'assembly', 'senate', 'full_leg', 'sent_to_gov', 'vetoed', 'signed', 'not_law', 'total']
  end
end

def bill(bill)
  stages = bill.css('ul.nys-bill-status__sml')[0].children.css('li')

  ## Array positions correspond to the "lights" on the legislative process element
  ## stages[4] is the Senate, stages[5] is the assembly

  if stages[7].attr('class') == 'passed'
    return 9 if stages[7].text.strip == "Signed by Governor"
    return 8 if stages[7].text.strip == "Vetoed by Governor"
  elsif stages[6].attr('class') == 'passed'
    return 7
  elsif stages[5].attr('class') == 'passed' && stages[4].attr('class') == 'passed'
    return 6
  elsif stages[5].attr('class') == 'passed'
    return 4
  elsif stages[4].attr('class') == 'passed'
    return 5
  elsif stages[2].attr('class') == 'passed'
    return 3
  elsif stages[1].attr('class') == 'passed'
    return 2
  elsif stages[0].attr('class') == 'passed'
    return 1
  else
    return 0
  end
end

def add_senator(senator)
  page = 1
  senator_code = SharedVariables.senators_list[senator][:id]
  party = SharedVariables.senators_list[senator][:party]
  conference = SharedVariables.senators_list[senator][:conference]
  district = SharedVariables.senators_list[senator][:district]
  killswitch = false

  directory = [:lost_stricken, :introduced, :committee, :floor_calendar, :assembly, :senate, :full_leg, :sent_to_gov, :vetoed, :signed, :not_law, :total]

  obj = {
    lost_stricken: 0,
    introduced: 0,
    committee: 0,
    floor_calendar: 0,
    assembly: 0,
    senate: 0,
    full_leg: 0,
    sent_to_gov: 0,
    vetoed: 0,
    signed: 0,
    not_law: 0,
    total: 0
  }

  until killswitch == true do
    html = Nokogiri::HTML(open("https://www.nysenate.gov/search/legislation?searched=true&type=f_bill&bill_session_year=2017&bill_sponsor=#{senator_code}&page=#{page}"))
    bills = html.css('div.c-block')
    killswitch = true if bills.length == 0

    bills.each do |b|
      next if b.children.css('h3.c-bill-num').text.strip.split(" ")[1].split('S')[1].to_i >= 7000
      ## next if b.children.css('p.c-bill-update--date').text.split("|")[0].strip.split(',')[1].strip.gsub("  ", "") != "2017"

      ## Filters out everything not from calendar year 2017
      ## which for the 2017-18 session is any bill greater than/equal to S7000

      obj[directory[bill(b)]] += 1
      obj[:total] += 1
      obj[:not_law] += 1 if bill(b) != 9
    end

    page += 1
  end

  CSV.open('senate_counts.csv', 'a+') do |csv|
    csv << [senator, district, party, conference, obj[:lost_stricken], obj[:introduced], obj[:committee], obj[:floor_calendar], obj[:assembly], obj[:senate], obj[:full_leg], obj[:sent_to_gov], obj[:vetoed], obj[:signed], obj[:not_law], obj[:total]]
  end
end

def populator
  SharedVariables.senators_list.keys.each do |senator|
    add_senator(senator)
    puts "#{senator}, #{Time.now}"
  end
end

csv_init
populator
