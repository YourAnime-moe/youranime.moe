# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(Show, type: :model) do
  include ActionView::Helpers::DateHelper

  Show::SHOW_TYPES.each do |show_type|
    it "creates a valid #{show_type} show" do
      show = FactoryBot.build(:show, show_type: show_type)

      expect(show).to(be_valid)
    end
  end

  it 'creates a valid show only with english title' do
    title = FactoryBot.build(:title, en: 'In English')
    show = FactoryBot.build(:show, title: title)

    expect(show).to(be_valid)
  end

  it 'creates a valid show only with french title' do
    title = FactoryBot.build(:title, fr: 'En francais')
    show = FactoryBot.build(:show, title: title)

    expect(show).to(be_valid)
  end

  it 'creates a valid show only with japanese title' do
    title = FactoryBot.build(:title, jp: '日本語で')
    show = FactoryBot.build(:show, title: title)

    expect(show).to(be_valid)
  end

  it 'is not valid when dubbed and subbed not present' do
    show = FactoryBot.build(:show, subbed: nil, dubbed: nil)

    expect(show).not_to(be_valid)
  end

  [:minute, :hour, :day, :week, :month, :year].each do |unit|
    let(:date_range) { 1.send(unit) }

    it "is not published when published 1 #{unit} from now" do
      # date = date_range.from_now.utc

      show = FactoryBot.build(:show, published: true)
      expect(show).not_to(be_published)
    end

    it "is published when published 1 #{unit} ago" do
      # date = date_range.ago.utc

      show = FactoryBot.build(:show, published: true)
      expect(show).to(be_published)
    end
  end

  it 'is released today by default' do
    title = FactoryBot.build(:title, en: 'my show')
    show = FactoryBot.build(:show, released_on: nil, title: title)
    expect(show.released_on).to(be_nil)

    Timecop.freeze do
      show.save

      expect(show.released_on).to(be_kind_of(Date))
    end
  end

  it 'belongs to no queues by default' do
    show = create_show

    expect(show.queues).to(be_empty)
  end

  it 'returns all the queues it belows to' do
    show = create_show
    queue = FactoryBot.create(:shows_queue)

    queue << show

    expect(show.queues).to(include(queue))
  end
end

def create_show(*args, **options)
  show = FactoryBot.build(:show, *args, **options)
  show.title = FactoryBot.build(:title)
  show.save

  expect(show).to(be_persisted)
  show
end
