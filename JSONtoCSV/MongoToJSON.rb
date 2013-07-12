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

# --- files to be written as JSON
my_stations_f = "stations.json"
my_trains_f = "trains.json"

# ---- Storing collections
my_stations = coll_stations.find().to_a.to_json
my_trains = coll_trains.find().to_a.to_json

# ---- Write to file as JSON --------
File.open(my_stations_f, 'w') { |file| file.write(my_stations) }
File.open(my_trains_f, 'w') { |file| file.write(my_trains) }

puts "There are #{coll_stations.count} records as Stations"
puts "There are #{coll_trains.count} records as Trains"