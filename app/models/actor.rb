# frozen_string_literal: true
class Actor < ApplicationRecord
  validates_presence_of :last_name

  DEFAULT_FORMAT = "%{last_name}, %{first_name}"
  FORMAT_RE = /\%\{(\w+)\}/

  def name(format: DEFAULT_FORMAT)
    return unless valid?

    properties = format.scan(FORMAT_RE).flatten

    invalid_properties = []
    properties.each do |property|
      invalid_properties << property unless respond_to?(property)
    end

    raise "Invalid DB property for Actor: #{invalid_properties.join(', ')}" if invalid_properties.any?

    properties.each do |property|
      format.gsub!("%{#{property}}", self[property])
    end

    format
  end
end
