require 'mongo'
require "json"
require "csv"
require 'pp'
include Mongo

# ---- Connect with MongoDB
mongo_client = MongoClient.new("localhost", 27017)
db = mongo_client.db("renfe_vizz")
coll_stations = db.collection("stations")
coll_trains = db.collection("trains")

# ---- Storing collections
my_stations = coll_stations.find().to_a.to_json
my_trains = coll_trains.find().to_a.to_json


# ---- Queries --------

#puts coll_stations.find().to_a

#pp coll_stations.find({}, {:limit => 1, :sort => { "trains.$.dep_time.$.total_time" => -1 }}).to_a

thisStation = coll_stations.find({}, {:limit => 1}).to_a
#puts thisStation[0]["oCity"]

#puts thisStation.length
#puts thisStation[0]["trains"].length
#puts thisStation[0]["trains"][0]["stops"].length

#puts thisStation[0]["trains"][0]["stops"][0]["arriv_time"]
#puts thisStation[0]["trains"][0]["stops"][0]["station_id"]
#puts thisStation[0]["trains"][0]["stops"][0]["train_name"]

#csv_string[3] = "|6.43| Zamora (INTERCITY34) -> |7.23| Calatrava (INTERCITY34) -> "
#csv_string[4] = "|18.13| Zamora (AVE145) -> |20.34| Madrid (AVE145) -> "

csv_string = Array.new

for i in (0).upto(thisStation.length)
	for j in (0).upto(thisStation[i]["trains"].length)
		for k in (0).upto(thisStation[i]["trains"][j]["stops"].length)
		
		csv_string[0] = thisStation[i]["oCity"] 
		#Trains trains_out
		csv_string[1] = thisStation[i]["total_trains_out"] 
		#Total destinations
		csv_string[2] = thisStation[i]["total_destinations"]

		n = k+3
	
		#Trains Descriptions from i to trains_out
		csv_string[n] = "| " <<  thisStation[i]["trains"][j]["stops"][k]["arriv_time"] << " | " << 
						  thisStation[i]["trains"][j]["stops"][k]["station_id"] << "( " <<
						  thisStation[i]["trains"][j]["stops"][k]["train_name"] << " ) ->"
		theCSV = csv_string.to_csv
		puts theCSV

   	   end
   end
#Add a new line to the CSV per station
theCSV = csv_string.to_csv
puts theCSV

end



#coll_stations.find().each { |row| p row }
		#csv_string[3] = "|6.43| Zamora (INTERCITY34) -> |7.23| Calatrava (INTERCITY34) -> "
		#csv_string[4] = "|18.13| Zamora (AVE145) -> |20.34| Madrid (AVE145) -> "

# ---- Write to file as JSON --------

my_stations_f = "stations.json"
my_trains_f = "trains.json"

#File.open(my_stations_f, 'w') { |file| file.write(my_stations) }

puts "There are #{coll_stations.count} records as Stations"

# ---- Write to file as CVS --------

#puts my_trains

#json = File.read('./SecondTest/mini-test.json')
#stations = JSON.parse(json)

#puts stations[0]["trains"][0]["t57-4_ref"]

#pp stations.select{|key, value| hash["t957-2_to"] == "Navalmoral de la Mata" }
#puts stations[0]["trains"]
##pp stations