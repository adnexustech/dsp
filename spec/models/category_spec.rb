require 'rails_helper'

RSpec.describe Category, type: :model do
  it 'exists as a model' do
    expect(defined?(Category)).to eq('constant')
  end
end
