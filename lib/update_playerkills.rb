module UpdatePlayerKills
  def self.update_playerKills
    include HTTParty

    # remove old kill stats
    # Killcurrent.where('cachedUntil < :date', date: oldCache + 1.hours < DateTime.now.utc).delete_all

    # get new stations
    response = HTTParty.get('https://api.eveonline.com/map/kills.xml.aspx')
    data = response.parsed_response
    result = []
    solarSystemIDsAll = Solarsystem.pluck(:solarSystemID)
    cachedUntil = data['eveapi']['cachedUntil']

    # xml sucks
    xmlData = {}
    cachedUntil = DateTime.parse(data['eveapi']['cachedUntil'])
    data['eveapi']['result']['rowset']['row'].each do |row|
      xmlData[row['solarSystemID'].to_i.to_s] = { shipKills: row['shipKills'].to_i, factionKills: row['factionKills'].to_i, podKills: row['podKills'].to_i }
    end

    solarSystemIDsAll.each do |id|
      if xmlData.key?(id.to_s)
        result << Killcurrent.new(solarSystemID: id, shipKills: xmlData[id.to_s][:shipKills], factionKills: xmlData[id.to_s][:factionKills], podKills: xmlData[id.to_s][:podKills], cachedUntil: cachedUntil)
      else
        result << Killcurrent.new(solarSystemID: id, shipKills: 0, factionKills: 0, podKills: 0, cachedUntil: cachedUntil)
      end
    end

    Killcurrent.import result
  end
end
