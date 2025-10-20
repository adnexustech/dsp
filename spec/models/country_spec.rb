require 'rails_helper'

RSpec.describe Country, type: :model do
  it 'exists as a model' do
    expect(defined?(Country)).to eq('constant')
  end
end
