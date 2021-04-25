# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(Show, type: :model) do
  it 'is a valid show' do
    show = FactoryBot.build(:show)
    expect(show).to(be_valid)
  end

  it 'is invalid without a slug' do
    show = FactoryBot.build(:show, slug: nil)
    expect(show).not_to(be_valid)
    expect(show.errors.messages[:slug]).to(include("can't be blank"))
  end

  it 'is invalid without a title' do
    show = FactoryBot.build(:show, titles: {})
    expect(show).not_to(be_valid)
    expect(show.errors.messages[:titles]).to(include("can't be blank"))
  end
end
