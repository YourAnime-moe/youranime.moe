module Navigatable

  def previous(save=true)
    return @previous if save and !@previous.nil?
    klass = self.class
    first_id = klass.first.id
    return nil if first_id == self.id
    pos = self.id - 1
    until false
      result = klass.find_by(id: pos)
      pos -= 1
      unless result.nil?
        return nil if result.show != self.show
        @previous = result
        return result
      end
      return nil if first_id == pos
    end
  end

  def next(save=true)
    raise "Please implement this method (next)"
  end

  def is_first?
    return self.previous.nil?
  end

  def is_last?
    return self.next.nil?
  end

  def -(index)
    if index < 0
      return self + -(index)
    end
    result = self
    while index > 0
      result = result.previous
      if result.nil?
        raise Exception.new("Could not find an episode after this many iterations.")
      end
      index -= 1
    end
    result
  end

  def +(index)
    if index < 0
      return self - -(index)
    end
    result = self
    while index > 0
      result = result.next
      if result.nil?
        raise Exception.new("Could not find an episode after this many iterations.")
      end
      index -= 1
    end
    result
  end

end
