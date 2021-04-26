# frozen_string_literal: true
class EmptyJob < TrackableJob
  def perform(name, staff: nil)
    p("This is starting #{name}")
    sleep(10)
    p("This is ending #{name}")
  end
end
