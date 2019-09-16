module TranslatableConcern
  extend ActiveSupport::Concern

  def metaclass
    class << self
      self
    end
  end

  class_methods do
    def translates(field, through: [], default:)
      raise 'Field must be present' unless field.present?
      raise 'Through must be present' unless through.present?

      if column_names.include?(field.to_s)
        raise 'Field must not be defined on the model'
      end

      through = [through] unless through.kind_of?(Array)
      default = default.to_sym

      unless I18n.available_locales.include?(default)
        raise "#{default} is not available on your system as a locale"
      end

      send(:define_method, field.to_sym) do
        through.each do |possible_locale|
          possible_locale = possible_locale.to_sym

          unless I18n.available_locales.include?(possible_locale)
            next
          end
        end

        return nil unless through.include?(I18n.locale)
        value = send(I18n.locale)
        value = send(default) if value.nil? && default
        value
      end
    end
  end
end