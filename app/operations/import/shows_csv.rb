# frozen_string_literal: true
require 'csv'

module Import
  class ShowsCsv < ApplicationOperation
    property! :by_author, accepts: User
    property! :file, accepts: [File, Tempfile]
    property :in_batches, default: 1000

    def execute
      init_upload_process!
      read_as_csv!
      data_in_batches

      process_import_later
    end

    private

    attr_reader :upload, :data

    def process_import_later
      data.each do |data_batch|
        BatchOperationJob.perform_later('Shows::SeedCsv', data: data_batch)
      end
    end

    def init_upload_process!
      @upload = Upload.create!(user: by_author, upload_type: :shows)
      AttachmentJob.perform_later(@upload, :attachment, path: file.path, filename: @upload.upload_filename)
    end

    def read_as_csv!
      csv = CSV.new(file.read,
        headers: true,
        header_converters: :symbol,
        converters: :all,)

      @data = csv.to_a.map(&:to_hash)
    end

    def data_in_batches
      @data = @data.in_groups_of(in_batches, false)
    end
  end
end
