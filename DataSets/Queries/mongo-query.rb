require 'mongo'
require "json"
include Mongo

#Connect with MongoDB

mongo_client = MongoClient.new("localhost", 27017)
db = mongo_client.db("renfe_vizz")
coll = db.collection("stations")

#Writes to journeys collection in the MongoDB


o = "Zamora"
tt = "99261LD-AVE" 
tt2 = "00851TRENHOTEL"
i = 3
j = 0

@trains= Hash.new
@trains = {[2, 0]=>"99142AVE-MD", [2, 1]=>"17.33", [2, 2]=>"23.20", [2, 3]=>347, [1, 0]=>"99570AVE-LD", [1, 1]=>"13.43", [1, 2]=>"20.09", [1, 3]=>386}
@length = @trains.length/4

# ------ Queries -------------------------


# ------ Loops -------------------------

#Add to DB every Train for this Journey

for k in (@length).downto(1)
  
  puts "In #{k}"

  coll.update( { "oCity" => o }, 
	{ "$addToSet" => { 'trains.$.stops' => {"station" => 'Sevilla', "time" => "2h33min", "arriv_time" => "21:43" }}} )
  
end

#Updates the list of stops for a given train
coll.update( { "oCity" => o, 'trains' =>{'$elemMatch' =>{'t_ref' => tt2}}}, 
	{ "$addToSet" => { 'trains.$.stops' => {"station" => 'Sevilla', "time" => "2h33min", "arriv_time" => "21:43" }}} )

puts coll.find.to_a