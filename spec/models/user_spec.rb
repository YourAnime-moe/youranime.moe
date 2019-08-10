require 'rails_helper'

RSpec.describe User, type: :model do
  User::USER_TYPES.each do |user_type|
    it "creates a valid `#{user_type}` user" do
      expect(FactoryBot.create(:user, user_type: user_type)).to be_valid
    end
  end

  it 'is invalid when invalid user_type is used' do
    user = FactoryBot.build(:user, user_type: 'junk')

    expect(user).not_to be_valid
  end

  it 'is invalid when username is missing' do
    user = FactoryBot.build(:user, username: nil)

    expect(user).not_to be_valid
  end

  it 'is not valid when name is missing' do
    user = FactoryBot.build(:user, name: nil)

    expect(user).not_to be_valid
  end

  it 'is only accepts valid emails' do
    user = FactoryBot.build(:user, :with_email)
    expect(user).to be_valid

    user = FactoryBot.build(:user, email: 'IamInvalid@test')
    expect(user).not_to be_valid
    expect(user.errors[:email]).to be_present
  end

  it 'creates a valid session with user info' do
    user = FactoryBot.create(:user)

    deleted_session = FactoryBot.create(:users_session, :deleted, user: user)
    expect(user.active_sessions).not_to include(deleted_session)
    expect(user.sessions).to include(deleted_session)

    active_session = FactoryBot.create(:users_session, :active, user: user)
    expect(user.active_sessions).to include(active_session)
    expect(user.sessions).to include(active_session)
  end
end
