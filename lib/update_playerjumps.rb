module UpdatePlayerJumps
  def self.update_playerJumps
    include HTTParty

    # remove old jump stats
    # Mapjumpscurrent.where('cachedUntil < :date', date: oldCache + 1.hours < DateTime.now.utc).delete_all

    # get new stations
    response = HTTParty.get('https://api.eveonline.com/map/Jumps.xml.aspx')
    data = response.parsed_response
    result = []
    solarSystemIDsAll = Solarsystem.pluck(:solarSystemID)
    cachedUntil = data['eveapi']['cachedUntil']

    # xml sucks
    xmlData = {}
    cachedUntil = DateTime.parse(data['eveapi']['cachedUntil'])
    data['eveapi']['result']['rowset']['row'].each do |row|
      xmlData["#{row['solarSystemID'].to_i}"] = row['shipJumps'].to_i
    end

    solarSystemIDsAll.each do |id|
      if xmlData.key?("#{id}")
        result << Jumpcurrent.new(solarSystemID: id, shipJumps: xmlData["#{id}"], cachedUntil: cachedUntil)
      else
        result << Jumpcurrent.new(solarSystemID: id, shipJumps: 0, cachedUntil: cachedUntil)
      end
    end



    Jumpcurrent.import result
  end
end
