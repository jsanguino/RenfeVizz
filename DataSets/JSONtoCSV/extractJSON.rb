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

# ---- Storing collections as JSON files
my_stations = coll_stations.find().to_a.to_json
my_trains = coll_trains.find().to_a.to_json

# ---- Files to be written as JSON or CSV--------

my_stations_json = "stations.json"
my_stations_csv = "stations.csv"
my_trains_json = "trains.json"
my_trains_csv = "trains.csv"

# ---- Write Stations to CVS --------

#puts coll_stations.find().to_a

cityStations = coll_stations.find({}, {:limit => 2}).to_a

csv_string = Hash.new
csv_string[[0,0]]= "oCity"
csv_string[[0,1]]= "total_trains_out"
csv_string[[0,2]]= "total_destinations"

stops_string = Array.new
stops_string[0] = String.new
larger_trains = 0

#Traverse every Station of every city 
for i in (0).upto(cityStations.length-1)
	for j in (0).upto(cityStations[i]["trains"].length-1)

		#Actions per new train at a given time
		csv_string[[i+1,j+3]]= String.new
		stops_string[0] = "|| " << cityStations[i]["trains"][j]["dep_time"] << " |||** " << cityStations[i]["oCity"] << " **|||"

		for k in (0).upto(cityStations[i]["trains"][j]["stops"].length-1)

		#Actions per stop 
		#puts "let's go with #{i} #{j} #{k}"
		
		#Train station origin City
		csv_string[[i+1,0]] = cityStations[i]["oCity"] 
		#Trains trains_out
		csv_string[[i+1,1]] = j+1
		if j >= larger_trains
		larger_trains = j 
		end
		#puts larger_trains
		#Total destinations
		csv_string[[i+1,2]] = cityStations[i]["total_destinations"]
		
		#Trains Descriptions concatenation from i to trains_out
		stops_string[0] = stops_string[0] << " --> | " <<  cityStations[i]["trains"][j]["stops"][k]["arriv_time"] << " | " << 
		cityStations[i]["trains"][j]["stops"][k]["station_id"] << " ( " <<
			cityStations[i]["trains"][j]["stops"][k]["train_name"] << " )"

		end

   	   #Add concatenation to csv_string hash
   	   csv_string[[i+1,j+3]] = stops_string[0]
   	   stops_string[0] = String.new

   	end

   end

#puts csv_string.length
pp csv_string
#puts csv_string.to_a


# HEADER: features -> [0,0..2] train_i ->[0, 3... total trains+2]
# DATA-general: city -> [1,0] total_trains_out -> [1,1] total_destinations -> [1,2] 
# DATA-stops: train_i -> [1, 3... total trains+2]

puts "Printing ..."

def printHashCSV_Header(csv_string, larger_trains)
	#Write header trains
	for i in (0).upto(2)
		print csv_string[[0,i]] + ","
	end	

	#Write header
	for z in (0).upto(larger_trains-1)
		print csv_string[[0,z+3]]= "train_#{z+1}" + ","
	end	
end

def printHashCSV_Data(csv_string, nstation)	
	
	puts ""
	ntrains = csv_string[[nstation+1, 1]]

   
	#Write DATA-general-station
	
	print csv_string[[nstation+1,0]] + ","
	print "#{csv_string[[nstation+1,1]]}"	+ ","
	print "#{csv_string[[nstation+1,2]]}"	+ ","

	#Write DATA-stops
	
	for k in (3).upto(ntrains) 
		print csv_string[[nstation+1,k]] + ","
	end


	puts ""
end  

printHashCSV_Header(csv_string, larger_trains)
nstation = 0
printHashCSV_Data(csv_string, nstation)

#theCSV = csv_string.values.to_csv
#puts theCSV


#coll_stations.find().each { |row| p row }
		#csv_string[3] = "|6.43| Zamora (INTERCITY34) -> |7.23| Calatrava (INTERCITY34) -> "
		#csv_string[4] = "|18.13| Zamora (AVE145) -> |20.34| Madrid (AVE145) -> "



#File.open(my_stations_json, 'w') { |file| file.write(my_stations) }

#puts "There are #{coll_stations.count} records as Stations"

# ---- Write to file as CVS --------

#puts my_trains

#json = File.read('./SecondTest/mini-test.json')
#stations = JSON.parse(json)

#puts stations[0]["trains"][0]["t57-4_ref"]

#pp stations.select{|key, value| hash["t957-2_to"] == "Navalmoral de la Mata" }
#puts stations[0]["trains"]
##pp stations