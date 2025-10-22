class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show, :update, :members, :add_member, :remove_member]
  before_action :require_admin, only: [:update, :add_member, :remove_member]

  def show
    @organization = current_user.current_org
    @members = @organization.organization_members.includes(:user)
    @subscription = @organization.stripe_customer if @organization.stripe_customer_id
  end

  def update
    if @organization.update(organization_params)
      flash[:success] = "Organization updated successfully"
      redirect_to organization_path
    else
      flash.now[:error] = "Failed to update organization"
      render :show
    end
  end

  def switch
    organization = current_user.organizations.find(params[:id])
    
    if current_user.switch_organization(organization)
      flash[:success] = "Switched to #{organization.name}"
      redirect_to root_path
    else
      flash[:error] = "Cannot switch to this organization"
      redirect_back fallback_location: root_path
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Organization not found"
    redirect_to root_path
  end

  def members
    @members = @organization.organization_members.includes(:user)
  end

  def add_member
    email = params[:email]
    role = params[:role] || 'member'
    
    user = User.find_by(email: email)
    
    unless user
      flash[:error] = "User with email #{email} not found"
      redirect_to members_organization_path(@organization) and return
    end
    
    if @organization.member?(user)
      flash[:error] = "#{email} is already a member"
      redirect_to members_organization_path(@organization) and return
    end
    
    if @organization.add_member(user, role: role)
      flash[:success] = "#{email} added as #{role}"
    else
      flash[:error] = "Failed to add member"
    end
    
    redirect_to members_organization_path(@organization)
  end

  def remove_member
    user = User.find(params[:user_id])
    
    if @organization.remove_member(user)
      flash[:success] = "Member removed"
    else
      flash[:error] = "Cannot remove this member"
    end
    
    redirect_to members_organization_path(@organization)
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "User not found"
    redirect_to members_organization_path(@organization)
  end

  private

  def set_organization
    @organization = current_user.current_org
  end

  def require_admin
    member = @organization.organization_members.find_by(user: current_user)
    
    unless member&.can_manage_members?
      flash[:error] = "You don't have permission to manage this organization"
      redirect_to root_path
    end
  end

  def organization_params
    params.require(:organization).permit(:name, :slug)
  end
end
