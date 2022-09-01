module Admin
  module Types
    class JobEventStatus < ::Types::BaseEnum
      ::JobEvent::STATUSES.each do |status|
        value(status.upcase, value: status)
      end
    end
  end
end
