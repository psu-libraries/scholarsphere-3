# frozen_string_literal: true
require "rails_helper"
require "rake"

describe "scholarsphere:users:list" do
  let!(:user_list) do
    (1..3).map do |n|
      User.create(login: "user#{n}", email: "user#{n}@example.org")
    end
  end

  # set up the rake environment
  before do
    load_rake_environment ["#{Rails.root}/lib/tasks/scholarsphere/users.rake"]
  end

  describe "list users" do
    it "includes all users" do
      run_task "scholarsphere:users:list"
      filename = Rails.root.join("user_emails.txt")
      expect(Dir.glob(filename).entries.size).to eq(1)
      f = File.open(filename)
      output = f.read
      user_list.each do |user|
        expect(output).to include(user.email)
      end
    end
  end

  describe "restoring users" do
    it "adds users to the database" do
      run_task "scholarsphere:users:restore"
    end
  end

  describe "quota report" do
    it "adds users to the database" do
      run_task "scholarsphere:users:quota_report"
    end
  end
end
