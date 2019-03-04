module ShowsHelper

  def show_tags(show)
    return if show.tags.blank?
    links = show.tags.map{|t| t.downcase.to_sym}.map do |tag|
      link_to(Utils.tags[tag], '#', class: 'btn tag')
    end
    content_tag(:div, class: 'tags-container') do
      links.join('').html_safe
    end
  end

  def sub_dub_holder(show)
    return unless show.class == Show
    content_tag :div, class: 'sub-dub-holder' do
      show_sub_dub(show)
    end
  end

  def show_sub_dub(show)
    return unless show.class == Show
    if show.only_subbed?
      sub_tag
    elsif show.only_dubbed?
      dub_tag
    else
      sub_tag
      dub_tag
    end
  end

  def dub_tag
    badge(type: 'success', content: "dub")
  end

  def sub_tag
    badge(type: 'danger', content: "sub")
  end

  def badge(type: nil, content: nil)
    content_tag :span, class: "badge badge-#{type}" do
      content
    end
  end

end
