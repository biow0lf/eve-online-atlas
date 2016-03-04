# README #

### Welcome to the EVE Online Atlas (EOA)!  ###

## Highlights and Features
* Automatic chat-log parsing and updating once initialized
* Works in the background and when the tab is not selected
    * Parallel states too! - Dashboard and Chat Parser can run concurrently
* Configurable for simultaneous multiple characters in a chat
    * Allows you to add alts to parsing & listening - no need to always run commands from the same character
* Variety of commands
    * Check the buy/sell price of an item or list of items at a specified system / region
        * Can specify item quantity
        * Can also paste in a list of items from an inventory details set
    * Find Thera wormholes and distances to those wormholes from a given system
    * Support for adding multiple characters for log parsing & listening
* History graph for item prices & order quantities over the past year (in monthly or weekly format)
* SPA (single page application)
* Character location-aware dashboard
* Scheduled jobs for keeping API data up-to-date (via Crono)
* Public API for querying SDE with models & associations (endpoints listed below)

### Future Additions ###
* More Commands!
* Highcharts to replace C3.js
* TBA

### Compatibility ###
* Compatible and tested with Chrome 49

### Demo ###
The server is hosted at https://eve-atlas.com/

To use the dashboard functionality of the application, sign in using Eve's SSO. When you're in a system, or when you change systems, the dashboard will reflect the current system that your character is in. If the CREST location api is down for some reason, then you can click the button to change the system to imitate moving from one system to another (starts at Jita and increments solarSystemID by one per click). Additionally, due to an issue with the refresh tokens that I haven't been able to figure out, your user needs to re-authenticate using Eve's SSO when the access token expires (every 20 minutes).

To use the log parser functionality, set a chat log file to track. Log files are typically present in your My Documents folder in Windows: C:\Users\[UserName]\Documents\EVE\logs

Log parser commands are shown in the Commands tab, along with examples. 


### Tech Used ###
* Ruby on Rails
* MySQL
* AngularJS
* Angular Material
* Ui-router
* Crono (ruby)
* C3.js (D3.js)
* Angular Moment (moment.js)
* Coffeescript
* HTML
* ERB

### Sources ###
* Thera wormholes - https://eve-scout.com
* Moon Data - eve-moons.com - http://eve-moons.com/rawdata.php
* SDE - CCP conversion by Fuzzworks - https://www.fuzzwork.co.uk/dump/
* Wormhole Data DB - by heicrd - https://github.com/heicrd/pyhole
* API - CCP's xml api
* CREST - CCP's crest api

### Sources (Detailed) ###

Category | Resource                   | Desc
---------|----------------------------|-----
Authed CREST | Location | Used to provide system location for the Atlas dashboard
CREST    | Market prices              | Used to fetch the prices for the !pc command
CREST    | Market History             | Used to supply the data for item history chart
CREST    | Industry Systems           | Provides the System Cost Indices.
CREST    | Sov Structures             | Provides the sov structures.
API      | map/kills                  | Used for system kill history
API      | map/jumps                  | Used for system jump history
API      | eve/ConquerableStationList | Used for outpost station data.
SDE      | mapSolarSystems            | Used for Solarsystem data and systemID to systemName conversions
SDE      | mapRegions                 | Used for Region data and regionID to regionName conversions
SDE      | mapConstellations          | Used for constellationID to constellationName conversions
SDE      | mapDenormalize             | Provide data on celestials
SDE      | mapSolarSystemJumps        | Used to figure out neighboring systems
SDE      | mapCelestialStatistics     | Used for planet/moon statistics
SDE      | staStations                | Provide station data
SDE      | staOperationServices       | operationID to serviceID conversions
SDE      | staServices                | serviceID to serviceName converions
SDE      | invTypes                   | Used for typeID to typeName conversions
SDE      | agtAgents                  | Provides the agent information
SDE      | invUniqueNames             | Provides agent's names

## Custom tables

Category | Table Name        | Desc
---------|-------------------|-----
CREST    | item_history      | Custom table to store historic market data for chart
CREST    | users             | Custom table for SSO
API      | map_jumps_current | Custom table to store current day's jumps
API      | map_kills_current | Custom table to store current day's kills
API      | map_jumps_history | Custom table to store the jump history
API      | map_kills_history | Custom table to store the kills history
API      | player_stations   | Custom table to store Outposts
SDE      | wormhole_effects  | Custom table to store wormhole effects
SDE      | planet_materials  | Custom table to store materials planets have
EXTERNAL | map_moons         | Moon material data supplied by eve-moons.com
EXTERNAL | wormhole_systems  | Wormhole sys data supplied from heicrd's sql dump
EXTERNAL | wormhole_types    | Wormhole static data supplied from heicrd's sql dump

## API

Type |Route                         | Description
-----|------------------------------|-----
GET  | /thera?system={system_name}  | Queries eve-scout's API for thera wormholes; gets jump distances to given system if system is supplied
GET  | /users/location              | Queries CREST to get character's location (if signed in)
GET  | /api/v1/items?name={items}   | Queries SDE; name can be a single item's name or a comma-separated list of item names; if name is present returns the SDE rows for items
GET  | /api/v1/items/{id}           | Queries SDE; id can be a numerical ID or an item name; if present in SDE returns the SDE row for item
GET  | /api/v1/items/price?name={items}&system={system_name}&region={region_name}&buy&sell | Queries SDE + CREST; name can be a single item's name or a comma-separated list of item names; default to The Forge region; if system name is specified, finds prices only for that system; if region name is specified, finds prices for the entire region; if buy param is present, finds buy prices; if sell param is present, finds sell prices
GET  | /api/v1/items/history?name={item} | Queries SDE + history table; name can be a single item's name or a comma-separated list of item names; return price history for items
GET  | /api/v1/regions?name={region_name}| Queries SDE; returns all regions if no name is specified; if name is specified, tries to match exact name first, then tries to match via LIKE
GET  | /api/v1/regions/{id}              | Queries SDE; returns region row and region's constellation and solarSystem ids
GET  | /api/v1/solar_systems?name={solar_system_name} | Queries SDE; return all solarSystems if no name is specified; if name is specified, tries to match exact name
GET  | /api/v1/solar_systems/{id}        | Queries SDE; returns solarSystem row and related data, including planet ids, class, structures, and station ids
GET  | /api/v1/solar_systems/{solar_system_id}/neighbors | Queries SDE; returns a list of neighboring solarSystems
GET  | /api/v1/solar_systems/{solar_system_id}/stations  | Queries SDE; returns a list of stations for a solarSystem, including station services
GET  | /api/v1/solar_systems/{solar_system_id}/stations/{id}  | Queries SDE; returns station of a solarSystem, including station services
GET  | /api/v1/solar_systems/{solar_system_id}/stations/{station_id}/agents  | Queries SDE; returns a list of agent rows for a station
GET  | /api/v1/solar_systems/{solar_system_id}/planets | Queries SDE; returns list of planets (with respective moon ids and celestialStatistics) for a solarSystem
GET  | /api/v1/solar_systems/{solar_system_id}/planets/{id} | Queries SDE; returns a specific planet of a solarSystem and associated data
GET  | /api/v1/solar_systems/{solar_system_id}/planets/{planet_id}/moons | Queries SDE; returns a list of moons with respective celestialStatistics
GET  | /api/v1/solar_systems/{solar_system_id}/planets/{planet_id}/moons/{id} | Queries SDE; returns a moon and respective celestialStatistics

### SDE Issues ###
*  mapCelestialStatistics orbitPeriod given in deciseconds?
*  maplocationwormholeclasses contains region, constellation and system IDs? Polymorphism, ho!
*  Out of the 471,577 planets in mapCelestialStatistics all of them have fragmented and mass = 0.
*  No way to get station services from outposts.
*  Planets/moons/asteroid belts should be in their own table.
*  Should remove the "DEPRECATED DIVISIONS" from crpNpcDivisions table.

### Known Issues ###
* Multiple word character names break chat log modified time
* CREST Location sometime caches system and does not update (Known error)
* /api/v1/solar_systems/{id} API can return false wh effect information

### Bug Reporters ###
miquela01 - Various thera related bugs

### Setup Instructions ###
Unix / Linux / Mac

* Install RVM and create two files in the project root: .ruby-version and .ruby-gemset
* .ruby-version should contain `ruby-2.3.0`
* .ruby-gemset should contain the gemset name (ex: `crest-api`)
* CD out of and into the project root once the .ruby files are made -> RVM should download the specified ruby version and create a gemset
* Copy the database.yml.samle in config/ to database.yml and input desired database names for `dbName`
* Inside the project root, run `gem install bundler`
* Once bundler is installed run `bundle install` to install the rest of the gems
* Run `rake db:create` to initialize the database
* Import the mysql2 conversion of the SDE into the your dbName-develop database
* Run `rake db:migrate` to run the database migrations
* Import the map_moons_and_wormhole_data.sql from the map_moons_and_wormhole_data.zip into your dbName-develop database
* Run `rake convert:planet_materials` to populate the planet_materials table
* Run `rake update:player_jumps update:player_kills update:player_stations update:sov_structures update:system_cost_indices update:item_history` to get the latest API data (warning: item_history WILL take a long time the first time, as it grabs the entire history from The Forge; future updates are faster as it only inserts newer histories)
* Run `rails s` to host the server on localhost:3000

Windows

* All I know is that it's possible because George did it, but I don't remember how.

### License (MIT LICENSE) ###
Copyright © 2016 George Dietrich, Zachary Lovin

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Copyright ###
EVE Online and the EVE logo are the registered trademarks of CCP hf. All rights are reserved worldwide. All other trademarks are the property of their respective owners. EVE Online, the EVE logo, EVE and all associated logos and designs are the intellectual property of CCP hf. All artwork, screenshots, characters, vehicles, storylines, world facts or other recognizable features of the intellectual property relating to these trademarks are likewise the intellectual property of CCP hf.

CCP hf. has granted permission to Eve Online Atlas to use EVE Online and all associated logos and designs for promotional and information purposes on its website but does not endorse, and is not in any way affiliated with, the Eve Online Atlas. CCP is in no way responsible for the content on or functioning of this website, nor can it be liable for any damage arising from the use of this website.