# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@randomizationsReady = () ->
  $("[data-object~='randomization_subject_search']").each( () ->
    $this = $(this)
    $this.typeahead(
      remote: root_url + "projects/#{$this.data('project-slug')}/randomization_schemes/#{$this.data('randomization-scheme-id')}/subject_search?q=%QUERY"
      template: '<p><span class="label label-{{status_class}}">{{status}}</span> <strong>{{subject_code}}</strong> {{acrostic}}</p>'
      engine: Hogan
    )
  )

$(document)
  .on('typeahead:selected', "[data-object~='randomization_subject_search']", (event, datum) ->
    $("#stratification_factors_#{$(this).data('sfo-id')}_#{datum['site_id']}").prop('checked', true)
  )


