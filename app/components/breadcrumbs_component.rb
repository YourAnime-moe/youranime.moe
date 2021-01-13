# frozen_string_literal: true

class BreadcrumbsComponent < ViewComponent::Base
  def initialize(crumbs:, active:)
    @crumbs = crumbs
    @active_crumb = active.try(:name) || active.to_s
  end

  def active_crumb?(crumb)
    crumb[:key] =~ Regexp.new(@active_crumb)
  end
end
