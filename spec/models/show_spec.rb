require 'rails_helper'

RSpec.describe Show, type: :model do
  include ActionView::Helpers::DateHelper

  Show::SHOW_TYPES.each do |show_type|
    it "creates a valid #{show_type} show" do
      show = FactoryBot.build(:show, show_type: show_type)
      
      expect(show).to be_valid
    end
  end

  it 'creates a valid show only with english title' do
    show = FactoryBot.build(:show, fr_title: '', jp_title: '')

    expect(show).to be_valid
  end

  it 'creates a valid show only with french title' do
    show = FactoryBot.build(:show, en_title: '', jp_title: '')

    expect(show).to be_valid
  end

  it 'creates a valid show only with japanese title' do
    show = FactoryBot.build(:show, fr_title: '', en_title: '')

    expect(show).to be_valid
  end

  it 'is not valid when dubbed and subbed not present' do
    show = FactoryBot.build(:show, subbed: nil, dubbed: nil)

    expect(show).not_to be_valid
  end

  it 'is not published when there is no published on date' do
    show = FactoryBot.create(:show, published_on: nil)

    expect(show).not_to be_published
  end

  [:minute, :hour, :day, :week, :month, :year].each do |unit|
    let(:date_range) { 1.send(unit) }

    it "is not published when published 1 #{unit} from now" do
      date = date_range.from_now.utc

      show = FactoryBot.create(:show, published_on: date)
      expect(show).not_to be_published
    end

    it "is published when published 1 #{unit} ago" do
      date = date_range.ago.utc

      show = FactoryBot.create(:show, published_on: date)
      expect(show).to be_published
    end
  end

  it 'is released today by default' do
    show = FactoryBot.build(:show, released_on: nil)
    expect(show.released_on).to be_nil

    Timecop.freeze do
      show.save

      expect(show.released_on).to be_kind_of(Date)
    end
  end

  it 'belongs to no queues by default' do
    show = FactoryBot.create(:show)

    expect(show.queues).to be_empty
  end

  it 'returns all the queues it belows to' do
    show = FactoryBot.create(:show)
    queue = FactoryBot.create(:shows_queue)

    queue << show

    expect(show.queues).to include(queue)
  end
end
