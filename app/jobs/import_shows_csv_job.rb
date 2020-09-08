class ImportShowsCsvJob < ApplicationJob
  queue_as :default

  def perform(upload, range: nil)
    upload.attachment.download do |file|
      upload.update(upload_status: :processing)

      operation = Shows::SeedCsv.new(
        io: file,
        range: range,
      )

      operation.perform
      upload.update(upload_status: operation.failed_shows.any? ? :failed_shows : :success)
    end

    upload.update(upload_status: :success)
  rescue => e
    upload.update(upload_status: :failed_exception)
  end
end
