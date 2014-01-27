class @Settlement
  refresh: ->
    @creditorSum = 0
    @debtorSum = 0

    # 出金側の集計・更新
    creditor_entries = $("table.settlement tr.entry td.creditor")
    for e in creditor_entries
      $tr = $(e).closest("tr")
      $checkbox = $("input[type='checkbox']", $tr)
      if $checkbox.prop("checked")
        @creditorSum += parseInt($(e).text().replace(/,/, ''), 10) if $(e).text() != ""
        $tr.removeClass("disabled")
      else
        $tr.addClass("disabled")
    $('#creditor_sum').html(numToFormattedString(@creditorSum))

    # 入金側の集計・更新
    debtor_entries = $("table.settlement tr.entry td.debtor")
    for e in debtor_entries
      $tr = $(e).closest("tr")
      $checkbox = $("input[type='checkbox']", $tr)
      if $checkbox.prop("checked")
        @debtorSum += parseInt($(e).text().replace(/,/, ''), 10) if $(e).text() != ""
        $tr.removeClass("disabled")
      else
        $tr.addClass("disabled")
    $('#debtor_sum').html(numToFormattedString(@debtorSum))

    # サマリー
    if @creditorSum > @debtorSum
      $('#target_description').html('に');
      $('#result').html(' から ' + numToFormattedString(@creditorSum - @debtorSum) + '円 を入金する。')
    else
      $('#target_description').html('から');
      $('#result').html(' に ' + numToFormattedString(@debtorSum - @creditorSum) + '円 が入金される。')

numToFormattedString = (num) ->
  str = num.toString()
  result = ''
  count = 0
  for i in [str.length-1..0]
    result = str.charAt(i) + result
    break if str.charAt(i) == '-' || i == 0
    count += 1
    if (count % 3) == 0
      result = ',' + result
  result

$ ->
  refreshTargets = ->
    $('#target_deals').load($('#target_deals_form').data('url'), $('#target_deals_form').serialize())

  $('#select_credit_account select.refresh_targets').change(refreshTargets)

  $('#select_credit_account button.refresh_targets').click ->
    refreshTargets()
    return false

  $('#target_deals a.selectAll').click ->
    $('table.book input[type=checkbox]').each ->
      $(@).click() if !@checked
    false

  $('#target_deals a.clearAll').click ->
    $('table.book input[type=checkbox]').each ->
      $(@).click() if @checked
    false
