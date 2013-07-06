require 'moped'
require "json"


#Connect with MongoDB
session = Moped::Session.new([ "127.0.0.1:27017" ])
session.use "renfe_vizz"
#Writes to journeys collection in the MongoDB
journeys = session[:stations]

o = "Zaragoza (*)"
@tt = "00664ALVIA" 
i = 3
j = 0

@trains= Hash.new
@trains = {[2, 0]=>"99142AVE-MD", [2, 1]=>"17.33", [2, 2]=>"23.20", [2, 3]=>347, [1, 0]=>"99570AVE-LD", [1, 1]=>"13.43", [1, 2]=>"20.09", [1, 3]=>386}
#@length = @trains/4

# ------ Queries -------------------------

#Match a given train departing from a given station - optional dep_time
#puts journeys.find({station: o, t_ref: tt }).inspect

#renfe_vizz.stations.find( { oCity: o },{ trains: { $elemMatch: { t_ref": "00664ALVIA" } } } )
#expr = Moped::BSON::Code.new(""this.name = param", param: "Tool"")
#collections[:bands].find("$where" => expr)

#journeys.find({oCity: o}).update(:$push => { instruments: { name: "Bass" }})
#journeys.find(oCity: o).upsert(:$push => { trains: { t_ref: "00664ALVIA", t_dep: "14:15" }})
#journeys.find(oCity: o).upsert(:$addToSet => { trains: { t_ref: "00664ALVIA", t_dep: "14:15" }})

#journeys.find({oCity: o}).update({ :$push => { trains:{t_dep: "14.15"})
#journeys.find({oCity: o, "trains.t_ref": "00664ALVIA"}).update({ "$set" => {"trains.t_dep": "14.15"})
#journeys.find({station: o, t_ref: tt }).update({t_dep: "14:15"})

#Works! 
#journeys.find( "oCity" => o, "trains.t_ref" => "00664ALVIA").update("$set" => { "trains.1.t_dep" => "14.20" })
#Add a stop to the given train
journeys.find( "oCity" => o, "trains.t_ref" => "99113MD-LD" ).update("$set" => { "trains.0.stops.1" => {"station"=> "Salamanca", "time"=> "10:20" }})

#puts journeys.find({station: o, t_ref: tt }).inspect
#journeys.find({station: o, trains_out.train_name:@trains[[k,0]] })
#journeys.find({station: o}, {trains_out: {$elemMatch:{train_name: @trains[[k,0]]}}})

#Add a set of stops 

# ------ Insertions -------------------------

#Add to DB general data of this Journey
#journeys.find(station: o).upsert( station: o);
#journeys.find(station: o).update({ "$inc" =>{ "trains_out" => @length}})
#journeys.find(station: d).update({ "$inc" =>{ "trains_in" => @length}})

#Adding to the trains_out[] array




#journeys.find({station: o}, {trains_out: {$elemMatch:{school: 102}}}).upsert({"$addToSet" => { "trains_out" => { "dep_time" => @trains[[k,3]], "train_name" => @trains[[k,0]], 

# ------ Loops -------------------------

#Add to DB every Train for this Journey

#for k in (@length).downto(1)
    
  #journeys.find(station: o).upsert({"$addToSet" => { "trains" => {"station" => o, "t#{i}#{j}-#{k}_to" => d, "t#{i}#{j}-#{k}_ref" => @trains[[k,0]], 
   # "t#{i}#{j}-#{k}_dep" => @trains[[k,1]], "t#{i}#{j}-#{k}_arriv" => @trains[[k,2]], "t#{i}#{j}-#{k}_time" => @trains[[k,3]]}}})

  #journeys.find(station: o).upsert({"$addToSet" => { "trains_out" => { "dep_time" => @trains[[k,3]], "train_name" => @trains[[k,0]], "t#{i}#{j}-#{k}_ref" => @trains[[k,0]], 
    #{}"t#{i}#{j}-#{k}_dep" => @trains[[k,1]], "t#{i}#{j}-#{k}_arriv" => @trains[[k,2]], "t#{i}#{j}-#{k}_time" => @trains[[k,3]]}}})
  
#end
