module Admin
  class FetchRunnableTasks < ApplicationOperation
    property :prefix, accepts: Array, converts: -> (value) { Array.wrap(value) }, default: -> { Array.new }

    def execute
      load_tasks!

      Rake::Task.tasks.map(&:name).filter do |task_name|
        next true if prefix.blank?

        prefix.find do |possible_prefix|
          task_name.start_with?(possible_prefix)
        end
      end
    end

    private

    def load_tasks!
      Rails.application.load_tasks
    end
  end
end
