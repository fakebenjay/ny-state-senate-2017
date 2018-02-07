require 'open-uri'
require 'nokogiri'
require 'csv'
require 'pry'

## Rough scraper, had to update some elements manually

html = Nokogiri::HTML(open("https://en.wikipedia.org/wiki/New_York_Assembly"))

obj = {}

html.css("table")[3].children.each do |member|
  memtext = member.text.split("\n")
  next if memtext == [] || memtext[1] == "District" || memtext[2] == "Vacant"

  if memtext[2].split(" ")[-1] == "Rosenthal"
    if memtext[2] == "Linda Rosenthal"
      obj["ROSENTHAL L"] = {party: memtext[3], district: memtext[1], fullname: memtext[2]}
    else
      obj["ROSENTHAL D"] = {party: memtext[3], district: memtext[1], fullname: memtext[2]}
    end
  elsif memtext[2].split(" ")[-1] == "Miller"
    if memtext[2] == "Michael G. Miller"
      obj["MILLER MG"] = {party: memtext[3], district: memtext[1], fullname: memtext[2]}
    elsif memtext[2] == "Melissa Miller"
      obj["MILLER ML"] = {party: memtext[3], district: memtext[1], fullname: memtext[2]}
    else
      obj["MILLER B"] = {party: memtext[3], district: memtext[1], fullname: memtext[2]}
    end
  else
    obj[memtext[2].split(" ")[-1].upcase] = {party: memtext[3], district: memtext[1], fullname: memtext[2]}
  end
end

puts obj
