require 'rubygems'
require 'json'
require 'pp'

json = File.read('./SecondTest/mini-test.json')
stations = JSON.parse(json)

puts stations[0]["trains"][0]["t57-4_ref"]

#pp stations.select{|key, value| hash["t957-2_to"] == "Navalmoral de la Mata" }
#puts stations[0]["trains"]
##pp stations