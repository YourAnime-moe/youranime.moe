# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(Show, type: :model) do
  it 'is a valid show' do
    show = FactoryBot.build(:show)
    expect(show).to(be_valid)
  end

  it 'is invalid without required fields' do
    show = FactoryBot.build(:show, slug: nil, titles: {}, released_on: nil, banner_url: nil)
    expect(show).not_to(be_valid)
    expect(show.errors.messages[:slug]).to(include("can't be blank"))
    expect(show.errors.messages[:released_on]).to(include("can't be blank"))
    expect(show.errors.messages[:banner_url]).to(include("can't be blank"))
    expect(show.errors.messages[:titles]).to(include("can't be blank"))
  end
end
