module Api
  module V1
    class ItemsController < ApiController
      include HTTParty
      respond_to :json

      def index
        items = []
        if params[:name].present?
          # find item by name
          items = find_item_by_name(params[:name])
        end
        render json: items.as_json
      end

      def show
        item = if params[:id].to_i > 0
                 # if actually an item id, search by id
                 Item.find_by(typeID: params[:id])
               else
                 # else search by name
                 Item.find_by(typeName: params[:id])
               end
        render json: item.as_json
      end

      def price
        uri_base = 'https://public-crest.eveonline.com/market'
        type_base = 'https://public-crest.eveonline.com/types'
        region = ''

        if params.key?(:system)
          find_solarsystem
          region = @solarsystem.region
        else
          find_region
          region = @region
        end

        items = find_item_by_name(params[:name])
        items = items.to_ary
        items.each_with_index do |item, idx|
          items[idx] = item.as_json
          if params.key?(:buy)
            buy = HTTParty.get("#{uri_base}/#{region.id}/orders/buy/?type=#{type_base}/#{item[:typeID]}/")
            filtered_items = if @solarsystem.nil?
                               get_items_from_region(buy)
                             else
                               get_items_from_system(buy)
                             end
            items[idx]['buy_price'], items[idx]['highest_buy'] = get_trimmed_mean(filtered_items, 0.2, 'highest')
            items[idx]['system'] = @solarsystem.solarSystemName unless @solarsystem.nil?
            items[idx]['region'] = @region.regionName unless @region.nil?
          end
          next unless params.key?(:sell)
          sell = HTTParty.get("#{uri_base}/#{region.id}/orders/sell/?type=#{type_base}/#{item[:typeID]}/")
          filtered_items = if @solarsystem.nil?
                             get_items_from_region(sell)
                           else
                             get_items_from_system(sell)
                           end
          items[idx]['sell_price'], items[idx]['lowest_sell'] = get_trimmed_mean(filtered_items, 0.2, 'lowest')
          items[idx]['system'] = @solarsystem.solarSystemName unless @solarsystem.nil?
          items[idx]['region'] = @region.regionName unless @region.nil?
        end
        render json: items.as_json
      end

      def history
        items = find_item_by_name(params[:name])
        return render json: { error: 'Invalid item names', status: :bad_request }, status: :bad_request if items.count == 0
        result = []
        items.each do |item|
          to_push = {}
          to_push['typeID'] = item.typeID
          to_push['history'] = item.itemHistories.select('id,orderCount,lowPrice,highPrice,avgPrice,volume,date').as_json
          result << to_push
        end
        render json: result.as_json
      end

      private

      def get_items_from_region(item_list)
        items = JSON.parse item_list
        items['items'].as_json
      end

      def get_items_from_system(item_list)
        items = JSON.parse item_list
        items_from_system = []
        items['items'].each do |i|
          station = Station.find_by(stationID: i['location']['id'].to_i, solarSystemID: @solarsystem.solarSystemID)
          if station.nil?
            station = PlayerStation.find_by(stationID: i['location']['id'].to_i, solarSystemID: @solarsystem.solarSystemID)
          end
          items_from_system.push(i) unless station.nil?
        end
        items_from_system
      end

      def find_solarsystem
        return @solarsystem = SolarSystem.find_by(solarSystemName: params[:system]) if params.key?(:system)
        # else use Jita
        @solarsystem = SolarSystem.find_by(solarSystemName: 'Jita')
      end

      def find_region
        return @region = Region.find_by(regionName: params[:region]) if params.key?(:region)
        # else use The Forge
        @region = Region.find_by(regionName: 'The Forge')
      end

      def find_item_by_name(names)
        return Item.where(typeName: names.split(',')) if names.include?(',')
        Item.where(typeName: names)
      end

      def get_trimmed_mean(items, trim_percentage, direction)
        unless items.empty?
          price = nil
          item_prices = items.map { |item| item['price'] }.sort
          if direction == 'highest'
            price = item_prices.last
          elsif direction == 'lowest'
            price = item_prices.first
          end
          to_trim = (item_prices.size * trim_percentage).round
          trimmed_items = item_prices.slice(to_trim..(item_prices.size - to_trim))
          trimmed_price = trimmed_items.sum / trimmed_items.size.to_f
          return trimmed_price.round(2), price
        end
        return 0, 0
      end
    end
  end
end
