require 'rails_helper'

RSpec.describe Attachment, type: :model do
  it 'exists as a model' do
    expect(defined?(Attachment)).to eq('constant')
  end
end
