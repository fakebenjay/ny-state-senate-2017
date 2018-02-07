require 'open-uri'
require 'nokogiri'
require 'csv'
require 'pry'
require_relative 'csv_methods'
require_relative 'members'

def assembly_hash
  obj = {}

  SharedVariables.assembly_list.keys.each do |member|
    blank_obj = {
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

    obj[member.upcase] = blank_obj
    obj[member.upcase][:district] = SharedVariables.assembly_list[member][:district].to_i
    obj[member.upcase][:party] = SharedVariables.assembly_list[member][:party]
    obj[member.upcase][:fullname] = SharedVariables.assembly_list[member][:fullname]
  end

  return obj
end

def add_assembly
  obj = assembly_hash
  killswitch = false
  page = 321

  directory = [:lost_stricken, :introduced, :committee, :floor_calendar, :assembly, :senate, :full_leg, :sent_to_gov, :vetoed, :signed, :not_law, :total]
  vacancies = ["GJONAJ", "KAVANAGH", "KEARNS", "MOYA", "GRAF", "LOPEZ", "LUPINACCI", "MCKEVITT", "MCLAUGHLIN", "SIMANOWITZ", "FARRELL", "SALADINO"]

  until killswitch == true do
    html = Nokogiri::HTML(open("https://www.nysenate.gov/search/legislation?searched=true&type=f_bill&bill_session_year=2017&page=#{page}"))
    bills = html.css('div.c-block')
    killswitch = true if bills.length == 0
    counter = 1

    # lastname = SharedVariables.assembly_list[member][:lastname].upcase
    # party = SharedVariables.assembly_list[member][:party]
    # district = SharedVariables.assembly_list[member][:district]

    bills.each do |b|
      next if b.children.css('h3.c-bill-num').text.strip.split(" ")[1].split("")[0] == "S"
      next if b.children.css('h3.c-bill-num').text.strip.split(" ")[1].split('A')[1].to_i >= 8884 && b.children.css('h3.c-bill-num').text.strip.split(" ")[1].split("")[0] ## arbitrary number, update if 2018 is a particularly prolific year in Albany

      ## Filters out everything not from calendar year 2017
      ## which for the 2017-18 session is any bill greater than A8883, excluding A40001

      lastname = b.children.css('p.c-bill-update--sponsor').text.strip.split(": ")[1]
      next if vacancies.include?(lastname)
      next if !lastname ##Annual budget doesn't have a sponsor

      lastname = "ROSENTHAL L" if lastname == "ROSENTHAL"

      ## Dan Rosenthal joined the assembly in Nov 2017
      ## Linda Rosenthal bills before that may be marked as "ROSENTHAL" instead of "ROSENTHAL L"

      obj[lastname][directory[bill(b)]] += 1
      obj[lastname][:total] += 1
      obj[lastname][:not_law] += 1 if bill(b) != 9
      puts "Bill #{counter} on page #{page}!"
      counter += 1
    end

    page += 1
  end

  CSV.open('senate_counts.csv', 'a+') do |csv|
    csv << [member, district, party, conference, obj[:lost_stricken], obj[:introduced], obj[:committee], obj[:floor_calendar], obj[:assembly], obj[:senate], obj[:full_leg], obj[:sent_to_gov], obj[:vetoed], obj[:signed], obj[:not_law], obj[:total]]
  end
end

csv_init("assembly")
add_assembly
