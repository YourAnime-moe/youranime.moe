require 'rails_helper'

RSpec.describe Issue, type: :model do
  it 'validates page url if present' do
    valid_issue = FactoryBot.create(:issue, page_url: '/test/test')
    expect(valid_issue).to be_valid

    invalid_issue = FactoryBot.create(:issue, page_url: 'test/test')
    expect(invalid_issue).not_to be_valid
  end

  it 'is not valid without a title' do
    issue = FactoryBot.create(:issue, title: nil)

    expect(issue).not_to be_valid
  end

  it 'is not valid without a description' do
    issue = FactoryBot.create(:issue, description: nil)

    expect(issue).not_to be_valid
  end

  it 'is open by default' do
    issue = FactoryBot.create(:issue)

    expect(issue).to be_open
  end

  context 'with open status' do
    let(:issue) { FactoryBot.create(:issue, :open) }

    [:as_in_progress, :archive, :resolve].each do |transition|
      it "cannot #{transition} an open issue" do
        expect(issue.send("may_#{transition}?")).to be_falsey
      end
    end

    [:close, :as_pending].each do |transition|
      it "can #{transition} an open issue" do
        expect(issue.send("may_#{transition}?")).to be_falsey
      end
    end
  end

  context 'with pending status' do
    let(:issue) { FactoryBot.create(:issue, :pending) }

    [:as_pending, :resolve].each do |transition|
      it "cannot #{transition} an open issue" do
        expect(issue.send("may_#{transition}?")).to be_falsey
      end
    end

    [:close, :as_in_progress, :archive].each do |transition|
      it "can #{transition} an open issue" do
        expect(issue.send("may_#{transition}?")).to be_falsey
      end
    end
  end

  context 'with in_progress status' do
    let(:issue) { FactoryBot.create(:issue, :in_progress) }

    [:as_in_progress, :as_pending, :archive].each do |transition|
      it "cannot #{transition} an open issue" do
        expect(issue.send("may_#{transition}?")).to be_falsey
      end
    end

    [:close, :resolve].each do |transition|
      it "can #{transition} an open issue" do
        expect(issue.send("may_#{transition}?")).to be_falsey
      end
    end
  end

  context 'with resolved status' do
    let(:issue) { FactoryBot.create(:issue, :resolved) }

    [:close, :as_pending, :as_in_progress, :resolve].each do |transition|
      it "cannot #{transition} an open issue" do
        expect(issue.send("may_#{transition}?")).to be_falsey
      end
    end

    [:archive].each do |transition|
      it "can #{transition} an open issue" do
        expect(issue.send("may_#{transition}?")).to be_falsey
      end
    end
  end

  context 'with closed status' do
    let(:issue) { FactoryBot.create(:issue, :closed) }

    [:close, :as_pending, :as_in_progress, :resolve].each do |transition|
      it "cannot #{transition} an open issue" do
        expect(issue.send("may_#{transition}?")).to be_falsey
      end
    end

    [:archive].each do |transition|
      it "can #{transition} an open issue" do
        expect(issue.send("may_#{transition}?")).to be_falsey
      end
    end
  end

  context 'with archived status' do
    let(:issue) { FactoryBot.create(:issue, :archived) }

    [:close, :as_pending, :as_in_progress, :resolve, :archive].each do |transition|
      it "cannot #{transition} an open issue" do
        expect(issue.send("may_#{transition}?")).to be_falsey
      end
    end
  end
end
