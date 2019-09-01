module GetRecordConcern
  extend ActiveSupport::Concern

  included do
    def record
      used_by_model.classify.constantize.find(model_id)
    end
  end

end
