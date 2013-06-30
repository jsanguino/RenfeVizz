require 'csv'
require 'json'
nodes = []
relations = []
#CSV.foreach("../dump/dump.csv", {headers: true}) do |ar| 
 CSV.foreach("./FirstTest/coru.csv", {headers: true}) do |ar| 
    nodes << ar['oCity'] unless nodes.include? ar['oCity']    
    nodes << ar['dCity'] unless nodes.include? ar['dCity']
    relations << [ar['oCity'], ar['dCity'], ar['ntrains']]
end

relations_idx = relations.collect do |rel|
    {"source" => nodes.index(rel[0]), "target" => nodes.index(rel[1]), "value" => rel[2].to_i}
end


nodes_group = nodes.collect do |n|
    {name: n, group: 1}
end

puts ({:nodes => nodes_group,
    :links => relations_idx
}).to_json