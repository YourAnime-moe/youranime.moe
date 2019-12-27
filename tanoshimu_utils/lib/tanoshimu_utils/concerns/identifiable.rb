module TanoshimuUtils
  module Concerns
    module Identifiable
      extend ActiveSupport::Concern

      included do
        before_validation :ensure_identification

        validates :identification, presence: true
      end

      private

      def ensure_identification
        raise ArgumentError, 'must respond to `identification`' unless respond_to?(:identification)

        self.identification = SecureRandom.hex

        until self.class.where(identification: self.identification)
          self.identification = SecureRandom.hex
        end
      end
    end
  end
end
