# frozen_string_literal: true
class JobEvent < ApplicationRecord
  include TanoshimuUtils::Concerns::GetRecord

  RUNNING = 'running'
  FAILED = 'failed'
  COMPLETE = 'complete'
  CANCELED = 'canceled'

  STATUSES = [RUNNING, FAILED, COMPLETE, CANCELED].freeze

  belongs_to :user, class_name: 'Users::Admin'

  scope :latest, -> { order(:started_at, :ended_at).reverse_order }
  scope :running, -> { latest.where(status: RUNNING) }
  scope :complete, -> { latest.where(status: COMPLETE) }
  scope :failed, -> { latest.where(status: FAILED) }
  scope :finished, -> { complete.or(failed) }
  scope :latest_by_job_name, -> do
    counts = select(:job_name).group(:job_name).having('count(*) > 1').count
    ids = counts.keys.map { |key| where(job_name: key).last.id }

    where(id: ids).order(started_at: :desc)
  end

  def mark_as_complete!
    update(status: COMPLETE, ended_at: Time.now.utc)
  end

  def mark_as_failed!(exception = nil)
    update(
      status: FAILED,
      ended_at: Time.now.utc,
      failed_reason_key: exception&.class&.name,
      failed_reason_text: exception&.message || 'Unknown internal server error',
      backtrace: exception&.backtrace&.join("\n"),
    )
  end

  def mark_as_canceled!(user, canceled_reason: nil)
    update(
      status: CANCELED,
      ended_at: Time.now.utc,
      canceled_at: Time.now.utc,
      canceled_by: user.id,
      canceled_reason: canceled_reason,
    )
  end

  def record_name
    return if [used_by_model, model_id].include?(nil)

    "#{used_by_model.classify}##{model_id}"
  end

  def cancelable?
    [RUNNING].include?(status)
  end

  def complete?
    status == COMPLETE
  end

  def failed?
    status == FAILED
  end

  def running?
    status == RUNNING
  end

  def self.running_for_job?(job_name)
    running.where(job_name: job_name).exists?
  end

  def self.running_for_model?(model)
    running.where(model_id: model.id, used_by_model: model.class.table_name).exists?
  end
end
