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

end
