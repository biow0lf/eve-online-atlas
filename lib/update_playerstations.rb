module UpdatePlayerstations
  def self.update_playerstations
    include HTTParty
    # remove old stations
    Playerstation.delete_all

    # get new stations
    response = HTTParty.get('https://api.eveonline.com/eve/ConquerableStationList.xml.aspx')
    data = response.parsed_response

    stations = []

    # xml sucks
    data['eveapi']['result']['rowset']['row'].each do |row|
      stations << Playerstation.new(stationID: row['stationID'].to_i, stationName: row['stationName'], stationTypeID: row['stationTypeID'].to_i, solarSystemID: row['solarSystemID'].to_i, corporationName: row['corporationName'], corporationID: row['corporationID'].to_i, x: row['x'].to_f, y: row['y'].to_f, z: row['z'].to_f)
      # Playerstation.create(stationID: row['stationID'].to_i, stationName: row['stationName'], stationTypeID: row['stationTypeID'].to_i, solarSystemID: row['solarSystemID'].to_i, corporationName: row['corporationName'], corporationID: row['corporationID'].to_i, x: row['x'].to_f, y: row['y'].to_f, z: row['z'].to_f)
    end

    Playerstation.import stations
  end
end
