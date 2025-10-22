class ProfilesController < ApplicationController
  before_action :authorize
  before_action :set_user

  def show
    @profile_completion = calculate_profile_completion
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      flash[:success] = "Profile updated successfully"
      redirect_to profile_path
    else
      flash.now[:error] = "Failed to update profile"
      render :edit
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(
      :name,
      :email,
      :bio,
      :skills,
      :hourly_rate,
      :portfolio_url,
      :twitter_url,
      :linkedin_url,
      :available_for_hire,
      :service_categories,
      :avatar
    )
  end

  def calculate_profile_completion
    total_fields = 8
    completed_fields = 0

    completed_fields += 1 if @user.avatar.attached?
    completed_fields += 1 if @user.bio.present?
    completed_fields += 1 if @user.skills.present?
    completed_fields += 1 if @user.hourly_rate.present?
    completed_fields += 1 if @user.portfolio_url.present?
    completed_fields += 1 if @user.twitter_url.present?
    completed_fields += 1 if @user.linkedin_url.present?
    completed_fields += 1 if @user.service_categories.present?

    (completed_fields.to_f / total_fields * 100).round
  end
end
