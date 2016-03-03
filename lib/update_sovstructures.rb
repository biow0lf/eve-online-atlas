module UpdateSovStructures
  def self.update_sovstructures
    include HTTParty

    # remove old stations
    SovStructure.delete_all

    result = HTTParty.get('https://public-crest.eveonline.com/sovereignty/structures/')
    json = JSON.parse(result)

    structures = []

    json['items'].each_with_index do |_sys, idx|
      structures << SovStructure.new(solarSystemID: json['items'][idx]['solarSystem']['id'].to_i, allianceID: json['items'][idx]['alliance']['id'].to_s, occupancyLevel: json['items'][idx]['vulnerabilityOccupancyLevel'].to_f, structureID: json['items'][idx]['structureID'].to_i, structureTypeID: json['items'][idx]['type']['id'].to_i, vulnerableStartTime: json['items'][idx]['vulnerableStartTime'], vulnerableEndTime: json['items'][idx]['vulnerableEndTime'])
    end

    SovStructure.import structures
  end
end
