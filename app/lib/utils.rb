require 'i18n'

class Utils
  def self.tags
    I18n.t('tags')[:tags]
  end

  def self.valid_tags
    valid_sym = tags.keys
    valid_string = valid_sym.map(&:to_s)
    valid_sym + valid_string
  end
end
