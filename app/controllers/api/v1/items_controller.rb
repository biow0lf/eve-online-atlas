require 'update_playerstations'
module Api
  module V1
    class ItemsController < ApiController
      include HTTParty
      include UpdatePlayerstations
      respond_to :json

      def index
        items = []
        if params[:name].present?
          # find item by name
          items = find_item_by_name(params[:name])
        end
        render json: items.to_json
      end

      def show
        item = if params[:id].to_i > 0
                 # if actually an item id, search by id
                 Item.find_by(typeID: params[:id])
               else
                 # else search by name
                 Item.find_by(typeName: params[:id])
               end
        render json: item.to_json
      end

      def price
        uri_base = 'https://public-crest.eveonline.com/market'
        type_base = 'https://public-crest.eveonline.com/types'
        find_solarsystem
        region = @solarsystem.region
        items = find_item_by_name(params[:name])
        items = items.to_ary
        items.each_with_index do |item, idx|
          items[idx] = item.as_json
          if params.key?(:buy)
            buy = HTTParty.get("#{uri_base}/#{region.id}/orders/buy/?type=#{type_base}/#{item[:typeID]}/")
            system_items = get_items_from_system(buy)
            items[idx]['buy_price'] = get_trimmed_mean(system_items, 0.2)
            items[idx]['system'] = @solarsystem.solarSystemName
          end
          next unless params.key?(:sell)
          sell = HTTParty.get("#{uri_base}/#{region.id}/orders/sell/?type=#{type_base}/#{item[:typeID]}/")
          system_items = get_items_from_system(sell)
          items[idx]['sell_price'] = get_trimmed_mean(system_items, 0.2)
          items[idx]['system'] = @solarsystem.solarSystemName
        end
        render json: items.to_json
      end

      private

      def get_items_from_system(item_list)
        items = JSON.parse item_list
        items_from_system = []
        items['items'].each do |i|
          station = Station.find_by(stationID: i['location']['id'].to_i)
          if station.nil?
            # check to see if player stations need to be updated
            check_playerstations
            station = Playerstation.find_by(stationID: i['location']['id'].to_i)
          end
          if station.solarsystem.solarSystemID == @solarsystem.solarSystemID
            items_from_system.push(i)
          end
        end
        items_from_system
      end

      def find_solarsystem
        @solarsystem = if params.key?(:system)
                         Solarsystem.find_by(solarSystemName: params[:system])
                       else
                         # Jita
                         Solarsystem.find(30_000_142)
                       end
      end

      def check_playerstations
        # make sure there are entries in the table
        if Playerstation.exists?
          return if Playerstation.first.created_at < Date.current - 1.hour
        end
        UpdatePlayerstations.update_playerstations
      end

      def find_item_by_name(names)
        return Item.where(typeName: names.split(',')) if names.include?(',')
        Item.where(typeName: names)
      end

      def get_trimmed_mean(items, trim_percentage)
        unless items.empty?
          item_prices = items.map { |item| item['price'] }.sort
          to_trim = (item_prices.size * trim_percentage).round
          trimmed_items = item_prices.slice(to_trim..(item_prices.size - to_trim))
          price = trimmed_items.sum / trimmed_items.size.to_f
          return price.round(2)
        end
        0
      end
    end
  end
end
