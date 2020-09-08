class ImportShowsCsvJob < ApplicationJob
  queue_as :default

  def perform(upload, range: nil)
    upload.attachment.download do |file|
      Shows::SeedCsv.perform(
        io: file,
        range: range,
      )
    end
  end
end
