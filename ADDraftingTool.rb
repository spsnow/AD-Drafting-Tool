<<<<<<< HEAD
require 'nokogiri'
require 'rest-client'

# Retrieve ability statistics from DatDota
response = RestClient.get('https://ad.datdota.com/abilities')
document = Nokogiri::HTML.parse(response.body)

# Parse retrieved ability statistics.
parsed_ability_statistics = {}
ability_image_location_regex = /.*src="(.*)"><\/td>/

skipped_first_row = false
document.xpath("//tr").each do |row|
    if skipped_first_row == false
        skipped_first_row = true
        next
    end

    ability_image_location_data = row.xpath("td[1]")
    ability_name_data = row.xpath("td[2]")
    ability_win_rate_data = row.xpath("td[4]")
    
    parsed_ability_image_location = ability_image_location_data.to_s.match(/.*src="(.*)"><\/td>/)[1]
    parsed_ability_name = ability_name_data.to_s.match(/<td>.*">(.*)<\/a><\/td>/)[1]
    parsed_ability_win_rate = ability_win_rate_data.to_s.match(/<td.*">(.*)%<\/td>/)[1]

    parsed_ability_statistics[parsed_ability_name] = {
        name: parsed_ability_name,
        image_location: parsed_ability_image_location,
        win_rate: parsed_ability_win_rate
    }
end

puts parsed_ability_statistics
=======
puts "test"
puts "I can push"
>>>>>>> 41d200d210c714cafa4a83e02addbd21d64327c7
