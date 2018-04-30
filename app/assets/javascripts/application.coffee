# This is a manifest file that'll be compiled into application.js, which will
# include all the files listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts,
# vendor/assets/javascripts, or any plugin's vendor/assets/javascripts directory
# can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at
# the bottom of the compiled file. JavaScript code in this file should be added
# after the last require_* statement.
#
# Read Sprockets README
# (https://github.com/rails/sprockets#sprockets-directives)
# for details about supported directives.
#
#= require jquery3
#= require jquery_ujs
#= require turbolinks
#= require popper
#= require bootstrap
#= require jquery-ui/widgets/droppable
#= require jquery-ui/widgets/sortable

# Compatibility

# Main JS initializer
#= require global

# External
#= require external/bootstrap-datepicker.js
#= require external/clipboard-2.0.0.src.js
#= require external/highcharts-5.0.7.src.js
#= require external/jquery.textcomplete-1.7.3.src.js
#= require external/typeahead-0.11.1-corejavascript.src.js

# Components

# Extensions
#= require extensions/datepicker
#= require extensions/tooltips

# Objects

#= require_tree .
