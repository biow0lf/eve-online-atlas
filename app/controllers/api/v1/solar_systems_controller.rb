module Api
  module V1
    class SolarSystemsController < ApiController
      respond_to :json
      before_action :find_solarsystem, :find_wormholes

      def index
        return render json: @solarsystem if @solarsystem
        return render json: [], status: :bad_request if params[:name]
        render json: SolarSystem.all
      end

      def show
        planet_ids = @solarsystem.planets.pluck(:itemID)
        result = @solarsystem.as_json
        unless @wormhole.nil?
          result['whData'] = @wormhole.as_json
          result['whData']['static1'] = @wormhole.static1
          result['whData']['static2'] = @wormhole.static2
          result['whData']['effects'] = @wormhole.wormholeEffects
          end
        result['structures'] = @solarsystem.sovStructures
        result['region'] = @solarsystem.region
        result['costIndexes'] = @solarsystem.systemCostIndex
        result['constellation'] = @solarsystem.constellation
        result['stationIDs'] = @solarsystem.stations.pluck(:stationID)
        result['jumps'] = @solarsystem.jumpsCurrents.last.shipJumps
        result['shipKills'] = @solarsystem.killsCurrents.last.shipKills
        result['podKills'] = @solarsystem.killsCurrents.last.podKills
        result['npcKills'] = @solarsystem.killsCurrents.last.factionKills
        if result['stationIDs'].empty?
          result['stationIDs'] = @solarsystem.playerStations.pluck(:stationID)
        end
        result['planetIDs'] = planet_ids
        render json: result
      end

      def neighbors
        neighboring = @solarsystem.toSolarSystems
        result = []
        neighboring.each do |n|
          to_push = n.as_json
          to_push['shipKills'] = n.killsCurrents.last.shipKills
          to_push['podKills'] = n.killsCurrents.last.podKills
          to_push['npcKills'] = n.killsCurrents.last.factionKills
          to_push['jumps'] = n.jumpsCurrents.last.shipJumps
          result << to_push
        end
        render json: result
      end

      private

      def find_solarsystem
        return @solarsystem = SolarSystem.find_by(solarSystemName: params[:name]) if params.key?(:name)
        @solarsystem = SolarSystem.find(params[:id]) if params[:id]
      end

      def find_wormholes
        @wormhole = WormholeSystem.find_by(solarSystemID: params[:id])
      end
      end
  end
end
