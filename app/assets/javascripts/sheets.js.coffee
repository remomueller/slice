# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@initializeSheet = (filter_element = '') ->
  $("#{filter_element} .chzn-select").chosen({ allow_single_deselect: true })
  $("#{filter_element} .timepicker").timepicker( showMeridian: false, showSeconds: true )
  $("#{filter_element} .datepicker").datepicker('remove')
  $("#{filter_element} .datepicker").datepicker( autoclose: true )
  $("#{filter_element} [data-object~='variable-typeahead']").each( () ->
    $this = $(this)
    $this.typeahead(
      source: (query, process) ->
        variable_id = $this.data('variable-id')
        return $.get(root_url + 'projects/' + $("#sheet_project_id").val() + '/variables/' + variable_id + '/typeahead', { query: query, sheet_authentication_token: ($('#sheet_authentication_token').val() || "") }, (data) -> return process(data))
    )
  )
  updateAllVariables()
  updateCalculatedVariables()
  $('[data-spy~="affix"]').affix( offset: { top: 423 } )
  checkAllRanges()
  $("span[rel~=tooltip], label[rel~=tooltip]").tooltip( trigger: 'hover' )
  $("span[rel~=popover], label[rel~=popover]").popover( trigger: 'hover' )

@evaluateBranchingLogic = () ->
  $('[data-object~="evaluate-branching-logic"]').each( (index, element) ->
    if $(element).data('branching-logic') == ""
      branching_logic_result = true
    else
      try
        branching_logic_result = eval($(element).data('branching-logic'))
      catch error
        branching_logic_result = true

    if branching_logic_result
      # $(element).css('background', "#ccc")
    else
      $(element).hide()
      # $(element).css('background', "#0f0")
  )

jQuery ->
  $("#sheet_design_id").on('change', () ->
    $.post(root_url + 'projects/' + $("#sheet_project_id").val() + '/designs/selection', $(this).serialize(), null, "script")
    false
  )

  $("#sheet_subject_id, #sheet_study_date").on('change', () ->
    $.post(root_url + 'projects/' + $("#sheet_project_id").val() + '/sheets/project_selection', $("sheet_design_id").serialize() + $("#hidden_sheet_id").serialize() + '&' + $("#sheet_subject_id").serialize() + '&' + $("#sheet_design_id").serialize() + '&' + $("#sheet_study_date").serialize(), null, "script")
    false
  )

  $("#email_popup").on('click', () ->
    $('#send_email_modal').modal({ dynamic: true })
    false
  )

  $("#info_popup").on('click', () ->
    $('#info_modal').modal({ dynamic: true })
    false
  )

  $("#email_history_popup").on('click', () ->
    $('#email_history_modal').modal({ dynamic: true })
    false
  )

  $(document)
    .on('click', '[data-object~="export"]', () ->
      url = $($(this).data('target')).attr('action') + '.' + $(this).data('format') + '?' + $($(this).data('target')).serialize()
      if $(this).data('page') == 'blank'
        window.open(url)
      else
        window.location = url
      false
    )
    .on('click', "[data-link]", (e) ->
      if nonStandardClick(e)
        window.open($(this).data("link"))
        return false
      else
        window.location = $(this).data("link")
    )
    .on('click', '[data-object~="export-data"]', () ->
      $('[data-dismiss~=alert]').click()
      form = $(this).data('target')
      $.get($(form).attr("action"), $(form).serialize() + '&export=1', null, "script")
      hideContourModal()
      false
    )

  initializeSheet()
