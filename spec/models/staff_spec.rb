# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(Staff, type: :model) do
  Staff::USER_TYPES.each do |user_type|
    it "creates a valid `#{user_type}` staff user" do
      expect(FactoryBot.create(:staff, user_type: user_type)).to(be_valid)
    end
  end

  it 'is invalid when invalid user_type is used' do
    staff = FactoryBot.build(:staff, user_type: 'junk')

    expect(staff).not_to(be_valid)
  end

  it 'is invalid when username is missing' do
    staff = FactoryBot.build(:staff, username: nil)

    expect(staff).not_to(be_valid)
  end

  it 'is not valid when name is missing' do
    staff = FactoryBot.build(:staff, name: nil)

    expect(staff).not_to(be_valid)
  end

  it 'creates a user from a staff' do
    staff = FactoryBot.create(:staff)
    user = staff.to_user!

    expect(user).to(be_valid)
    expect(user.username).to(eq(staff.username))
    expect(user.name).to(eq(staff.name))
    expect(user.active).to(be_truthy)
    expect(user.limited).to(be_falsey)
    expect(user.sessions).to(be_empty)
    expect(user.can_manage?).to(be_truthy)
  end

  it 'does not recreate the user if already created' do
  end
end
