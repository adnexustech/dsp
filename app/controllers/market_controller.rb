class MarketController < ApplicationController
  before_action :authorize
  
  def index
    @category = params[:category]

    @providers = User.where(available_for_hire: true)
                    .where.not(bio: [nil, ''])
                    .where.not(skills: [nil, ''])

    if @category.present?
      @providers = @providers.where("service_categories LIKE ?", "%#{@category}%")
    end

    @providers = @providers.order(created_at: :desc).limit(50)

    @categories = [
      'Campaign Management',
      'Video Production',
      'Banner Design',
      'Copywriting',
      'Account Strategy',
      'Analytics & Reporting',
      'Social Media Marketing',
      'Content Creation'
    ]
  end

  def show
    @provider = User.find(params[:id])
    @related_providers = User.where(available_for_hire: true)
                             .where.not(id: @provider.id)
                             .where.not(bio: [nil, ''])
                             .limit(3)
  end
end
