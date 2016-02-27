module UpdateCostIndexes
  def self.update_systemcostindexes
    include HTTParty
    require 'pp'
    
    # remove old stations
    Systemcostindex.delete_all

    result = HTTParty.get('https://public-crest.eveonline.com/industry/systems/')
    json = JSON.parse(result)

    systems = []

   json['items'].each_with_index do |sys,idx|
     systems << Systemcostindex.new(solarSystemID: json['items'][idx]['solarSystem']['id'].to_i, inventionIndex: json['items'][idx]['systemCostIndices'][0]['costIndex'].to_s, manufacturingIndex: json['items'][idx]['systemCostIndices'][1]['costIndex'].to_s, timeResearchIndex: json['items'][idx]['systemCostIndices'][2]['costIndex'].to_s, materialResearchIndex: json['items'][idx]['systemCostIndices'][3]['costIndex'].to_s, copyingIndex: json['items'][idx]['systemCostIndices'][4]['costIndex'].to_s)
   end

    Systemcostindex.import systems
  end
end