# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(Actor, type: :model) do
  it 'is invalid if last name is missing' do
    invalid_actors = [
      Actor.new,
      Actor.new(first_name: 'Your'),
      Actor.new(label: 'KyoAni'),
    ]

    invalid_actors.each do |actor|
      expect(actor).not_to(be_valid)
      expect(actor.errors[:last_name]).to(be_present)
    end
  end

  it 'validates if the last name is there' do
    actor = Actor.new

    expect(actor).not_to(be_valid)
    expect(actor.errors[:last_name]).to(be_present)
  end

  context 'name' do
    it 'is nil when the actor is not valid' do
      actor = Actor.new

      expect(actor.name).to(be_nil)
    end
  end

  it 'builds the name properly' do
  end
end
