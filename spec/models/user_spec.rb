require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value("test@example.com").for(:email) }
    it { should_not allow_value("bad_email").for(:email) }

    describe "password complexity" do
      it "is valid with 8 chars, a capital, and a special char" do
        user = build(:user, password: "Password123!", password_confirmation: "Password123!")
        expect(user).to be_valid
      end

      it "is invalid without a capital letter" do
        user = build(:user, password: "password123!", password_confirmation: "password123!")
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include(/capital letter/)
      end

      it "is invalid without a special character" do
        user = build(:user, password: "Password123", password_confirmation: "Password123")
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include(/special character/)
      end

      it "is invalid if shorter than 8 characters" do
        user = build(:user, password: "Pas1!", password_confirmation: "Pas1!")
        expect(user).to_not be_valid
      end
    end
  end

  describe "encryption" do
    it "encrypts the todoist_access_token" do
      token = "sensitive_token_123"
      user = create(:user, todoist_access_token: token)

      raw_db_value = ActiveRecord::Base.connection.execute("SELECT todoist_access_token FROM users WHERE id = #{user.id}").first["todoist_access_token"]

      expect(raw_db_value).not_to eq(token)
      expect(user.reload.todoist_access_token).to eq(token)
    end
  end

  describe "#todoist_linked?" do
    it "returns true if token is present" do
      user = build(:user, :with_todoist)
      expect(user.todoist_linked?).to be true
    end

    it "returns false if token is nil" do
      user = build(:user, todoist_access_token: nil)
      expect(user.todoist_linked?).to be false
    end
  end
end
