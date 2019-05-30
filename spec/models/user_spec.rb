require 'spec_helper'

RSpec.describe User, type: :model do

  describe 'auth_token' do
    it 'returns the auth_token'
    it 'returns appropriate demo token'
  end

  describe 'username' do
    it 'returns the username'
    it 'returns the appropriate demo username'
  end

  describe 'name' do
    it 'returns the name'
    it 'returns the appropriate demo name'
  end

  describe 'get_name' do
    it 'returns the username if no name is present'
    it 'returns the name if present'
  end

  describe 'episodes_data' do
    it 'includes the progress key for show that hasn\'t been seen'
    it 'includes the progress key for show that has been seen'
  end

  describe 'history' do
    it 'is empty when no episodes have been watched'
    it 'is empty when the progress for all episodes is 0'
    it 'does not go over the limit if specified'
  end

  describe 'allows_setting' do
    it 'does this'
  end

  describe 'is_admin?' do
    it 'does this'
  end

  describe 'is_demo_account?' do
    it 'does this'
  end

  describe 'is_activated?' do
    it 'does this'
  end

  describe 'is_demo?' do
    it 'does this'
  end

  describe 'update_settings' do
    it 'does this'
  end

  describe 'destroy_token' do
    it 'does this'
  end

  describe 'find_by_token' do
    it 'does this'
  end

  describe 'from_omniauth' do
    it 'does this'
  end


end
