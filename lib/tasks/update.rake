namespace :update do
  desc 'Updates item_history table'
  task item_history: :environment do
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
          next unless DateTime.parse(h['date']) > date
          to_insert << ItemHistory.new(
            typeID: id, orderCount: h['orderCount'],
            lowPrice: h['lowPrice'],
            highPrice: h['highPrice'],
            avgPrice: h['avgPrice'],
            volume: h['volume'],
            date: h['date'])
        end
      end
      ItemHistory.import to_insert if to_insert.count > 0
      count += bin_size
      puts 'ItemHistory update ' + (count / total * 100.0).round(3).to_s + '% complete'
    end
  end

  desc 'Updates player_stations table'
  task player_stations: :environment do
    # remove old stations
    PlayerStation.delete_all
    # get new stations
    response = HTTParty.get('https://api.eveonline.com/eve/ConquerableStationList.xml.aspx')
    data = response.parsed_response
    stations = []
    # xml sucks
    data['eveapi']['result']['rowset']['row'].each do |row|
      stations << PlayerStation.new(
        stationID: row['stationID'].to_i,
        stationName: row['stationName'],
        stationTypeID: row['stationTypeID'].to_i,
        solarSystemID: row['solarSystemID'].to_i,
        corporationName: row['corporationName'],
        corporationID: row['corporationID'].to_i,
        x: row['x'].to_f,
        y: row['y'].to_f,
        z: row['z'].to_f)
    end
    PlayerStation.import stations
  end

  desc 'Updates systemCostIndexes table'
  task system_cost_indices: :environment do
    # remove old stations
    SystemCostIndex.delete_all
    # get cost indices
    result = HTTParty.get('https://public-crest.eveonline.com/industry/systems/')
    json = JSON.parse(result)
    systems = []
    json['items'].each_with_index do |_sys, idx|
      systems << SystemCostIndex.new(
        solarSystemID: json['items'][idx]['solarSystem']['id'].to_i,
        inventionIndex: json['items'][idx]['systemCostIndices'][0]['costIndex'].to_s,
        manufacturingIndex: json['items'][idx]['systemCostIndices'][1]['costIndex'].to_s,
        timeResearchIndex: json['items'][idx]['systemCostIndices'][2]['costIndex'].to_s,
        materialResearchIndex: json['items'][idx]['systemCostIndices'][3]['costIndex'].to_s,
        copyingIndex: json['items'][idx]['systemCostIndices'][4]['costIndex'].to_s)
    end
    SystemCostIndex.import systems
  end

  desc 'Updates player_kills table'
  task player_kills: :environment do
    # remove old kill stats
    # KillsCurrent.where('cachedUntil < :date', date: oldCache + 1.hours < DateTime.now.utc).delete_all
    # get kills
    response = HTTParty.get('https://api.eveonline.com/map/kills.xml.aspx')
    data = response.parsed_response
    result = []
    solar_system_ids_all = SolarSystem.pluck(:solarSystemID)
    cached_until = data['eveapi']['cachedUntil']
    # xml  still sucks
    xml_data = {}
    cached_until = DateTime.parse(data['eveapi']['cachedUntil'])
    data['eveapi']['result']['rowset']['row'].each do |row|
      xml_data[row['solarSystemID'].to_i.to_s] = {
        shipKills: row['shipKills'].to_i,
        factionKills: row['factionKills'].to_i,
        podKills: row['podKills'].to_i }
    end
    solar_system_ids_all.each do |id|
      if xml_data.key?(id.to_s)
        result << KillsCurrent.new(
          solarSystemID: id,
          shipKills: xml_data[id.to_s][:shipKills],
          factionKills: xml_data[id.to_s][:factionKills],
          podKills: xml_data[id.to_s][:podKills],
          cachedUntil: cached_until)
      else
        result << KillsCurrent.new(
          solarSystemID: id,
          shipKills: 0,
          factionKills: 0, podKills: 0,
          cachedUntil: cached_until)
      end
    end
    KillsCurrent.import result
  end

  desc 'Updates player_jumps table'
  task player_jumps: :environment do
    # remove old jump stats
    # Mapjumpscurrent.where('cachedUntil < :date', date: oldCache + 1.hours < DateTime.now.utc).delete_all
    # get jumps
    response = HTTParty.get('https://api.eveonline.com/map/Jumps.xml.aspx')
    data = response.parsed_response
    result = []
    solar_system_ids_all = SolarSystem.pluck(:solarSystemID)
    cached_until = data['eveapi']['cachedUntil']
    # xml continues to suck
    xml_data = {}
    cached_until = DateTime.parse(data['eveapi']['cachedUntil'])
    data['eveapi']['result']['rowset']['row'].each do |row|
      xml_data[row['solarSystemID'].to_i.to_s] = row['shipJumps'].to_i
    end
    solar_system_ids_all.each do |id|
      result << if xml_data.key?(id.to_s)
                  JumpsCurrent.new(solarSystemID: id, shipJumps: xml_data[id.to_s], cachedUntil: cached_until)
                else
                  JumpsCurrent.new(solarSystemID: id, shipJumps: 0, cachedUntil: cached_until)
                end
    end
    JumpsCurrent.import result
  end

  desc 'Adds planet_materials to table'
  task planet_materials: :environment do
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
