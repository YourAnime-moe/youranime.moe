require 'spec_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.create(:user) }

  context 'regular user' do
    it 'returns the auth_token' do
      expect(user.auth_token).to eq 'myauthtoken'
    end

    it 'returns the username' do
      expect(user.username).to eq 'user'
    end

    it 'returns the name' do
      expect(user.name).to eq 'Regular Account'
    end

    it 'returns the username if no name is present' do
      user.name = nil
      expect(user.name).to eq user.username
    end
  end

  context 'demo user' do
    let(:user) { FactoryBot.create(:user, :demo) }

    it 'returns the auth_token' do
      expect(user.auth_token).to eq 'demo'
    end

    it 'returns the username' do
      expect(user.username).to eq 'demo'
    end

    it 'returns the name' do
      expect(user.name).to eq 'Demo Account'
    end
  end

  describe 'history' do
    it 'is empty when no episodes have been watched' do
      expect(user.history).to be_empty
    end
  end

  describe 'admin?' do
    it 'is false for a regular user' do
      expect(user.admin?).to be_falsey
    end

    it 'is false for a demo user' do
      user = FactoryBot.create(:user, :demo)
      expect(user.admin?).to be_falsey
    end

    it 'is false an admin that is not active' do
      user = FactoryBot.create(:user, :inactive)
      expect(user.admin?).to be_falsey
    end

    it 'should not be true for an admin that is a demo account' do
      user = FactoryBot.create(:user, :admin, :demo)
      expect(user.admin?).to be_falsey
    end

    it 'is true for an admin' do
      user = FactoryBot.create(:user, :admin)
      expect(user.admin?).to be_truthy
    end
  end

  describe 'activated?' do
    it 'is true by default' do
      expect(user.activated?).to be_truthy
    end

    is 'is true for an active user' do
      user = FactoryBot.create(:user, :active)
      expect(user.activated?).to be_truthy
    end

    is 'is false for an inactive user' do
      user = FactoryBot.create(:user, :inactive)
      expect(user.activated?).to be_falsey
    end
  end

  describe 'destroy_token' do
    it 'removes the auth_token' do
      expect(user.auth_token).not_to be_nil
      user.destroy_token
      expect(user.auth_token).to be_nil
    end
  end

  describe 'find_by_token' do
    it 'returns the user by token' do
      new_user = User.find_by_token(user.auth_token)
      expect(new_user).to eq(user)
    end

    it 'does not return a user for non-existing token' do
      expect(User.find_by_token('thisissomegarbagetoken')).to be_nil
    end
  end
end
