# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(Users::Session, type: :model) do
  specify 'token does not change after update' do
    session = FactoryBot.create(:users_session)
    current_token = session.token

    session.delete!
    expect(session.token).to(eq(current_token))
  end

  it 'cannot be destroyed' do
    session = FactoryBot.create(:users_session)

    expect do
      session.destroy!
    end.to(raise_error(ActiveRecord::RecordNotDestroyed))
  end

  it 'marks the session as deleted' do
    session = FactoryBot.create(:users_session, :active)
    expect(session).to(be_active)
    expect(session).not_to(be_deleted)

    session.delete!
    expect(session).to(be_deleted)
    expect(session.deleted_on).to(be_present)
    expect(session.deleted_on <= Time.now.utc).to(be_truthy)
    expect(session).not_to(be_active)
  end

  it 'can delete an expired session' do
    session = FactoryBot.create(:users_session, :expired)
    expect(session).to(be_expired)
    expect(session).not_to(be_deleted)

    session.delete!
    expect(session).to(be_deleted)
  end

  it 'validates user presence' do
    session = FactoryBot.build(:users_session, user: nil)

    expect(session).not_to(be_valid)
    expect(session.errors[:user]).to(be_present)
  end

  # it 'can validate staff presence' do
  #   staff = FactoryBot.create :staff
  #   session = FactoryBot.create :users_session, user: staff

  #   expect(session).to be_valid
  # end
end
