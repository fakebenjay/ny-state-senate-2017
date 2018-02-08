require 'csv'

def csv_init(chamber)
  if chamber == "senate"
    CSV.open("senate_counts.csv", 'wb') do |csv|
      csv << ['senator', 'district', 'party', 'conference', 'lost_stricken', 'introduced', 'committee', 'floor_calendar', 'assembly', 'senate', 'full_leg', 'sent_to_gov', 'vetoed', 'signed', 'not_law', 'total']
    end
  elsif chamber == "assembly"
    CSV.open("assembly_counts.csv", 'wb') do |csv|
      csv << ['member', 'district', 'party', 'lost_stricken', 'introduced', 'committee', 'floor_calendar', 'assembly', 'senate', 'full_leg', 'sent_to_gov', 'vetoed', 'signed', 'not_law', 'total']
    end
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
