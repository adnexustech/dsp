# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:organization) { create(:organization, owner: create(:user)) }
  let(:user) { create(:user, current_organization: organization) }

  before do
    allow_any_instance_of(User).to receive(:create_personal_organization)
  end

  describe 'associations' do
    it { is_expected.to have_one_attached(:avatar) }
    it { is_expected.to belong_to(:current_organization).class_name('Organization').optional }
  end

  describe 'validations' do
    context 'basic validations' do
      it 'is valid with valid attributes' do
        expect(user).to be_valid
      end

      it 'is invalid without an email' do
        user.email = nil
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("can't be blank")
      end

      it 'is invalid with a duplicate email' do
        create(:user, email: 'duplicate@example.com')
        duplicate_user = build(:user, email: 'duplicate@example.com')
        expect(duplicate_user).not_to be_valid
        expect(duplicate_user.errors[:email]).to include('has already been taken')
      end
    end

    context 'URL validations' do
      it 'is valid with properly formatted portfolio URL' do
        user.portfolio_url = 'https://example.com/portfolio'
        expect(user).to be_valid
      end

      it 'is valid with properly formatted Twitter URL' do
        user.twitter_url = 'https://twitter.com/username'
        expect(user).to be_valid
      end

      it 'is valid with properly formatted LinkedIn URL' do
        user.linkedin_url = 'https://linkedin.com/in/username'
        expect(user).to be_valid
      end

      it 'allows blank URLs' do
        user.portfolio_url = nil
        user.twitter_url = ''
        user.linkedin_url = nil
        expect(user).to be_valid
      end
    end

    context 'hourly rate validation' do
      it 'allows positive hourly rates' do
        user.hourly_rate = 100
        expect(user).to be_valid
      end

      it 'allows zero hourly rate' do
        user.hourly_rate = 0
        expect(user).to be_valid
      end

      it 'allows nil hourly rate' do
        user.hourly_rate = nil
        expect(user).to be_valid
      end
    end
  end

  describe 'profile fields' do
    context 'bio' do
      it 'can be set and retrieved' do
        user.bio = 'Experienced developer with 10 years in Rails'
        user.save
        expect(user.reload.bio).to eq('Experienced developer with 10 years in Rails')
      end

      it 'can be blank' do
        user.bio = nil
        expect(user).to be_valid
      end

      it 'accepts long text' do
        long_bio = 'A' * 1000
        user.bio = long_bio
        user.save
        expect(user.reload.bio).to eq(long_bio)
      end
    end

    context 'skills' do
      it 'can be set and retrieved' do
        user.skills = 'Ruby, Rails, JavaScript, React'
        user.save
        expect(user.reload.skills).to eq('Ruby, Rails, JavaScript, React')
      end

      it 'can be blank' do
        user.skills = nil
        expect(user).to be_valid
      end
    end

    context 'service_categories' do
      it 'can be set and retrieved' do
        user.service_categories = 'Campaign Management, Video Production'
        user.save
        expect(user.reload.service_categories).to eq('Campaign Management, Video Production')
      end

      it 'can store multiple categories' do
        categories = 'Development, Design, Marketing, Analytics'
        user.service_categories = categories
        user.save
        expect(user.reload.service_categories).to eq(categories)
      end
    end

    context 'available_for_hire' do
      it 'defaults to false' do
        new_user = User.new(email: 'new@example.com', password: 'password123')
        expect(new_user.available_for_hire).to be_falsey
      end

      it 'can be set to true' do
        user.available_for_hire = true
        user.save
        expect(user.reload.available_for_hire).to be true
      end

      it 'can be set to false' do
        user.available_for_hire = false
        user.save
        expect(user.reload.available_for_hire).to be false
      end
    end

    context 'social URLs' do
      it 'stores portfolio URL correctly' do
        url = 'https://johndoe.com'
        user.portfolio_url = url
        user.save
        expect(user.reload.portfolio_url).to eq(url)
      end

      it 'stores Twitter URL correctly' do
        url = 'https://twitter.com/johndoe'
        user.twitter_url = url
        user.save
        expect(user.reload.twitter_url).to eq(url)
      end

      it 'stores LinkedIn URL correctly' do
        url = 'https://linkedin.com/in/johndoe'
        user.linkedin_url = url
        user.save
        expect(user.reload.linkedin_url).to eq(url)
      end
    end
  end

  describe 'avatar attachment' do
    it 'can attach an avatar' do
      user.avatar.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test.png')),
        filename: 'avatar.png',
        content_type: 'image/png'
      )
      expect(user.avatar).to be_attached
    end

    it 'can check if avatar is attached' do
      expect(user.avatar.attached?).to be false
      
      user.avatar.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test.png')),
        filename: 'avatar.png',
        content_type: 'image/png'
      )
      
      expect(user.avatar.attached?).to be true
    end

    it 'can purge an attached avatar' do
      user.avatar.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test.png')),
        filename: 'avatar.png',
        content_type: 'image/png'
      )
      
      expect(user.avatar.attached?).to be true
      user.avatar.purge
      expect(user.avatar.attached?).to be false
    end
  end

  describe '#create_personal_organization' do
    before do
      # Don't stub the method for these tests
      allow_any_instance_of(User).to receive(:create_personal_organization).and_call_original
    end

    it 'creates an organization for the user' do
      expect {
        create(:user, name: 'John Doe', email: 'john@example.com')
      }.to change(Organization, :count).by(1)
    end

    it 'sets the user as owner of the organization' do
      new_user = create(:user, name: 'John Doe', email: 'john@example.com')
      org = Organization.find_by(owner: new_user)
      
      expect(org).to be_present
      expect(org.owner).to eq(new_user)
    end

    it 'sets organization name based on user name' do
      new_user = create(:user, name: 'John Doe', email: 'john@example.com')
      org = Organization.find_by(owner: new_user)
      
      expect(org.name).to eq("John Doe's Organization")
    end

    it 'sets organization slug based on name or email' do
      new_user = create(:user, name: 'John Doe', email: 'john@example.com')
      org = Organization.find_by(owner: new_user)
      
      # Slug is based on organization name which is derived from user name
      expect(org.slug).to match(/john/) | match(/doe/) | match(/organization/)
    end

    it 'initializes organization with zero credits balance' do
      new_user = create(:user, name: 'John Doe', email: 'john@example.com')
      org = Organization.find_by(owner: new_user)
      
      expect(org.credits_balance).to eq(0.0)
    end
  end

  describe 'marketplace profile completeness' do
    context 'empty profile' do
      it 'has incomplete profile when no fields are filled' do
        expect(user.bio).to be_blank
        expect(user.skills).to be_blank
        expect(user.hourly_rate).to be_nil
        expect(user.portfolio_url).to be_blank
        expect(user.twitter_url).to be_blank
        expect(user.linkedin_url).to be_blank
        expect(user.service_categories).to be_blank
        expect(user.avatar.attached?).to be false
      end
    end

    context 'partially filled profile' do
      it 'can have only bio filled' do
        user.bio = 'Developer'
        user.save
        expect(user.bio).to be_present
        expect(user.skills).to be_blank
      end

      it 'can have only skills filled' do
        user.skills = 'Ruby, Rails'
        user.save
        expect(user.skills).to be_present
        expect(user.bio).to be_blank
      end
    end

    context 'complete profile' do
      it 'has all profile fields filled' do
        user.bio = 'Experienced developer'
        user.skills = 'Ruby, Rails, JavaScript'
        user.hourly_rate = 100
        user.portfolio_url = 'https://example.com'
        user.twitter_url = 'https://twitter.com/user'
        user.linkedin_url = 'https://linkedin.com/in/user'
        user.service_categories = 'Development'
        user.avatar.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test.png')),
          filename: 'avatar.png',
          content_type: 'image/png'
        )
        user.save

        expect(user.bio).to be_present
        expect(user.skills).to be_present
        expect(user.hourly_rate).to be_present
        expect(user.portfolio_url).to be_present
        expect(user.twitter_url).to be_present
        expect(user.linkedin_url).to be_present
        expect(user.service_categories).to be_present
        expect(user.avatar.attached?).to be true
      end
    end
  end

  describe 'marketplace visibility' do
    context 'when available_for_hire is true' do
      it 'appears in marketplace provider queries' do
        user.update(
          available_for_hire: true,
          bio: 'Test bio',
          skills: 'Ruby on Rails'
        )

        providers = User.where(available_for_hire: true)
                       .where.not(bio: [nil, ''])
                       .where.not(skills: [nil, ''])

        expect(providers).to include(user)
      end
    end

    context 'when available_for_hire is false' do
      it 'does not appear in marketplace provider queries' do
        user.update(
          available_for_hire: false,
          bio: 'Test bio',
          skills: 'Ruby on Rails'
        )

        providers = User.where(available_for_hire: true)
                       .where.not(bio: [nil, ''])
                       .where.not(skills: [nil, ''])

        expect(providers).not_to include(user)
      end
    end

    context 'when bio or skills are blank' do
      it 'does not appear in marketplace even if available_for_hire is true' do
        user.update(
          available_for_hire: true,
          bio: nil,
          skills: nil
        )

        providers = User.where(available_for_hire: true)
                       .where.not(bio: [nil, ''])
                       .where.not(skills: [nil, ''])

        expect(providers).not_to include(user)
      end
    end
  end

  describe 'service category filtering' do
    it 'can filter users by service category' do
      user.update(
        available_for_hire: true,
        bio: 'Developer',
        skills: 'Ruby',
        service_categories: 'Campaign Management, Video Production'
      )

      results = User.where(available_for_hire: true)
                   .where("service_categories LIKE ?", "%Campaign Management%")

      expect(results).to include(user)
    end

    it 'does not match users without matching categories' do
      user.update(
        available_for_hire: true,
        bio: 'Developer',
        skills: 'Ruby',
        service_categories: 'Banner Design'
      )

      results = User.where(available_for_hire: true)
                   .where("service_categories LIKE ?", "%Campaign Management%")

      expect(results).not_to include(user)
    end
  end
end
