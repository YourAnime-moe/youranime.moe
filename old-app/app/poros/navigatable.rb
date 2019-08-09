# frozen_string_literal: true

module Navigatable
  def previous(save = true)
    return @previous if save && !@previous.nil?

    klass = self.class
    first_id = klass.first.id
    return nil if first_id == id

    pos = id - 1
    loop do
      result = klass.find_by(id: pos)
      pos -= 1
      unless result.nil?
        return nil if result.show != show

        @previous = result
        return result
      end
      return nil if first_id == pos
    end
  end

  def next(_save = true)
    raise 'Please implement this method (next)'
  end

  def is_first?
    previous.nil?
  end

  def is_last?
    self.next.nil?
  end

  def -(index)
    return self + -index if index < 0

    result = self
    while index > 0
      result = result.previous
      raise Exception, 'Could not find an episode after this many iterations.' if result.nil?

      index -= 1
    end
    result
  end

  def +(index)
    return self - -index if index < 0

    result = self
    while index > 0
      result = result.next
      raise Exception, 'Could not find an episode after this many iterations.' if result.nil?

      index -= 1
    end
    result
  end
end
