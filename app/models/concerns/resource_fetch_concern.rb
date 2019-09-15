# frozen_string_literal: true

module ResourceFetchConcern
  extend ActiveSupport::Concern

  class_methods do
    def has_resource(resource_name, default_url: '/', expiry: 1.day)
      resource_url = :"#{resource_name}_url"
      db_resource_url = :"db_#{resource_url}?"
      send(:define_method, db_resource_url) do
        @db_resource_url ||= self.class.column_names.include?(resource_url.to_s)
      end
      send(:define_method, resource_url) do
        ensure_fetchable_resource!(resource_name)
        resource_url_for(resource_name, default_url: default_url, expiry: expiry)
      end
      send(:define_method, "#{resource_url}!") do
        attachment = resource_for(resource_name).attachment
        return default_url if attachment.nil?

        if Config.uses_disk_storage?
          Rails.application.routes.url_helpers.rails_blob_url(attachment, only_path: true)
        else
          attachment.service_url(expires_in: expiry)
        end
      end
      send(:define_method, "#{resource_name}?") do
        resource = fetch!(resource_name)
        resource.blank? ? false : resource.attached?
      end
    end
  end

  private

  def resource_for(resource_name)
    method(resource_name).call
  end

  def resource_url_for(resource_name, default_url: '/', expiry: 1.day)
    ensure_attachable_resource!(resource_name)
    resource_url = :"#{resource_name}_url"
    if try(:"db_#{resource_url}?")
      self[resource_url] || default_url
    else
      resource = resource_for(resource_name)
      if resource.attached?
        p "OOOOGESA"
        #resource.service_url(expires_in: expiry)
      else
        default_url
      end
    end
  end

  def fetch!(resource_name)
    ensure_attachable_resource!(resource_name)
    resource = resource_for(resource_name)
    return resource if resource.attached?

    resource.attach(io: File.open(path), filename: "episode-#{id}")
  rescue ResourceNotAttachable, Errno::ENOENT
    nil
  end

  def ensure_fetchable_resource!(resource_name)
    raise NoMethodError, "Don't know how to fetch #{resource_name}" unless respond_to?(resource_name)
  end

  def ensure_attachable_resource!(resource_name)
    resource_for(resource_name)
  rescue NameError
    raise ResourceNotAttachable, resource unless resource.respond_to?(:attached?)
  end

  class ResourceNotAttachable < StandardError
    def initialize(resource_name)
      super("Resource #{resource_name} not attachable.")
    end
  end
end
