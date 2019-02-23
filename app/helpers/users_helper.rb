module UsersHelper

  def home_thumbnails_rules
    [
      {id: 0, class: 'col', display: ''},
      {id: 1, class: 'col', display: ''},
      {id: 2, class: 'col', display: ''},
      {id: 3, class: 'col d-none d-md-block', display: ''},
      {id: 4, class: 'col d-none d-xl-block', display: ''},
      {id: 5, class: 'col d-none d-xl-block', display: ''}
    ]
  end

  def thumb_class_for(model, index)
    rules = home_thumbnails_rules
    last_possible = rules.last[:id]
    rule = rules.select {|rule| rule[:id] == index}[0]
    rule[:display] = 'd-none' if model.nil?
    rule
  end

  def force_array_to(size, array)
    return nil if array.nil? || !array.respond_to?(:size)
    return {cut: array, actual: array} if size <= 0
    current_size = array.size
    return {cut: array[0,size], actual: array} if current_size >= size
    {
      cut: array + ([nil] * (size - current_size)),
      actual: array
    }
  end

end
