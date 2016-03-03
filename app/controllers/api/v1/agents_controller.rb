module Api
  module V1
    class AgentsController < ApiController
      respond_to :json
      before_action :find_solarsystem, :find_station

      def index
        return render json: @station.agents if @station
        render json: Agent.all.as_json
      end

      def show
        # find agents by locationID as int
        agents = Agent.where(locationID: params[:id].to_s)
        # create output array
        result = []
        # for each agent in the relationship
        agents.each do |a|
          # dump the agent to a tmp variable as json
          tmp = a.as_json
          # add in the agent's name to the tmp variable
          tmp['name'] = a.agentName.itemName
          # push the result to the output
          result.push(tmp)
        end

        # return the output
        render json: result.as_json
      end

      private

      def find_solarsystem
        @solarsystem = SolarSystem.find(params[:solar_system_id])
      end

      def find_station
        @station = @solarsystem.stations.find(params[:station_id])
      end

    end
  end
end
