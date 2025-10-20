require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'password authentication' do
    it 'authenticates with correct password' do
      user = create(:user, password: 'secret123', password_confirmation: 'secret123')
      expect(user.authenticate('secret123')).to eq(user)
    end

    it 'fails authentication with incorrect password' do
      user = create(:user, password: 'secret123', password_confirmation: 'secret123')
      expect(user.authenticate('wrong')).to be_falsey
    end

    it 'requires password on create' do
      user = build(:user, password: nil, password_confirmation: nil)
      expect(user).not_to be_valid
    end
  end

  describe 'factory' do
    it 'creates a valid user' do
      user = build(:user)
      expect(user).to be_valid
    end
  end
end
