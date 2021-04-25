# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(Shows::Queue, type: :model) do
  it 'validates user presence' do
    valid_queue = FactoryBot.build(:shows_queue)
    expect(valid_queue).to(be_valid)

    invalid_queue = FactoryBot.build(:shows_queue, graphql_user: nil)
    expect(invalid_queue).not_to(be_valid)
  end
end
