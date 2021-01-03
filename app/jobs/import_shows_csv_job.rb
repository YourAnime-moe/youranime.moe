# frozen_string_literal: true
class ImportShowsCsvJob < TrackableJob
  queue_as :default

  def perform(upload, batches: 1000, range: nil, staff:)
    raise "Missing user" unless upload.user.present?

    Rails.logger.info("Upload #{upload.uuid} of type '#{upload.upload_type}' by #{upload.user.name}")
    upload.attachment.download do |file|
      upload.update(upload_status: :processing)

      entire_shows_data = shows_data_for(file)
      batches = entire_shows_data.in_groups_of(batches, false)
      Rails.logger.info("Running #{batches.size} batch(es)")

      batches.each do |data|
        BatchOperationJob.perform_later(
          'Shows::SeedCsv',
          data: data,
          range: range,
          staff: staff,
        )
      end
    end

    upload.update(upload_status: :waiting)
  rescue => e
    upload.update(upload_status: :failed_exception)
  ensure
    Rails.logger.info("Upload #{upload.uuid} complete with status '#{upload.upload_status}'")
  end

  private

  def shows_data_for(file)
    file.rewind if file.is_a?(Tempfile) # ensure a tempfile is always readable

    csv = CSV.new(file.read,
      headers: true,
      header_converters: :symbol,
      converters: :all,)
  end
end
