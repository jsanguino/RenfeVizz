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

#csv_string = Array.new
stops_string = Array.new
stops_string[3] = String.new
#csv_string[3] = String.new

csv_string = Hash.new
#csv_string[[0,0]]= 23
#csv_string[[0,1]]= 42
#csv_string[[0,2]]=
csv_string[[0,3]]= String.new

for i in (0).upto(1)
	for j in (0).upto(1)

		stops_string[3] = "|| " << thisStation[i]["trains"][j]["dep_time"] << " |||** " << thisStation[i]["oCity"] << " **|||"

		for k in (0).upto(thisStation[i]["trains"][j]["stops"].length-1)

#for i in (0).upto(thisStation.length-1)
#	for j in (0).upto(thisStation[i]["trains"].length-1)
#		for k in (0).upto(thisStation[i]["trains"][j]["stops"].length-1)

		puts "let's go with #{i} #{j} #{k}"
		
		csv_string[[i,0]] = thisStation[i]["oCity"] 
		#Trains trains_out
		csv_string[[i,1]] = thisStation[i]["total_trains_out"] 
		#Total destinations
		csv_string[[i,2]] = thisStation[i]["total_destinations"]
		
		 

		#Trains Descriptions from i to trains_out
		stops_string[3] = stops_string[3] << " --> | " <<  thisStation[i]["trains"][j]["stops"][k]["arriv_time"] << " | " << 
						  thisStation[i]["trains"][j]["stops"][k]["station_id"] << " ( " <<
						  thisStation[i]["trains"][j]["stops"][k]["train_name"] << " )"
		
		#puts stops_string

		#theCSV = csv_string.to_csv
		#puts theCSV

   	   end
   	   csv_string[[i,j+3]] = stops_string[3]
   	   stops_string[3] = String.new
   	   theCSV = csv_string.values.to_csv
   	   puts theCSV
   end
#Add a new line to the CSV per station

#theCSV = csv_string.to_csv
#puts theCSV

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