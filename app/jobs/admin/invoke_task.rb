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

      try_to_find_job(task_name)
    end

    private

    def try_to_find_job(task_name)
      retries = 5
      count = 0

      while count <= retries
        sleep(1)
        found_job = JobEvent.where(task: task_name).last
        return found_job if found_job.present?

        count += 1
      end

      nil
    end
  end
end
