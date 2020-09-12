class JobEvent < ApplicationRecord
  include TanoshimuUtils::Concerns::GetRecord

  RUNNING = 'running'
  FAILED = 'failed'
  COMPLETE = 'complete'

  belongs_to :user, class_name: 'Staff'

  scope :latest, -> { order(:started_at, :ended_at).reverse_order }
  scope :running, -> { latest.where(status: RUNNING) }
  scope :complete, -> { latest.where(status: COMPLETE) }
  scope :failed, -> { latest.where(status: FAILED) }

  def mark_as_complete!
    update(status: COMPLETE, ended_at: Time.now.utc)
  end

  def mark_as_failed!(exception = nil)
    update(
      status: FAILED,
      ended_at: Time.now.utc,
      failed_reason_key: exception&.class&.name,
      failed_reason_text: exception&.message || 'Unknown internal server error',
    )
  end

  def record_name
    return if [used_by_model, model_id].include?(nil)

    "#{used_by_model.classify}##{model_id}"
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

  def self.is_running_for_job?(job_name)
    running.where(job_name: job_name).exists?
  end

  def self.is_running_for_model?(model)
    running.where(model_id: model.id, used_by_model: model.class.table_name).exists?
  end
end
