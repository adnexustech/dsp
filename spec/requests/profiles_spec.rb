require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let!(:user) { create(:user, name: "Test User", email: "test@example.com") }
  let!(:organization) { create(:organization, name: "Test Org", owner: user) }
  
  before do
    # Stub organization creation callback
    allow_any_instance_of(User).to receive(:create_personal_organization)
    # Set current organization for user
    user.update(current_organization: organization)
  end

  describe "authentication" do
    context "when user is not logged in" do
      it "redirects to login for show action" do
        get profile_path
        expect(response).to redirect_to('/login')
      end

      it "redirects to login for edit action" do
        get edit_profile_path
        expect(response).to redirect_to('/login')
      end

      it "redirects to login for update action" do
        patch profile_path, params: { user: { bio: "Test" } }
        expect(response).to redirect_to('/login')
      end
    end

    context "when user is logged in" do
      before { setup_authentication }

      it "allows access to show action" do
        get profile_path
        expect(response).to have_http_status(:success)
      end

      it "allows access to edit action" do
        get edit_profile_path
        expect(response).to have_http_status(:success)
      end

      it "allows access to update action" do
        patch profile_path, params: { user: { bio: "New bio" } }
        expect(response).to redirect_to(profile_path)
      end
    end
  end

  describe "GET #show" do
    before { setup_authentication }

    it "returns http success" do
      get profile_path
      expect(response).to have_http_status(:success)
    end

    it "assigns @user as current_user" do
      get profile_path
      expect(assigns(:user)).to eq(user)
    end

    context "profile completion calculation" do
      it "calculates 0% when no profile fields filled" do
        get profile_path
        expect(assigns(:profile_completion)).to eq(0)
      end

      it "calculates 12.5% with just bio (1 of 8 fields)" do
        user.update(bio: "Test bio")
        get profile_path
        expect(assigns(:profile_completion)).to eq(13) # Rounded
      end

      it "calculates 25% with bio and skills (2 of 8 fields)" do
        user.update(bio: "Test bio", skills: "Ruby, Rails")
        get profile_path
        expect(assigns(:profile_completion)).to eq(25)
      end

      it "calculates 100% when all fields filled" do
        user.update(
          bio: "Test bio",
          skills: "Ruby, Rails",
          hourly_rate: 100.0,
          portfolio_url: "https://example.com",
          twitter_url: "https://twitter.com/test",
          linkedin_url: "https://linkedin.com/in/test",
          service_categories: "Development"
        )
        user.avatar.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test.png')),
          filename: 'test.png',
          content_type: 'image/png'
        )
        get profile_path
        expect(assigns(:profile_completion)).to eq(100)
      end
    end
  end

  describe "GET #edit" do
    before { setup_authentication }

    it "returns http success" do
      get edit_profile_path
      expect(response).to have_http_status(:success)
    end

    it "assigns @user as current_user" do
      get edit_profile_path
      expect(assigns(:user)).to eq(user)
    end
  end

  describe "PATCH #update" do
    before { setup_authentication }

    context "with valid parameters" do
      let(:valid_params) do
        {
          user: {
            name: "Updated Name",
            bio: "Updated bio",
            skills: "Ruby, Rails, JavaScript",
            hourly_rate: 150.0,
            portfolio_url: "https://portfolio.example.com",
            twitter_url: "https://twitter.com/updated",
            linkedin_url: "https://linkedin.com/in/updated",
            available_for_hire: true,
            service_categories: "Development, Consulting"
          }
        }
      end

      it "updates the user" do
        patch profile_path, params: valid_params
        user.reload
        expect(user.name).to eq("Updated Name")
        expect(user.bio).to eq("Updated bio")
        expect(user.skills).to eq("Ruby, Rails, JavaScript")
        expect(user.hourly_rate).to eq(150.0)
        expect(user.available_for_hire).to be true
      end

      it "redirects to profile path" do
        patch profile_path, params: valid_params
        expect(response).to redirect_to(profile_path)
      end

      it "sets a success flash message" do
        patch profile_path, params: valid_params
        expect(flash[:success]).to eq("Profile updated successfully")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          user: {
            email: "" # Email can't be blank
          }
        }
      end

      it "does not update the user" do
        original_email = user.email
        patch profile_path, params: invalid_params
        user.reload
        expect(user.email).to eq(original_email)
      end

      it "renders the edit template" do
        patch profile_path, params: invalid_params
        expect(response).to render_template(:edit)
      end

      it "sets an error flash message" do
        patch profile_path, params: invalid_params
        expect(flash[:error]).to eq("Failed to update profile")
      end
    end

    context "updating avatar" do
      it "updates avatar attachment when provided" do
        avatar_file = fixture_file_upload('test.png', 'image/png')
        patch profile_path, params: { user: { avatar: avatar_file } }
        user.reload
        expect(user.avatar).to be_attached
      end
    end

    context "updating individual fields" do
      it "updates bio only" do
        patch profile_path, params: { user: { bio: "New bio only" } }
        user.reload
        expect(user.bio).to eq("New bio only")
      end

      it "updates skills only" do
        patch profile_path, params: { user: { skills: "New skills" } }
        user.reload
        expect(user.skills).to eq("New skills")
      end

      it "updates hourly_rate only" do
        patch profile_path, params: { user: { hourly_rate: 100 } }
        user.reload
        expect(user.hourly_rate.to_i).to eq(100)
      end

      it "updates service_categories only" do
        patch profile_path, params: { user: { service_categories: "Design, Marketing" } }
        user.reload
        expect(user.service_categories).to eq("Design, Marketing")
      end
    end
  end
end
