require 'rubygems'
require 'bundler/setup'
require 'bgg'

def gameInfoAsString(g)
  
  own_text = g["status"][0]["own"]
  want_to_play_text = g["status"][0]["wanttoplay"]

  "%-10s %-7s %-13s %s" % [g["objectid"], 
                     own_text=="1" ? "(OWNED)" : "",
                     want_to_play_text=="1" ? "(WantToPlay)" : "",
                     g["name"][0]["content"]]
end

def partitionCollection(colln)
  owned = colln["item"].select do |i|
    i["status"][0]["own"] == "1"
  end
  wantToPlays = colln["item"].select do |i|
    i["status"][0]["wanttoplay"] == "1"
  end  
  info = {}
  info[:owned] = owned
  info[:want_to_play] = wantToPlays
  info
end

def showDetailsOfMyCollection(myCollection)
  #puts myCollection["item"].size
  info = partitionCollection(myCollection)

  owned_strs = info[:owned].map do |g|
    gameInfoAsString(g)
  end
  wanttoplay_strs = info[:want_to_play].map do |g|
    gameInfoAsString(g)
  end
  info[:owned_strs] = owned_strs
  info[:want_to_play_strs] = wanttoplay_strs
  
  puts "OWNED: "
  puts info[:owned_strs].join("\n")
  puts "OWNED---END"
  puts "WANT TO PLAY --- START"
  puts info[:want_to_play_strs].join("\n")
  puts "WANT TO PLAY --- END"
end
