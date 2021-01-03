# frozen_string_literal: true
class AttachmentJob < ApplicationJob
  queue_as :default

  def perform(model, attribute, path:, filename:)
    model.send(attribute).attach(io: File.open(path), filename: filename)
  end
end
