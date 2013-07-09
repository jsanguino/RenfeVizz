require 'mongo'
require "json"
require "csv"
require 'pp'
include Mongo

# ----------------------------------------------------------------
# Converter to CVS of Renfe data scrapped and stored in MongoDB 
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

f_stations_json = "stations.json"
f_stations_csv = "stations-simple.csv"
f_trains_json = "trains.json"
f_trains_csv = "trains.csv"

# ---- Write Stations to CVS --------


total_cityStations = 95 
cityStations = coll_stations.find({}, {:limit => total_cityStations}).to_a
#cityStations = coll_stations.find().to_a


csv_string = Hash.new
csv_string[[0,0]]= "oCity"
csv_string[[0,1]]= "total_trains_out"
csv_string[[0,2]]= "total_destinations"

stops_string = Array.new
#earliest_train = 24
#earliest_train_name = String.new
larger_trains = 0

#Traverse every Station of every city 
for i in (0).upto(cityStations.length-1)
	for j in (0).upto(cityStations[i]["trains"].length-1)

		#Actions per new train at a given time
		csv_string[[i+1,j+3]]= String.new
		stops_string = Array.new
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

		#Total destinations
		csv_string[[i+1,2]] = cityStations[i]["total_destinations"]
		
		#Trains Descriptions concatenation from i to trains_out
		time_order = cityStations[i]["trains"][j]["stops"][k]["arriv_time"]
		time_order = time_order.gsub(/(?<=\d).(?=\d)/, '').to_i

		train_info_string = " --> | " <<  cityStations[i]["trains"][j]["stops"][k]["arriv_time"] << " | " << 
		cityStations[i]["trains"][j]["stops"][k]["station_id"] << " ( " <<
			cityStations[i]["trains"][j]["stops"][k]["train_name"] << " )"

		stops_string.insert(time_order, train_info_string)

		end

   	   #Add concatenation to csv_string hash
   	   stops_string.compact!

   	   for x in (1).upto(stops_string.length-1)
   	    stops_string[0] = stops_string[0] + stops_string[x]
   	   end

   	   #Adding to the big hash to be converted to csv
   	   csv_string[[i+1,j+3]] = stops_string[0]
   	   puts "Paradas para #{cityStations[i]["oCity"]} #{csv_string[[i+1,j+3]]}"
   	   puts " ---------- "
   	end

   end

#puts csv_string.to_a
puts "hola"
#pp csv_string

# HEADER: features -> [0,0..2] train_i ->[0, 3... total trains+2]
# DATA-general: city -> [1,0] total_trains_out -> [1,1] total_destinations -> [1,2] 
# DATA-stops: train_i -> [1, 3... total trains+2]

def printHashCSV_Header(csv_string, larger_trains, f_stations_csv)
	#Write header trains
	for i in (0).upto(2)
		 File.open(f_stations_csv, 'a') do |file|
    		file.print csv_string[[0,i]] + ","
  		end
		print csv_string[[0,i]] + ","
	end	

	#Write header
	for z in (0).upto(larger_trains)
	    File.open(f_stations_csv, 'a') do |file|
    		file.print csv_string[[0,z+3]]= "train_#{z+1}" + ","
  		end
		print csv_string[[0,z+3]]= "train_#{z+1}" + ","
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
  	end

	print "#{csv_string[[nstation+1,0]]}"	+ ","
	print "#{csv_string[[nstation+1,1]]}"	+ ","
	print "#{csv_string[[nstation+1,2]]}"	+ ","

	#Write DATA-stops
	
	for k in (3).upto(ntrains+2) 
	  File.open(f_stations_csv, 'a') do |file|
    	file.print csv_string[[nstation+1,k]] + ","
  	  end
	print csv_string[[nstation+1,k]] + ","
	end

	File.open(f_stations_csv, 'a') do |file|
    	file.puts ""
  	end
	puts ""
end  

# Writing Stations to file

puts "Printing and writing to file..."
#Write header
printHashCSV_Header(csv_string, larger_trains, f_stations_csv)

#Write DATA
for o in (0).upto(total_cityStations-1) 
nstation = o
printHashCSV_Data(csv_string, nstation, f_stations_csv)
end
