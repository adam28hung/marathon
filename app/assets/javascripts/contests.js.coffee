$ ->
  $(window).scroll ->
    if $(window).scrollTop() + $(window).height() > $(document).height() - 100
      if $('#load_more_data').length > 0
        $('#load_more_data').click()
        $('#load_more_data_container').empty()
        $('#load_more_data_container').append('<i class="fa fa-spin fa-cog fa-1x"></i>')
    else
    return
