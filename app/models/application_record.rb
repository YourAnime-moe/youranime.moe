class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def errors_string(default=nil)
    return default unless errors.any?

    errors.to_a.join(', ')
  end

  def self.random
    function = 'random()'
    if defined?(ActiveRecord::ConnectionAdapters::MysqlAdapter)
      if ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::MysqlAdapter
        function = 'rand()'
      end
    end

    order(function)
  end
end
