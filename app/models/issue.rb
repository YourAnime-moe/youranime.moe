class Issue < ApplicationRecord
  include AASM
  include ConnectsToShowsConcern

  OPEN = :open
  PENDING = :pending
  IN_PROGRESS = :in_progress
  RESOLVED = :resolved
  CLOSED = :closed
  ARCHIVED = :archived

  STATUSES = [OPEN, PENDING, IN_PROGRESS, RESOLVED, CLOSED, ARCHIVED].freeze
  PAGE_URL_FORMAT = /\A\/[\/\w-]+\z/

  validates :title, presence: true
  validates :description, presence: true
  validates :status, inclusion: { in: STATUSES }

  belongs_to :user, inverse_of: :issues
  validates_format_for :page_url, with: PAGE_URL_FORMAT, if: :page_url?

  aasm column: :status do
    state OPEN, initial: true
    (STATUSES - [OPEN]).each { |status| state(status) }

    event :close do
      transitions from: [OPEN, IN_PROGRESS, PENDING], to: CLOSED
    end

    event :as_pending do
      transitions from: OPEN, to: PENDING
    end

    event :as_in_progress do
      transitions from: PENDING, to: IN_PROGRESS
    end

    event :archive do
      transitions from: [PENDING, CLOSED, RESOLVED], to: ARCHIVED
    end

    event :resolve do
      transitions from: IN_PROGRESS, to: RESOLVED
    end
  end
end
