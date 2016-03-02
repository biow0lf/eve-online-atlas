# README #

### Welcome to the EVE Online Atlas (EOA)!  ###

* Quick summary
* Version
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

### How do I get set up? ###

* Summary of set up
* Configuration
* Dependencies
* Database configuration
* How to run tests
* Deployment instructions

### Future Additions ###
* Moar Commands!
* #more to come

### Tech Used ###
* Ruby on Rails
* MySQL
* Coffeescript
* HTML

### Sources ###
* Moon Data - eve-moons.com - http://eve-moons.com/rawdata.php
* SDE - CCP conversion by Fuzzworks - https://www.fuzzwork.co.uk/dump/
* API - CCP
* CREST - CCP

### Sources (Detailed) ###
Authed CREST - Location - Used to provide system location for the Atlas dashboard

* CREST - Market prices - Used to fetch the prices for the !pc command
* CREST - Market History - Used to supply the data for item history chart
* CREST - Industry Systems - Provides the System Cost Indices.
* CREST - Sov Structures - Provides the sov structures.

* API - map/kills - Used for system kill history
* API - map/jumps - Used for system jump history
* API - eve/ConquerableStationList - Used for outpost station data.

* SDE - mapSolarSystems - Used for Solarsystem data and systemID to systemName conversions
* SDE - mapRegions - Used for Region data and regionID to regionName conversions
* SDE - mapConstellations - Used for constellationID to constellationName conversions
* SDE - map_jumps_current - Custom table to store current day's jumps
* SDE - map_kills_current - Custom table to store current day's kills
* SDE - mapJumpHistory - Custom table to store the jump history
* SDE - mapKillHistory - Custom table to store the kills history
* SDE - map_moons - Moon material data supplied by eve-moons.com
* SDE - mapDenormalize - Provide data on celestials
* SDE - mapSolarSystemJumps - Used to figure out neighboring systems
* SDE - mapCelestialStatistics - Used for planet/moon statistics
* SDE - mapLocationWormholeClasses - Provides WH classes
* SDE - player_stations - Custom table to store Outposts
* SDE - staStations - Provide station data
* SDE - staOperationServices - operationID to serviceID conversions
* SDE - staServices - serviceID to serviceName converions
* SDE - invTypes - Used for typeID to typeName conversions
* SDE - agtAgents - Provides the agent information
* SDE - invUniqueNames - Provides agent's names
* SDE - item_history - Custom table to store historic market data for chart
* SDE - planet_materials - Custom table to store materials planets have
* SDE - users - Custom table for SSO

### SDE Issues ###
*  mapCelestialStatistics orbitPeriod given in deciseconds?
*  maplocationwormholeclasses contains region, constellation and system IDs?
*  Out of the 471,577 planets in mapCelestialStatistics all of them have fragmented and mass = 0.
*  No way to get station services from outposts.
*  Planets/moons should be in their own table.