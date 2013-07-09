require 'mongo'
require "json"
require "csv"
require 'pp'
include Mongo

# ----------------------------------------------------------------
# Writes to a CVS of Renfe data stats scrapped and stored in MongoDB 
# - by Victoriano Izquierdo
#-----------------------------------------------------------------

# ---- Connect with MongoDB
mongo_client = MongoClient.new("localhost", 27017)
db = mongo_client.db("renfe_vizz")
coll_stations = db.collection("stations")
coll_trains = db.collection("trains")

# ---- Storing collections as JSON files
my_stations = coll_stations.find().to_a.to_json
#my_trains = coll_trains.find().to_a.to_json

# ---- Files to be written as JSON or CSV--------

#f_stations_json = "stations.json"
f_stations_csv = "stations-stats.csv"
#f_trains_json = "trains.json"
#f_trains_csv = "trains.csv"

# ---- Write Stations to CVS --------

total_cityStations = 95 
cityStations = coll_stations.find({}, {:limit => total_cityStations}).to_a

csv_string = Hash.new
csv_string[[0,0]]= "estacion"
csv_string[[0,1]]= "numero_de_trenes_que_salen"
csv_string[[0,2]]= "destinos_con_y_sin_transbordo_a"
csv_string[[0,3]]= "conexiones_directas_a"
csv_string[[0,4]]= "billetes_con_transbordo_a"

# ---- Utility functions --------

# UpdateCityConnections ( train_info ) -- pass train_info array of hashes and updates external hashes counters

  def UpdateCityConnections (train_info, city_counter_direct, city_counter_transfer  )

  	puts train_info[0]["train_name"]

  	direct_train_name = train_info[0]["train_name"]

  	for x in (0).upto(train_info.length-1)
  		if direct_train_name == train_info[x]["train_name"]
  			if city_counter_direct[ "#{train_info[x]["destination"]}" ].nil?
  				city_counter_direct[ "#{train_info[x]["destination"]}" ] = 1
  			else
  				city_counter_direct[ "#{train_info[x]["destination"]}" ] += 1  
  			end
  		else
  			if city_counter_transfer[ "#{train_info[x]["destination"]}" ].nil?
  				city_counter_transfer[ "#{train_info[x]["destination"]}" ] = 1
  			else
  				city_counter_transfer[ "#{train_info[x]["destination"]}" ] += 1  
  			end
  		end
  	end

end 

# Function -- pass a hash and returns a string of cities with its values 
# pass {"Antequera"=>1, "Cordoba"=>2, "Madrid"=>1}
# returns  Cordoba (2), Madrid (1), Antequera (1),

def fromCitiesHashtoString( city_counter_direct )

	the_keys = city_counter_direct.keys
	trenes_directos_a = String.new

	city_counter_direct = city_counter_direct.sort_by { |name, total_trains | total_trains }
	city_counter_direct = city_counter_direct.reverse

	for l in (0).upto(city_counter_direct.length-1)
		trenes_directos_a += city_counter_direct[l][0] + ' (' + city_counter_direct[l][1].to_s + ') - '
	end

	return trenes_directos_a

end

# ---- Traverse every Train for every Station for every City --------

for i in (0).upto(cityStations.length-1)

	#Hash with connections per city Station
	city_counter_direct = Hash.new
	city_counter_transfer = Hash.new

	for j in (0).upto(cityStations[i]["trains"].length-1)

		#Actions per new train at a given time
		csv_string[[i+1,3]]= String.new
		stops_string = Array.new

		for k in (0).upto(cityStations[i]["trains"][j]["stops"].length-1)
		
			#Train station origin City
			csv_string[[i+1,0]] = cityStations[i]["oCity"]
			#Total destinations
			csv_string[[i+1,2]] = cityStations[i]["total_destinations"] 
			#Trains trains_out
			csv_string[[i+1,1]] = j+1
	
			#Trains Descriptions concatenation from i to trains_out
			time_order = cityStations[i]["trains"][j]["stops"][k]["arriv_time"]
			time_order = time_order.gsub(/(?<=\d).(?=\d)/, '').to_i

			# hash with stop information: name of stations + name of the train
			train_info = {"destination" => cityStations[i]["trains"][j]["stops"][k]["station_id"], 
			"train_name" => cityStations[i]["trains"][j]["stops"][k]["train_name"]}

			stops_string.insert(time_order, train_info)

		end

   	#Compact array ordered with stops
   	stops_string.compact!

   	#pp stops_string

   	UpdateCityConnections(stops_string, city_counter_direct, city_counter_transfer)

   	#Adding to the big hash to be converted later to csv

   	csv_string[[i+1,3]] = fromCitiesHashtoString( city_counter_direct )
   	csv_string[[i+1,4]] = fromCitiesHashtoString( city_counter_transfer )
   	
   	#puts "Trenes directos desde #{cityStations[i]["oCity"]} :  #{csv_string[[i+1,3]]}"
   	#puts "Billetes con transbordo desde #{cityStations[i]["oCity"]} :  #{csv_string[[i+1,4]]}"
   	#puts " ---------- "
   	
   	end

end

# ---- Utility functions for writing to CVS format the CVS_STRING HASH --------

# HEADER: features -> [0,0..2] train_i ->[0, 3... total trains+2]
# DATA-general: city -> [1,0] total_trains_out -> [1,1] total_destinations -> [1,2] 
# DATA-stops: train_i -> [1, 3... total trains+2]

def printHashCSV_Header(csv_string, f_stations_csv)
	#Write header trains
	for i in (0).upto(4)
		File.open(f_stations_csv, 'a') do |file|
			file.print csv_string[[0,i]] + ","
		end
		print csv_string[[0,i]] + ","
	end	
end

def printHashCSV_Data(csv_string, nstation, f_stations_csv)	
		
	File.open(f_stations_csv, 'a') do |file|
		file.puts ""
	end
	puts ""

	ntrains = csv_string[[nstation+1, 1]]

	#Write DATA-general-station
	
	File.open(f_stations_csv, 'a') do |file|
		file.print "#{csv_string[[nstation+1,0]]}" + ","
		file.print "#{csv_string[[nstation+1,1]]}"	+ ","
		file.print "#{csv_string[[nstation+1,2]]}"	+ ","
		file.print "#{csv_string[[nstation+1,3]]}"	+ ","
		file.print "#{csv_string[[nstation+1,4]]}"	+ ""
	end

	print "#{csv_string[[nstation+1,0]]}"	+ ","
	print "#{csv_string[[nstation+1,1]]}"	+ ","
	print "#{csv_string[[nstation+1,2]]}"	+ ","
	print "#{csv_string[[nstation+1,3]]}"	+ ","
	print "#{csv_string[[nstation+1,4]]}"	+ ","
	print "#{csv_string[[nstation+1,4]]}"	+ ""

	puts ""
end  

# ---- Writing Stations to file --------

puts "Printing and writing to file..."

#Write header
printHashCSV_Header(csv_string, f_stations_csv)

#Write DATA
for o in (0).upto(total_cityStations-1) 
	
	nstation = o
	printHashCSV_Data(csv_string, nstation, f_stations_csv)
	
	File.open(f_stations_csv, 'a') do |file|
		file.puts " , "
	end

end
