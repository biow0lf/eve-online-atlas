# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

cache_time = DateTime.now - 1.year
100.times do |idx|
  cache_time += 1.day
  to_insert =[]
  8000.times do
    to_insert << Jumpcurrent.new(solarSystemID: rand(30000001..30005000), shipJumps: rand(0..1000), cachedUntil: cache_time)
  end
  Jumpcurrent.import to_insert
  puts idx
end
