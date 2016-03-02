namespace :update do
  desc 'Updates ItemHistory table'
  task ItemHistory: :environment do
    # get list of items that have market history
    response = HTTParty.get('https://public-crest.eveonline.com/market/prices/')
    item_list = JSON.parse(response.body)
    id_list = []
    item_list['items'].each do |item|
      id_list << item['type']['id']
    end

    count = 0
    total = id_list.count.to_f
    bin_size = 30

    base_url = 'https://public-crest.eveonline.com/market/10000002/types' # 34/history/'
    id_list.in_groups_of(bin_size).each do |ids|
      threads = []
      ids.each do |id|
        next if id.nil?
        threads << Thread.new do
          response = HTTParty.get("#{base_url}/#{id}/history/")
          { response: JSON.parse(response), id: id }
        end
      end
      to_insert = []
      threads.each do |t|
        history = t.value[:response]
        id = t.value[:id]
        # find last history date for id in table
        item = ItemHistory.where(typeID: id)
        date = Time.zone.today - 1.year
        date = item.order('date DESC').first.date if item.count > 0
        next unless history.key?('items')
        history['items'].each do |h|
          # make sure that the item doesn't already exist
          if DateTime.parse(h['date']) > date
            to_insert << ItemHistory.new(typeID: id, orderCount: h['orderCount'], lowPrice: h['lowPrice'], highPrice: h['highPrice'], avgPrice: h['avgPrice'], volume: h['volume'], date: h['date'])
          end
        end
      end
      ItemHistory.import to_insert if to_insert.count > 0
      count += bin_size
      puts 'ItemHistory update ' + (count / total * 100.0).round(3).to_s + '% complete'
    end
  end

  desc 'Updates playerstations table'
  task playerstations: :environment do
    # remove old stations
    PlayerStation.delete_all
    # get new stations
    response = HTTParty.get('https://api.eveonline.com/eve/ConquerableStationList.xml.aspx')
    data = response.parsed_response
    stations = []
    # xml sucks
    data['eveapi']['result']['rowset']['row'].each do |row|
      stations << PlayerStation.new(stationID: row['stationID'].to_i, stationName: row['stationName'], stationTypeID: row['stationTypeID'].to_i, solarSystemID: row['solarSystemID'].to_i, corporationName: row['corporationName'], corporationID: row['corporationID'].to_i, x: row['x'].to_f, y: row['y'].to_f, z: row['z'].to_f)
      # PlayerStation.create(stationID: row['stationID'].to_i, stationName: row['stationName'], stationTypeID: row['stationTypeID'].to_i, solarSystemID: row['solarSystemID'].to_i, corporationName: row['corporationName'], corporationID: row['corporationID'].to_i, x: row['x'].to_f, y: row['y'].to_f, z: row['z'].to_f)
    end
    PlayerStation.import stations
  end

  desc 'Updates systemCostIndexes table'
  task systemcostindices: :environment do
    # remove old stations
    SystemCostIndex.delete_all
    # get cost indices
    result = HTTParty.get('https://public-crest.eveonline.com/industry/systems/')
    json = JSON.parse(result)
    systems = []
    json['items'].each_with_index do |_sys, idx|
      systems << SystemCostIndex.new(solarSystemID: json['items'][idx]['solarSystem']['id'].to_i, inventionIndex: json['items'][idx]['systemCostIndices'][0]['costIndex'].to_s, manufacturingIndex: json['items'][idx]['systemCostIndices'][1]['costIndex'].to_s, timeResearchIndex: json['items'][idx]['systemCostIndices'][2]['costIndex'].to_s, materialResearchIndex: json['items'][idx]['systemCostIndices'][3]['costIndex'].to_s, copyingIndex: json['items'][idx]['systemCostIndices'][4]['costIndex'].to_s)
    end
    SystemCostIndex.import systems
  end

  desc 'Updates player kills'
  task playerkills: :environment do
    # remove old kill stats
    # KillsCurrent.where('cachedUntil < :date', date: oldCache + 1.hours < DateTime.now.utc).delete_all
    # get kills
    response = HTTParty.get('https://api.eveonline.com/map/kills.xml.aspx')
    data = response.parsed_response
    result = []
    solarSystemIDsAll = SolarSystem.pluck(:solarSystemID)
    cachedUntil = data['eveapi']['cachedUntil']
    # xml  still sucks
    xmlData = {}
    cachedUntil = DateTime.parse(data['eveapi']['cachedUntil'])
    data['eveapi']['result']['rowset']['row'].each do |row|
      xmlData[row['solarSystemID'].to_i.to_s] = { shipKills: row['shipKills'].to_i, factionKills: row['factionKills'].to_i, podKills: row['podKills'].to_i }
    end
    solarSystemIDsAll.each do |id|
      if xmlData.key?(id.to_s)
        result << KillsCurrent.new(solarSystemID: id, shipKills: xmlData[id.to_s][:shipKills], factionKills: xmlData[id.to_s][:factionKills], podKills: xmlData[id.to_s][:podKills], cachedUntil: cachedUntil)
      else
        result << KillsCurrent.new(solarSystemID: id, shipKills: 0, factionKills: 0, podKills: 0, cachedUntil: cachedUntil)
      end
    end
    KillsCurrent.import result
  end

  desc 'Updates player jumps'
  task playerjumps: :environment do
    # remove old jump stats
    # Mapjumpscurrent.where('cachedUntil < :date', date: oldCache + 1.hours < DateTime.now.utc).delete_all
    # get jumps
    response = HTTParty.get('https://api.eveonline.com/map/Jumps.xml.aspx')
    data = response.parsed_response
    result = []
    solarSystemIDsAll = SolarSystem.pluck(:solarSystemID)
    cachedUntil = data['eveapi']['cachedUntil']
    # xml continues to suck
    xmlData = {}
    cachedUntil = DateTime.parse(data['eveapi']['cachedUntil'])
    data['eveapi']['result']['rowset']['row'].each do |row|
      xmlData[row['solarSystemID'].to_i.to_s] = row['shipJumps'].to_i
    end
    solarSystemIDsAll.each do |id|
      result << if xmlData.key?(id.to_s)
                  JumpsCurrent.new(solarSystemID: id, shipJumps: xmlData[id.to_s], cachedUntil: cachedUntil)
                else
                  JumpsCurrent.new(solarSystemID: id, shipJumps: 0, cachedUntil: cachedUntil)
                end
    end
    JumpsCurrent.import result
  end

  desc 'Adds planet materials to table'
  task planetmaterials: :environment do
    to_load = []
    planets = PlanetMaterial.find_by_sql("SELECT planet.typeID, pi.typeName
FROM invTypes planet, invTypes pi, dgmTypeAttributes dgmPlanet, dgmTypeAttributes dgmPi
WHERE dgmPlanet.typeID = dgmPi.typeID
AND dgmPlanet.attributeID = 1632 AND dgmPlanet.valueFloat = planet.typeID
AND dgmPi.attributeID = 709 AND dgmPi.valueFloat = pi.typeID
AND pi.published = 1")
    planets.each do |sys|
      to_load << PlanetMaterial.new(typeID: sys.typeID.to_i, materialType: sys.typeName.to_s)
    end
    PlanetMaterial.import to_load
  end

  desc 'Test'
  task test: :environment do
    puts 'Testing'
  end
end
