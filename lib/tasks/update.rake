namespace :update do
  desc 'Updates itemHistory table'
  task itemhistory: :environment do
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
        item = Itemhistory.where(typeID: id)
        date = Time.zone.today - 1.year
        date = item.order('date DESC').first.date if item.count > 0
        next unless history.key?('items')
        history['items'].each do |h|
          # make sure that the item doesn't already exist
          if DateTime.parse(h['date']) > date
            to_insert << Itemhistory.new(typeID: id, orderCount: h['orderCount'], lowPrice: h['lowPrice'], highPrice: h['highPrice'], avgPrice: h['avgPrice'], volume: h['volume'], date: h['date'])
          end
        end
      end
      Itemhistory.import to_insert if to_insert.count > 0
      count += bin_size
      puts 'ItemHistory update ' + (count / total * 100.0).round(3).to_s + '% complete'
    end
  end

  desc 'Updates playerstations table'
  task playerstations: :environment do
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

  desc 'Test'
  task test: :environment do
    puts 'Testing'
  end
end
