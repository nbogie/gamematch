# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery -> 
    $('#game_name_search').autocomplete
        source: "/game_names"
        minLength: 5
        delay: 600

#    $('#game_name_search').keypress((e) ->
#        if e.which == 13
#            $('#submit').submit()
#        )