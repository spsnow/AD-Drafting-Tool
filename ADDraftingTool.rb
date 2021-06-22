require 'erb'
require 'json'
require 'nokogiri'
require 'rest-client'

# Retrieves and parses ability statistics from DatDota.
# 
# Returns a Hash with entries of the form: 
# "Warcry" => { :name => "Warcry", :image_location => "https://cdn.datdota.com/images/ability/sven_warcry.png", :win_rate => "48.56" }
def retrieve_ability_statistics
    # Retrieve ability statistics.
    response = RestClient.get('https://ad.datdota.com/abilities')
    document = Nokogiri::HTML.parse(response.body)

    # Parse retrieved ability statistics.
    parsed_ability_statistics = {}

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
        parsed_ability_name = ability_name_data.to_s.gsub(/'/, "").match(/<td>.*">(.*)<\/a><\/td>/)[1]
        parsed_ability_win_rate = ability_win_rate_data.to_s.match(/<td.*">(.*)%<\/td>/)[1].to_f

        parsed_ability_statistics[parsed_ability_name] = {
            name: parsed_ability_name,
            image_location: parsed_ability_image_location,
            win_rate: parsed_ability_win_rate
        }
    end

    return parsed_ability_statistics
end

# Retrieves and parses ability pair statistics from DatDota.
#
# Returns an Array containing Hashes of the form:
# { :ability_one_name => "Juxtapose", :ability_two_name => "Curse of Avernus", :win_rate => "57.90" }
def retrieve_ability_pair_statistics
    # Retrieve ability pair statistics.
    response = RestClient.get('https://ad.datdota.com/ability-pairs')
    document = Nokogiri::HTML.parse(response.body)

    # Prase retrieved ability pair statistics.
    parsed_ability_pair_statistics = []
    
    rows_to_skip = 2
    document.xpath("//tr").each do |row|
        if rows_to_skip > 0
            rows_to_skip -= 1
            next
        end

        ability_one_name_data = row.xpath("td[2]")
        ability_two_name_data = row.xpath("td[5]")
        ability_pair_win_rate_data = row.xpath("td[8]")

        parsed_ability_one_name = ability_one_name_data.to_s.gsub(/[\n']/, "").match(/<td>(.*)<\/td>/)[1]
        parsed_ability_two_name = ability_two_name_data.to_s.gsub(/[\n']/, "").match(/<td>(.*)<\/td>/)[1]
        parsed_ability_pair_win_rate = ability_pair_win_rate_data.to_s.gsub(/\n/, "").match(/<td.*">(.*)%<\/td>/)[1].to_f

        parsed_ability_pair_statistics.push({
            ability_one_name: parsed_ability_one_name,
            ability_two_name: parsed_ability_two_name,
            win_rate: parsed_ability_pair_win_rate
        })
    end

    return parsed_ability_pair_statistics
end

# Generates the interactive HTML file to be used by the user during AD draft.
def generate_webpage(abilities_on_board, ability_statistics, ability_pair_statistics)
    output_filename = "ADWebpage.html"
    output_filepath = "#{__dir__}/#{output_filename}"
    
    File.delete(output_filepath) if File.exist?(output_filepath) 

    erb = ERB.new(File.open("#{__dir__}/ADWebpageTemplate.html.erb").read)

    template_variables = binding
    template_variables.local_variable_set(:abilities_on_board, abilities_on_board)
    template_variables.local_variable_set(:ability_statistics, ability_statistics)
    template_variables.local_variable_set(:ability_pair_statistics, ability_pair_statistics)

    File.write(output_filepath, erb.result(template_variables))
end

# TODO: Replace with OpenCV code that retrieves the player's starting position and the abilities on the draft board.
# For now this has example data for webpage development.
abilities_on_board = {
    ultimates: ["Mystic Flare", "Coup de Grace", "Life Drain", "Assassinate", "Reincarnation", "Magnetize", "Solar Guardian", "Astral Step",  "Nether Strike", "Spirit Form", "Sunder", "Life Break"],
    spells: [
        "Arcane Bolt", "Concussive Shot", "Ancient Seal",
        "Boulder Smash", "Rolling Boulder", "Mist Coil",
        "Stifling Dagger", "Blink Strike", "Blur",
        "Wraithfire Blast", "Vampiric Spirit", "Mortal Strike",
        "Nether Blast", "Decrepify", "Nether Ward",
        "Shrapnel", "Headshot", "Take Aim",
        "Starbreaker", "Celestial Hammer", "Luminosity",
        "Inner Fire", "Burning Spear", "Berserkers Blood",
        "Aether Remnant", "Dissimilate", "Resonant Pulse",
        "Reflection", "Conjure Image", "Metamorphosis",
        "Charge of Darkness", "Bulldoze", "Greater Bash",
        "Illuminate", "Solar Bind", "Chakra Magic"
    ]
}

ability_statistics = retrieve_ability_statistics
ability_pair_statistics = retrieve_ability_pair_statistics
generate_webpage(abilities_on_board, ability_statistics, ability_pair_statistics)