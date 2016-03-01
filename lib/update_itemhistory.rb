module UpdateItemhistory
  def self.update_itemhistory
    include HTTParty
    # get list of items that have market history
    response = HTTParty.get('https://public-crest.eveonline.com/market/prices/')
    item_list = JSON.parse(response.body)
    id_list = []
    item_list['items'].each do |item|
      id_list << item['type']['id']
    end

    base_url = 'https://public-crest.eveonline.com/market/10000002/types' # 34/history/'
    id_list.in_groups_of(100).each do |ids|
      threads = []
      puts ids
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
    end
  end
end
