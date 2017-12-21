require 'test_helper'

class TanoshimuBaseTest < ActiveSupport::TestCase

    def assert_save model
        assert_not model.nil?
        assert model.class < ActiveRecord::Base
        assert model.save
    end

    def assert_save_models models
        assert_not models.nil?
        models.each do |model|
            assert_save model
        end
    end

end
