require "active_storage/service/s3_service"

module ActiveStorage
  class Service::AkinyeleService < Service::S3Service
    def url(key, expires_in:, filename:, disposition:, content_type:)
      instrument :url, key: key do |payload|
        p bucket
        generated_url = object_for(key).presigned_url :get, expires_in: expires_in.to_i,
          response_content_disposition: content_disposition_with(type: disposition, filename: filename),
          response_content_type: content_type

        payload[:url] = generated_url

        generated_url
      end
    end
  end
end
