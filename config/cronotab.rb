require 'rake'
CrestApiContest::Application.load_tasks

class UpdatePlayerstations
  def perform
    Rake::Task['update:PlayerStations'].invoke
  end
end

class UpdateItemhistory
  def perform
    Rake::Task['update:ItemHistory'].invoke
  end
end

class UpdateCostIndicies
  def perform
    Rake::Task['update:SystemCostIndices'].invoke
  end
end

Crono.perform(UpdatePlayerstations).every 1.hour
Crono.perform(UpdateCostIndicies).every 1.hour
# 18:00 is UTC midnight in Central tz - so wait a couple of hours for downtime, etc.
Crono.perform(UpdateItemhistory).every 1.day, at: {hour: 20, min: 0}