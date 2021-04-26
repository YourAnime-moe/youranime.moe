# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(Show, type: :model) do
  it 'is a valid show' do
    show = FactoryBot.build(:show)
    expect(show).to(be_valid)
  end

  it 'is invalid without required fields' do
    show = FactoryBot.build(:show, slug: nil, titles: {})
    expect(show).not_to(be_valid)

    expect(show.errors.messages[:slug]).to(include("can't be blank"))
    expect(show.errors.messages[:titles]).to(include("can't be blank"))
  end

  it 'sets default released_on with nil' do
    show = FactoryBot.build(:show, released_on: nil)
    expect(show.released_on).to(be_nil)
    expect(show).to(be_valid)
    expect(show.released_on).to(be_today)
  end
end
