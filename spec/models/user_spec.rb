require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe "Validations" do
    it "is valid" do
      expect(user).to be_valid
    end

    it "requires an email" do
      user.email = nil
      expect(user).to_not be_valid
    end

    it "encrypts the todoist_access_token" do
      token = "secret_123"
      user.update(todoist_access_token: token)
      
      expect(user.todoist_access_token).to eq(token)
      expect(User.where(todoist_access_token: token)).to_not exist
    end
  end
end