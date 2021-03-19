# frozen_string_literal: true
module ProcMe
  def to_proc
    -> (klass, tag) { klass.from_tag(tag) }.curry[self]
  end

  def from_tag(tag)
    if tag.is_a?(self)
      return self
    elsif tag.is_a?(Integer)
      return find(tag) # for active record classes
    elsif tag.is_a?(Symbol)
      return find_tag!(tag) # for non-active record classes, like Shows::Filter
    elsif tag.is_a?(Array)
      return make_tag!(*tag) # for non-active record classes, like Shows::Filter
    end

    raise "Cannot turn `#{tag}' to an instance of `#{self.class}'"
  end
end
