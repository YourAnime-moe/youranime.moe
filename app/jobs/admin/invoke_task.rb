module Admin
  class InvokeTask < ApplicationOperation
    property! :task, accepts: String

    def execute
      task_name = Admin::FetchRunnableTasks.perform.find do |existing_task|
        task == existing_task
      end
      unless task_name.present?
        Rails.logger.error("No task found for #{task}")
        return
      end

      task = Rake::Task[task_name]
      task.execute
    end
  end
end
