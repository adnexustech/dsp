require 'rails_helper'

RSpec.describe MarketController, type: :controller do
  # Stub authorization and organization creation for all tests
  before do
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
    allow_any_instance_of(User).to receive(:create_personal_organization).and_return(true)
  end

  describe 'authentication' do
    before do
      # Remove the authorization stub for this context
      allow_any_instance_of(ApplicationController).to receive(:authorize).and_call_original
    end

    context 'when user is not logged in' do
      it 'redirects to login for index action' do
        get :index
        expect(response).to redirect_to('/login')
      end

      it 'redirects to login for show action' do
        provider = create(:user)
        get :show, params: { id: provider.id }
        expect(response).to redirect_to('/login')
      end
    end

    context 'when user is logged in' do
      let(:user) { create(:user) }

      before do
        session[:user_id] = user.id
      end

      it 'allows access to index action' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'allows access to show action' do
        provider = create(:user, available_for_hire: true, bio: 'Test bio', skills: 'Ruby, Rails')
        get :show, params: { id: provider.id }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET #index' do
    let!(:available_provider_1) do
      create(:user,
        available_for_hire: true,
        bio: 'Experienced campaign manager',
        skills: 'Campaign Management, Strategy',
        service_categories: 'Campaign Management',
        created_at: 1.day.ago
      )
    end

    let!(:available_provider_2) do
      create(:user,
        available_for_hire: true,
        bio: 'Video production specialist',
        skills: 'Video Editing, Production',
        service_categories: 'Video Production, Content Creation',
        created_at: 2.days.ago
      )
    end

    let!(:available_provider_3) do
      create(:user,
        available_for_hire: true,
        bio: 'Banner design expert',
        skills: 'Photoshop, Illustrator',
        service_categories: 'Banner Design',
        created_at: 3.days.ago
      )
    end

    let!(:provider_without_bio) do
      create(:user,
        available_for_hire: true,
        bio: nil,
        skills: 'Ruby, Rails'
      )
    end

    let!(:provider_with_empty_bio) do
      create(:user,
        available_for_hire: true,
        bio: '',
        skills: 'Ruby, Rails'
      )
    end

    let!(:provider_without_skills) do
      create(:user,
        available_for_hire: true,
        bio: 'Great developer',
        skills: nil
      )
    end

    let!(:provider_with_empty_skills) do
      create(:user,
        available_for_hire: true,
        bio: 'Great developer',
        skills: ''
      )
    end

    let!(:unavailable_provider) do
      create(:user,
        available_for_hire: false,
        bio: 'Not available',
        skills: 'Ruby, Rails'
      )
    end

    context 'without category filter' do
      before { get :index }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @providers with only available_for_hire users who have bio and skills' do
        expect(assigns(:providers)).to match_array([
          available_provider_1,
          available_provider_2,
          available_provider_3
        ])
      end

      it 'excludes providers without bio' do
        expect(assigns(:providers)).not_to include(provider_without_bio)
      end

      it 'excludes providers with empty bio' do
        expect(assigns(:providers)).not_to include(provider_with_empty_bio)
      end

      it 'excludes providers without skills' do
        expect(assigns(:providers)).not_to include(provider_without_skills)
      end

      it 'excludes providers with empty skills' do
        expect(assigns(:providers)).not_to include(provider_with_empty_skills)
      end

      it 'excludes providers not available for hire' do
        expect(assigns(:providers)).not_to include(unavailable_provider)
      end

      it 'orders providers by created_at descending' do
        expect(assigns(:providers).first).to eq(available_provider_1)
        expect(assigns(:providers).last).to eq(available_provider_3)
      end

      it 'assigns @categories array' do
        expect(assigns(:categories)).to eq([
          'Campaign Management',
          'Video Production',
          'Banner Design',
          'Copywriting',
          'Account Strategy',
          'Analytics & Reporting',
          'Social Media Marketing',
          'Content Creation'
        ])
      end

      it 'assigns @category as nil' do
        expect(assigns(:category)).to be_nil
      end
    end

    context 'with category filter' do
      it 'filters providers by exact category match' do
        get :index, params: { category: 'Campaign Management' }
        expect(assigns(:providers)).to contain_exactly(available_provider_1)
      end

      it 'filters providers by partial category match' do
        get :index, params: { category: 'Video Production' }
        expect(assigns(:providers)).to contain_exactly(available_provider_2)
      end

      it 'filters providers with multiple categories' do
        get :index, params: { category: 'Content Creation' }
        expect(assigns(:providers)).to contain_exactly(available_provider_2)
      end

      it 'returns empty when no providers match category' do
        get :index, params: { category: 'Nonexistent Category' }
        expect(assigns(:providers)).to be_empty
      end

      it 'assigns @category param' do
        get :index, params: { category: 'Campaign Management' }
        expect(assigns(:category)).to eq('Campaign Management')
      end

      it 'handles category with special characters safely' do
        # SQL injection test - LIKE query should be safe
        get :index, params: { category: "'; DROP TABLE users; --" }
        expect { assigns(:providers) }.not_to raise_error
        expect(assigns(:providers)).to be_empty
      end
    end

    context 'with 50+ providers' do
      before do
        # Create 60 providers total (including 3 existing)
        57.times do |i|
          create(:user,
            available_for_hire: true,
            bio: "Provider bio #{i}",
            skills: "Skill #{i}",
            created_at: (i + 4).days.ago
          )
        end
      end

      it 'limits results to 50 providers' do
        get :index
        expect(assigns(:providers).count).to eq(50)
      end

      it 'returns most recent 50 providers' do
        get :index
        providers = assigns(:providers)

        # Check first and last provider's created_at
        expect(providers.first.created_at).to be > providers.last.created_at
      end
    end

    context 'with empty marketplace' do
      before do
        User.destroy_all
      end

      it 'returns empty array when no providers exist' do
        get :index
        expect(assigns(:providers)).to be_empty
      end

      it 'still assigns @categories' do
        get :index
        expect(assigns(:categories)).to be_present
        expect(assigns(:categories).count).to eq(8)
      end
    end
  end

  describe 'GET #show' do
    let!(:provider) do
      create(:user,
        available_for_hire: true,
        bio: 'Main provider bio',
        skills: 'Ruby, Rails, JavaScript',
        service_categories: 'Campaign Management'
      )
    end

    let!(:related_provider_1) do
      create(:user,
        available_for_hire: true,
        bio: 'Related provider 1',
        skills: 'Python, Django',
        created_at: 1.day.ago
      )
    end

    let!(:related_provider_2) do
      create(:user,
        available_for_hire: true,
        bio: 'Related provider 2',
        skills: 'PHP, Laravel',
        created_at: 2.days.ago
      )
    end

    let!(:related_provider_3) do
      create(:user,
        available_for_hire: true,
        bio: 'Related provider 3',
        skills: 'Go, Rust',
        created_at: 3.days.ago
      )
    end

    let!(:related_provider_4) do
      create(:user,
        available_for_hire: true,
        bio: 'Related provider 4',
        skills: 'Java, Kotlin',
        created_at: 4.days.ago
      )
    end

    let!(:unavailable_related) do
      create(:user,
        available_for_hire: false,
        bio: 'Not available',
        skills: 'C++, C#'
      )
    end

    let!(:no_bio_related) do
      create(:user,
        available_for_hire: true,
        bio: nil,
        skills: 'Swift, Objective-C'
      )
    end

    context 'with valid provider id' do
      before { get :show, params: { id: provider.id } }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns the requested provider to @provider' do
        expect(assigns(:provider)).to eq(provider)
      end

      it 'assigns @related_providers' do
        expect(assigns(:related_providers)).to be_present
      end

      it 'limits related providers to 3' do
        expect(assigns(:related_providers).count).to eq(3)
      end

      it 'excludes the current provider from related providers' do
        expect(assigns(:related_providers)).not_to include(provider)
      end

      it 'only includes available_for_hire related providers' do
        expect(assigns(:related_providers)).not_to include(unavailable_related)
      end

      it 'only includes related providers with bio' do
        expect(assigns(:related_providers)).not_to include(no_bio_related)
      end

      it 'returns most recent related providers' do
        related = assigns(:related_providers)
        expect(related).to include(related_provider_1, related_provider_2, related_provider_3)
        expect(related).not_to include(related_provider_4) # 4th most recent
      end
    end

    context 'with invalid provider id' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          get :show, params: { id: 99999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when provider is not available_for_hire' do
      let(:unavailable_provider) do
        create(:user,
          available_for_hire: false,
          bio: 'Not available',
          skills: 'Test skills'
        )
      end

      it 'still finds and displays the provider' do
        get :show, params: { id: unavailable_provider.id }
        expect(assigns(:provider)).to eq(unavailable_provider)
      end

      it 'assigns related providers' do
        get :show, params: { id: unavailable_provider.id }
        expect(assigns(:related_providers)).to be_present
      end
    end

    context 'when no related providers exist' do
      before do
        User.where.not(id: provider.id).destroy_all
      end

      it 'assigns empty array for @related_providers' do
        get :show, params: { id: provider.id }
        expect(assigns(:related_providers)).to be_empty
      end
    end

    context 'when fewer than 3 related providers exist' do
      before do
        # Keep only 2 related providers
        User.where.not(id: [provider.id, related_provider_1.id, related_provider_2.id]).destroy_all
      end

      it 'assigns all available related providers' do
        get :show, params: { id: provider.id }
        expect(assigns(:related_providers).count).to eq(2)
        expect(assigns(:related_providers)).to match_array([related_provider_1, related_provider_2])
      end
    end
  end

  describe 'integration scenarios' do
    context 'browsing from index to show' do
      let!(:provider) do
        create(:user,
          available_for_hire: true,
          bio: 'Test provider',
          skills: 'Testing, QA',
          service_categories: 'Analytics & Reporting'
        )
      end

      it 'allows navigating from filtered index to provider show' do
        # First, visit index with filter
        get :index, params: { category: 'Analytics & Reporting' }
        expect(assigns(:providers)).to include(provider)

        # Then, visit provider show page
        get :show, params: { id: provider.id }
        expect(assigns(:provider)).to eq(provider)
      end
    end

    context 'with various service category formats' do
      it 'handles comma-separated categories' do
        provider = create(:user,
          available_for_hire: true,
          bio: 'Multi-skilled',
          skills: 'Everything',
          service_categories: 'Campaign Management, Video Production, Banner Design'
        )

        get :index, params: { category: 'Video Production' }
        expect(assigns(:providers)).to include(provider)
      end

      it 'handles single category' do
        provider = create(:user,
          available_for_hire: true,
          bio: 'Specialist',
          skills: 'Copywriting',
          service_categories: 'Copywriting'
        )

        get :index, params: { category: 'Copywriting' }
        expect(assigns(:providers)).to include(provider)
      end

      it 'handles categories with extra spaces' do
        provider = create(:user,
          available_for_hire: true,
          bio: 'Specialist',
          skills: 'Analysis',
          service_categories: ' Analytics & Reporting , Social Media Marketing '
        )

        get :index, params: { category: 'Analytics & Reporting' }
        expect(assigns(:providers)).to include(provider)
      end
    end
  end
end
