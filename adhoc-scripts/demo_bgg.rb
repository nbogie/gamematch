require 'rubygems'
require 'bundler/setup'
require 'bgg'
require './bgg_utils.rb'

def demoShowCollection
  sampleNames = ["enz0", 'Haakon Gaarder']
  myCollection = BggApi.collection({username: sampleNames[0]})
  #myCollection = BggApi.collection({user_id: 749194})
  showDetailsOfMyCollection(myCollection)
end

def main
  all_bgg_names = []
  
  1.upto(7) do |pageNumber|
    guild = BggApi.guild({id: 586, members: 1, page: pageNumber, pagesize: 100})
    (guild['members'][0]['member']).each do |m|
      name = m['name']
      all_bgg_names.push name
    end    
    sleep 2
  end

  all_bgg_names.each do |n|
    puts n
  end

  #demoShowCollection
end
main