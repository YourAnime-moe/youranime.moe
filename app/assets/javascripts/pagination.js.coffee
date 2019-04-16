jQuery ->
  if $('#infinite-scrolling').size() > 0
    $(window).on 'scroll', ->
      more_shows_url = $('.pagination .next_page a').attr('href')
      if more_shows_url && $(window).scrollTop() > $(document).height() - $(window).height() - 60
          $('.pagination').html('<div class="w-100 padded text-center"><img src="/assets/ajax-loader.gif" alt="Loading..." title="Loading..." /></div>')
          $.getScript more_shows_url
        return
      return
